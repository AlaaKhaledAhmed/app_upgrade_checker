import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade_checker/app_upgrade_checker.dart';

/// Covers update actions that complete *inside* the app: `onUpdate` may return a
/// Future, and the button owns the wait — it disables itself and shows a spinner
/// until that future settles.
///
/// Note: never `pumpAndSettle` here. The designs run an endless pulse-glow on
/// the button (and the spinner is endless too), so nothing on this screen ever
/// settles — the rest of the suite pumps fixed durations for the same reason.
const _label = 'Download';

Future<void> pump(
  WidgetTester tester, {
  required FutureOr<void> Function() onUpdate,
  bool showUpdateButton = true,
}) async {
  await tester.pumpWidget(MaterialApp(
    home: AppUpgradeScreen(
      isMandatory: true, // hides the "Later" action, so one button remains
      onUpdate: onUpdate,
      versionName: '3.5.0',
      theme: AppUpgradeTheme.cosmic(
        updateButton: const UpdateButtonStyle(text: _label),
      ).copyWith(showUpdateButton: showUpdateButton),
    ),
  ));
  await tester.pump(const Duration(seconds: 1)); // let the entrance finish
}

/// The update button specifically, rather than whichever `InkWell` comes first.
Finder get _button =>
    find.ancestor(of: find.text(_label), matching: find.byType(InkWell)).first;

Finder get _spinner => find.byType(CircularProgressIndicator);

void main() {
  group('asynchronous onUpdate', () {
    testWidgets('shows a spinner while the action is in flight', (t) async {
      final completer = Completer<void>();
      await pump(t, onUpdate: () => completer.future);

      expect(_spinner, findsNothing, reason: 'idle button has no spinner');

      await t.tap(_button);
      await t.pump();
      expect(_spinner, findsOneWidget, reason: 'spinner appears on tap');

      completer.complete();
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      expect(_spinner, findsNothing, reason: 'spinner clears when it settles');
    });

    testWidgets('a second tap while in flight does not re-run the action',
        (t) async {
      final completer = Completer<void>();
      var calls = 0;
      await pump(t, onUpdate: () {
        calls++;
        return completer.future;
      });

      await t.tap(_button);
      await t.pump();
      await t.tap(_button, warnIfMissed: false);
      await t.pump();

      expect(calls, 1, reason: 're-entrant taps must be ignored');

      completer.complete();
      await t.pump();
    });

    testWidgets('a failing action leaves the button usable again', (t) async {
      var calls = 0;
      await pump(t, onUpdate: () async {
        calls++;
        throw Exception('download failed');
      });

      await t.tap(_button);
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));

      expect(t.takeException(), isNotNull, reason: 'the error still surfaces');

      // The throw must not leave the button stuck spinning — otherwise a failed
      // download would trap the user with no way to retry.
      expect(_spinner, findsNothing);

      await t.tap(_button);
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      t.takeException();

      expect(calls, 2, reason: 'retry must work after a failure');
    });

    testWidgets('the label keeps its space so the button does not resize',
        (t) async {
      final completer = Completer<void>();
      await pump(t, onUpdate: () => completer.future);

      final before = t.getSize(_button);
      await t.tap(_button);
      await t.pump();
      final during = t.getSize(_button);

      expect(during, before, reason: 'spinner must not shift the layout');

      completer.complete();
      await t.pump();
    });
  });

  group('backwards compatibility', () {
    testWidgets('a synchronous callback never enters the busy state',
        (t) async {
      var calls = 0;
      await pump(t, onUpdate: () => calls++);

      await t.tap(_button);
      await t.pump();

      // Hand-off actions (open the store, then leave) must not flash a spinner.
      expect(_spinner, findsNothing);
      expect(calls, 1);
    });

    testWidgets('a sync callback can still be tapped repeatedly', (t) async {
      var calls = 0;
      await pump(t, onUpdate: () => calls++);

      await t.tap(_button);
      await t.pump();
      await t.tap(_button);
      await t.pump();

      expect(calls, 2, reason: 'the re-entrancy guard must not latch on sync');
    });
  });

  group('showUpdateButton', () {
    testWidgets('false renders no primary button', (t) async {
      await pump(t, onUpdate: () {}, showUpdateButton: false);
      expect(find.text(_label), findsNothing);
    });

    testWidgets('defaults to rendering the button', (t) async {
      await pump(t, onUpdate: () {});
      expect(find.text(_label), findsOneWidget);
    });
  });
}
