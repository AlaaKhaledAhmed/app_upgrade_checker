import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_upgrade_checker/app_upgrade_checker.dart';

/// The dialog and the sheet render the SAME blocks as the full screen, from the
/// same theme — that promise is what these tests hold in place.
void main() {
  // A check reads the installed build via package_info_plus, which needs the
  // binding and a stubbed platform channel.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (call) async => <String, dynamic>{
        'appName': 'test',
        'packageName': 'com.example.test',
        'version': '1.0.0',
        'buildNumber': '1',
      },
    );
  });

  /// Bounded pumps, not `pumpAndSettle`: the artwork loops forever, so settling
  /// never completes.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Prompts the way an idle app does — from a context in the tree, exactly as
  /// `prompting from an idle app` in the main suite. `checkAndPrompt` only
  /// returns once the prompt is dismissed, so it is deliberately not awaited.
  Future<BuildContext> prompt(
    WidgetTester tester,
    AppUpgradeTheme theme, {
    UpdatePreview? preview,
  }) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const Scaffold(body: Text('home'));
      }),
    ));

    unawaited(AppUpgrade.checkAndPrompt(
      ctx,
      theme: theme,
      preview: preview ?? UpdatePreview.optional(delay: Duration.zero),
    ));

    await settle(tester);
    return ctx;
  }

  /// Closes whatever is open so the pending future finishes and the library's
  /// "already prompting" lock is released before the next test.
  ///
  /// The lock is static, so a test that leaves its prompt open makes every later
  /// test in this file see "already prompting" and render nothing.
  Future<void> dismiss(WidgetTester tester, BuildContext ctx) async {
    // Pop until the prompt is gone: a dialog route and a pushed page both sit
    // on the root navigator, but a modal sheet adds one of its own.
    for (var i = 0; i < 3; i++) {
      final open = find.byType(AppUpgradeScreen).evaluate().isNotEmpty ||
          find.byType(AppUpgradeDialog).evaluate().isNotEmpty;
      if (!open) break;
      Navigator.of(ctx, rootNavigator: true).pop();
      await settle(tester);
    }
  }

  /// Cosmic's default English copy, so a rendered block can be found by text.
  final strings = ThemeStrings.of(ThemeLang.en);

  group('viewType', () {
    testWidgets('screen is the default and still renders', (tester) async {
      final ctx = await prompt(tester, AppUpgradeTheme.cosmic());

      expect(find.byType(AppUpgradeScreen), findsOneWidget);
      expect(find.text(strings.updateButton), findsOneWidget);

      await dismiss(tester, ctx);
    });

    testWidgets('dialog renders the same blocks, not the screen',
        (tester) async {
      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(viewType: UpdateViewType.dialog),
      );

      expect(find.byType(AppUpgradeScreen), findsNothing);
      expect(find.byType(AppUpgradeDialog), findsOneWidget);
      // Title, description and both buttons all arrive.
      expect(find.text(strings.titleFirst), findsOneWidget);
      expect(find.text(strings.updateButton), findsOneWidget);
      expect(find.text(strings.laterButton), findsOneWidget);

      await dismiss(tester, ctx);
    });

    testWidgets('sheet renders the same blocks', (tester) async {
      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(viewType: UpdateViewType.sheet),
      );

      expect(find.byType(AppUpgradeScreen), findsNothing);
      expect(find.byType(AppUpgradeSheet), findsOneWidget);
      expect(find.text(strings.updateButton), findsOneWidget);
      expect(find.text(strings.laterButton), findsOneWidget);

      await dismiss(tester, ctx);
    });

    testWidgets('show* flags are honoured in a dialog', (tester) async {
      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(
          viewType: UpdateViewType.dialog,
          showBadge: true,
          showLaterButton: false,
        ),
      );

      // The rendered pill is prefix + text, so match on a substring.
      expect(find.textContaining(strings.badge), findsOneWidget);
      expect(find.text(strings.laterButton), findsNothing);

      await dismiss(tester, ctx);
    });

    testWidgets('a mandatory update hides Later in a dialog', (tester) async {
      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(viewType: UpdateViewType.dialog),
        preview: UpdatePreview.forced(delay: Duration.zero),
      );

      expect(find.text(strings.updateButton), findsOneWidget);
      expect(find.text(strings.laterButton), findsNothing);

      await dismiss(tester, ctx);
    });

    testWidgets('the dialog stays within its height cap', (tester) async {
      // Every block on, on a short screen — the worst case for overflow.
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(
          viewType: UpdateViewType.dialog,
          showBadge: true,
          showFeatures: true,
          showVersion: true,
        ),
      );

      // The visible card is the ConstrainedBox the dialog wraps its content in;
      // AppUpgradeDialog itself fills the screen so it can centre that card.
      final card = tester.getSize(
        find
            .descendant(
              of: find.byType(AppUpgradeDialog),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      expect(
        card.height,
        lessThanOrEqualTo(700 * AppUpgradeDialog.maxHeightFactor + 1),
      );
      // A capped card scrolls rather than overflowing.
      expect(tester.takeException(), isNull);

      await dismiss(tester, ctx);
    });

    /// A long release note used to run unbounded inside the card and push the
    /// update button past the bottom edge — the one block that could hide the
    /// primary action. The card caps the paragraph instead.
    testWidgets('a long release note cannot hide the update button',
        (tester) async {
      tester.view.physicalSize = const Size(400, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(viewType: UpdateViewType.dialog),
        preview: UpdatePreview.optional(
          delay: Duration.zero,
          releaseNotes: 'Rewrote sync. ' * 60,
        ),
      );

      final button = find.text(strings.updateButton);
      expect(button, findsOneWidget);

      // Inside the card, not below it.
      final card = tester.getRect(
        find
            .descendant(
              of: find.byType(AppUpgradeDialog),
              matching: find.byType(ClipRRect),
            )
            .first,
      );
      expect(tester.getRect(button).bottom, lessThanOrEqualTo(card.bottom));

      await dismiss(tester, ctx);
    });

    testWidgets('one theme shows two ways via copyWith', (tester) async {
      final theme = AppUpgradeTheme.cosmic();

      var ctx = await prompt(tester, theme);
      expect(find.byType(AppUpgradeScreen), findsOneWidget);
      await dismiss(tester, ctx);

      ctx =
          await prompt(tester, theme.copyWith(viewType: UpdateViewType.dialog));
      expect(find.byType(AppUpgradeScreen), findsNothing);
      expect(find.byType(AppUpgradeDialog), findsOneWidget);
      await dismiss(tester, ctx);
    });
  });

  group('dialogEntrance', () {
    /// A screen-only entrance carried on a theme shown as a dialog is inert —
    /// this is what makes `copyWith(viewType:)` safe, so it must not throw.
    testWidgets('a screen entrance is ignored by a dialog', (tester) async {
      final ctx = await prompt(
        tester,
        AppUpgradeTheme.cosmic(
          viewType: UpdateViewType.dialog,
          entrance: const UpdateEntrance.rocketPull(),
        ),
      );

      expect(find.byType(AppUpgradeDialog), findsOneWidget);
      expect(find.text(strings.updateButton), findsOneWidget);

      await dismiss(tester, ctx);
    });

    for (final entry in <String, DialogEntrance>{
      'popIn': const DialogEntrance.popIn(),
      'slideUp': const DialogEntrance.slideUp(),
      'fade': const DialogEntrance.fade(),
      'none': const DialogEntrance.none(),
      'popIn without overshoot': const DialogEntrance.popIn(overshoot: false),
    }.entries) {
      testWidgets('${entry.key} settles', (tester) async {
        final ctx = await prompt(
          tester,
          AppUpgradeTheme.cosmic(
            viewType: UpdateViewType.dialog,
            dialogEntrance: entry.value,
          ),
        );

        expect(find.text(strings.updateButton), findsOneWidget);
        expect(tester.takeException(), isNull);

        await dismiss(tester, ctx);
      });
    }
  });
}
