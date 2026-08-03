import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade/app_upgrade.dart';

Future<void> pump(WidgetTester tester, AppUpgradeTheme theme) =>
    tester.pumpWidget(MaterialApp(
      home: AppUpgradeScreen(
        isMandatory: false,
        onUpdate: () {},
        versionName: '3.5.0',
        theme: theme,
      ),
    ));

void main() {
  testWidgets('merged label renders', (t) async {
    await pump(
        t,
        AppUpgradeTheme.cosmic(
          updateButton: const UpdateButtonStyle(text: 'اشترِ الآن'),
        ));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('اشترِ الآن'), findsOneWidget);
  });

  testWidgets('an overridden label renders', (t) async {
    await pump(
        t,
        AppUpgradeTheme.cosmic(
          updateButton: const UpdateButtonStyle(
              text: 'GO', backgroundColor: Colors.green),
        ));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('GO'), findsOneWidget);
  });

  testWidgets('default design renders', (t) async {
    await pump(t, AppUpgradeTheme.cosmic());
    await t.pump(const Duration(seconds: 1));
    expect(find.text('UPDATE NOW'), findsOneWidget);
  });
}
