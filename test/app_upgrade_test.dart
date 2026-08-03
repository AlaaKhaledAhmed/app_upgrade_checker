import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade/app_upgrade.dart';

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

  group('VersionComparator', () {
    test('detects a newer store version', () {
      expect(
        VersionComparator.hasUpdate(current: '3.1.0', store: '3.2.0'),
        isTrue,
      );
    });

    test('no update when equal', () {
      expect(
        VersionComparator.hasUpdate(current: '3.2.0', store: '3.2.0'),
        isFalse,
      );
    });

    test('no update when store is older', () {
      expect(
        VersionComparator.hasUpdate(current: '3.2.0', store: '3.1.9'),
        isFalse,
      );
    });

    test('treats missing trailing segments as zero', () {
      expect(VersionComparator.compare('3.2', '3.2.0'), 0);
      expect(
          VersionComparator.hasUpdate(current: '3.2', store: '3.2.1'), isTrue);
    });

    test('ignores pre-release / build metadata suffix', () {
      expect(VersionComparator.compare('3.2.0-beta+7', '3.2.0'), 0);
    });

    test('does not signal update on unparseable input', () {
      expect(VersionComparator.hasUpdate(current: '', store: 'abc'), isFalse);
    });

    test('compares numerically, not lexically (10 > 9)', () {
      expect(VersionComparator.hasUpdate(current: '1.9.0', store: '1.10.0'),
          isTrue);
    });
  });

  group('VersionComparator.isMajorBump', () {
    test('true when the first segment increases', () {
      expect(
        VersionComparator.isMajorBump(current: '3.4.1', store: '4.0.0'),
        isTrue,
      );
    });

    test('false for a minor/patch bump', () {
      expect(
        VersionComparator.isMajorBump(current: '3.4.1', store: '3.5.0'),
        isFalse,
      );
      expect(
        VersionComparator.isMajorBump(current: '3.4.1', store: '3.4.2'),
        isFalse,
      );
    });

    test('false when store is not newer', () {
      expect(
        VersionComparator.isMajorBump(current: '4.0.0', store: '3.9.9'),
        isFalse,
      );
    });
  });

  group('AppUpdateData.fromJson', () {
    test('coerces string/num/bool fields defensively', () {
      final data = AppUpdateData.fromJson({
        'versionName': '2.0.0',
        'versionCode': '42',
        'hasUpdate': 'true',
        'isForceUpdate': 1,
        'storeUrl': 'https://example.com',
      });
      expect(data.versionName, '2.0.0');
      expect(data.versionCode, 42);
      expect(data.hasUpdate, isTrue);
      expect(data.isForceUpdate, isTrue);
    });

    test('parses latestVersionCode / minSupportedVersionCode', () {
      final data = AppUpdateData.fromJson({
        'latestVersionCode': 55,
        'minSupportedVersionCode': '50',
      });
      expect(data.latestVersionCode, 55);
      expect(data.minSupportedVersionCode, 50);
    });
  });

  group('concurrent checks', () {
    // A check takes a network round trip, during which the UI has not changed —
    // so a user taps again. Both taps must share one result, or each one ends by
    // pushing the update screen and two stack up.
    test('overlapping calls share a single in-flight check', () async {
      final preview = UpdatePreview.optional(
        delay: const Duration(milliseconds: 300),
      );

      expect(AppUpgrade.isChecking, isFalse);

      final first = AppUpgrade.checkUpdate(preview: preview);
      final second = AppUpgrade.checkUpdate(preview: preview);

      expect(AppUpgrade.isChecking, isTrue);

      final results = await Future.wait([first, second]);

      // The same object, not merely equal ones — proof only one check ran.
      expect(results[0], same(results[1]));
      expect(results[0], isA<UpdateAvailable>());

      // The lock releases, so a later check still works.
      expect(AppUpgrade.isChecking, isFalse);
    });

    test('a later check runs normally after the first settles', () async {
      const preview = UpdatePreview.upToDate(delay: Duration.zero);

      final first = await AppUpgrade.checkUpdate(preview: preview);
      final second = await AppUpgrade.checkUpdate(preview: preview);

      expect(first, isA<NoUpdate>());
      expect(second, isA<NoUpdate>());
      // Sequential calls are independent, unlike overlapping ones.
      expect(first, isNot(same(second)));
    });

    test('the lock releases even when the check fails', () async {
      const preview = UpdatePreview.failure(delay: Duration.zero);

      final result = await AppUpgrade.checkUpdate(preview: preview);

      expect(result, isA<UpdateCheckError>());
      expect(AppUpgrade.isChecking, isFalse);
    });
  });

  group('UpdatePreview', () {
    test('optional reports a dismissible update', () async {
      final result = await AppUpgrade.checkUpdate(
        preview: UpdatePreview.optional(
          versionName: '7.7.7',
          delay: Duration.zero,
        ),
      );

      expect(result, isA<UpdateAvailable>());
      final update = result as UpdateAvailable;
      expect(update.versionName, '7.7.7');
      expect(update.isForceUpdate, isFalse);
    });

    test('forced reports a mandatory update', () async {
      final result = await AppUpgrade.checkUpdate(
        preview: UpdatePreview.forced(delay: Duration.zero),
      );

      expect(result, isA<UpdateAvailable>());
      expect((result as UpdateAvailable).isForceUpdate, isTrue);
    });
  });

  group('theme fontFamily', () {
    /// Every resolved family on the screen, as the text layer sees it.
    Future<Set<String?>> familiesOf(
        WidgetTester tester, AppUpgradeTheme theme) async {
      await tester.pumpWidget(MaterialApp(
        home: AppUpgradeScreen(
          isMandatory: false,
          versionName: '9.9.9',
          theme: theme,
          onUpdate: () {},
        ),
      ));
      await tester.pump(const Duration(seconds: 1));

      final families = <String?>{};
      for (final t in tester.widgetList<Text>(find.byType(Text))) {
        if (t.style != null) families.add(t.style!.fontFamily);
        // The headline renders as spans, so its family lives there.
        t.textSpan?.visitChildren((span) {
          if (span is TextSpan && span.style != null) {
            families.add(span.style!.fontFamily);
          }
          return true;
        });
      }
      return families;
    }

    testWidgets('a caller font is used verbatim, not scoped to the package',
        (tester) async {
      final families = await familiesOf(
          tester, AppUpgradeTheme.cosmic(fontFamily: 'Cairo'));

      // `package:` would rewrite this to `packages/app_upgrade/Cairo`, which
      // resolves to nothing — the caller's font lives in the caller's pubspec.
      expect(families, contains('Cairo'));
      expect(
        families.any((f) => f?.startsWith('packages/') ?? false),
        isFalse,
        reason: 'a caller-supplied family must not be package-qualified',
      );
    });

    testWidgets('the bundled font is package-qualified when none is given',
        (tester) async {
      final families = await familiesOf(tester, AppUpgradeTheme.cosmic());

      // The fallback ships with this package, so it *must* stay qualified.
      expect(families, contains('packages/app_upgrade/IBMP'));
    });
  });

  group('prompting from an idle app', () {
    /// `checkAndPrompt` defers the push so a call from `initState` finds a
    /// Navigator. That wait must not apply when the tree is already idle: a
    /// post-frame callback only runs if a frame is produced, and an idle app
    /// schedules none — so an unconditional wait hangs the first press until
    /// something else happens to draw.
    testWidgets('a button press shows the screen without a second frame',
        (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const Scaffold(body: Text('home'));
        }),
      ));

      // The app is now idle, exactly as it is when a user taps a button.
      // Not awaited: checkAndPrompt only returns once the pushed screen is
      // popped, so what matters is that the push happens at all.
      unawaited(AppUpgrade.checkAndPrompt(
        ctx,
        preview: UpdatePreview.optional(delay: Duration.zero),
      ));

      // Bounded pumps, not pumpAndSettle: the screen's artwork loops forever.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Before the idle short-circuit this stayed absent: the deferred push
      // waited on a frame an idle app never produced, so the first press did
      // nothing and only a second tap (which schedules a frame) opened it.
      expect(find.byType(AppUpgradeScreen), findsOneWidget);

      // Close the route so the pending future can finish. The screen has no
      // back button of its own, so pop it directly.
      Navigator.of(ctx).pop();
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });

    testWidgets('a call from initState still finds a Navigator',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: _PromptOnInit(
          preview: UpdatePreview.optional(delay: Duration.zero),
        ),
      ));
      // Bounded pumps, not pumpAndSettle: the screen's artwork loops forever.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Pushing mid-build would have thrown instead of reaching the screen.
      expect(tester.takeException(), isNull);
      expect(find.byType(AppUpgradeScreen), findsOneWidget);
    });
  });

  group('title layout', () {
    /// The headline puts a plain part, a colored word and a sparkle on one
    /// line. Laid out as separate widgets each demands its full width, so the
    /// line runs off a narrow screen instead of wrapping.
    Future<void> pumpAt(
        WidgetTester tester, double width, AppUpgradeTheme theme) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        home: AppUpgradeScreen(
          isMandatory: false,
          versionName: '9.9.9',
          theme: theme,
          onUpdate: () {},
        ),
      ));
      await tester.pump(const Duration(seconds: 1));
    }

    testWidgets('the default headline fits a narrow screen', (tester) async {
      await pumpAt(tester, 320, AppUpgradeTheme.cosmic());
      expect(tester.takeException(), isNull);
    });

    testWidgets('a long headline wraps instead of overflowing', (tester) async {
      await pumpAt(
        tester,
        320,
        AppUpgradeTheme.cosmic(
          title: const UpdateTitle(
            firstLine: 'Ready for',
            secondLine: 'something considerably',
            highlight: 'better!',
            sparkle: '✦︎',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('every part of the headline still renders', (tester) async {
      await pumpAt(tester, 320, AppUpgradeTheme.cosmic());

      final rich = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere((t) => t.textSpan != null);
      final text = rich.textSpan!.toPlainText();

      expect(text, contains('something'));
      expect(text, contains('better!'));
    });
  });
}

/// Calls `checkAndPrompt` straight from `initState` — the case the deferred
/// push exists for, where the tree is still building and has no Navigator yet.
class _PromptOnInit extends StatefulWidget {
  const _PromptOnInit({required this.preview});

  final UpdatePreview preview;

  @override
  State<_PromptOnInit> createState() => _PromptOnInitState();
}

class _PromptOnInitState extends State<_PromptOnInit> {
  @override
  void initState() {
    super.initState();
    AppUpgrade.checkAndPrompt(context, preview: widget.preview);
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('home'));
}
