import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_upgrade_checker/app_upgrade_checker.dart';

/// `viewType` belongs to the theme, not to one design — every design takes it,
/// and each carries its own `dialogEntrance`. These tests hold that in place so
/// a new design cannot ship as screen-only again.
void main() {
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

  Future<BuildContext> prompt(
      WidgetTester tester, AppUpgradeTheme theme) async {
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
      preview: UpdatePreview.optional(delay: Duration.zero),
    ));

    await settle(tester);
    return ctx;
  }

  /// Releases the library's static "already prompting" lock, which would
  /// otherwise make every later test render nothing.
  Future<void> dismiss(WidgetTester tester, BuildContext ctx) async {
    for (var i = 0; i < 3; i++) {
      final open = find.byType(AppUpgradeScreen).evaluate().isNotEmpty ||
          find.byType(AppUpgradeDialog).evaluate().isNotEmpty;
      if (!open) break;
      Navigator.of(ctx, rootNavigator: true).pop();
      await settle(tester);
    }
  }

  /// Each design paired with the constructor under test, so a failure names the
  /// design that regressed.
  final designs = <String, AppUpgradeTheme Function({UpdateViewType viewType})>{
    'cosmic': ({viewType = UpdateViewType.screen}) =>
        AppUpgradeTheme.cosmic(viewType: viewType),
    'rocketUp': ({viewType = UpdateViewType.screen}) =>
        AppUpgradeTheme.rocketUp(viewType: viewType),
    'superHero': ({viewType = UpdateViewType.screen}) =>
        AppUpgradeTheme.superHero(viewType: viewType),
  };

  for (final entry in designs.entries) {
    final name = entry.key;
    final build = entry.value;

    group(name, () {
      test('defaults to the full screen', () {
        expect(build().viewType, UpdateViewType.screen);
      });

      test('carries its own dialogEntrance', () {
        // Never null: the dialog and the sheet read it, so a design that left
        // it unset would fall back to another design's motion.
        expect(build().dialogEntrance, isNotNull);
      });

      testWidgets('renders as a dialog', (tester) async {
        final ctx =
            await prompt(tester, build(viewType: UpdateViewType.dialog));

        expect(find.byType(AppUpgradeDialog), findsOneWidget);
        expect(find.byType(AppUpgradeScreen), findsNothing);

        await dismiss(tester, ctx);
      });

      testWidgets('renders as a sheet', (tester) async {
        final ctx = await prompt(tester, build(viewType: UpdateViewType.sheet));

        expect(find.byType(AppUpgradeSheet), findsOneWidget);
        expect(find.byType(AppUpgradeScreen), findsNothing);

        await dismiss(tester, ctx);
      });

      testWidgets('renders as a screen', (tester) async {
        final ctx = await prompt(tester, build());

        expect(find.byType(AppUpgradeScreen), findsOneWidget);

        await dismiss(tester, ctx);
      });
    });
  }

  test('copyWith still switches the view type on every design', () {
    for (final build in designs.values) {
      final asDialog = build().copyWith(viewType: UpdateViewType.dialog);
      expect(asDialog.viewType, UpdateViewType.dialog);
      // The design's own motion survives the switch.
      expect(asDialog.dialogEntrance, build().dialogEntrance);
    }
  });
}
