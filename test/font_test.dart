import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade_checker/app_upgrade_checker.dart';

void main() {
  test('line height adapts to the font', () {
    const t = UpdateTitle();
    expect(t.firstLineHeightFor(hasCustomFont: false), 1.0);
    expect(t.firstLineHeightFor(hasCustomFont: true), 1.0); // your font
  });

  test('an explicit value always wins', () {
    const t = UpdateTitle(firstLineHeight: 0.8);
    expect(t.firstLineHeightFor(hasCustomFont: false), 0.8);
    expect(t.firstLineHeightFor(hasCustomFont: true), 0.8);
    expect(
        AppUpgradeTheme.cosmic(title: const UpdateTitle(firstLineHeight: 0.8))
            .title
            .firstLineHeight,
        0.8);
  });

  testWidgets('a custom font does not make the headline collide', (t) async {
    for (final font in [null, 'Cairo']) {
      await t.pumpWidget(MaterialApp(
        home: AppUpgradeScreen(
          isMandatory: false,
          onUpdate: () {},
          theme: AppUpgradeTheme.cosmic(fontFamily: font),
        ),
      ));
      await t.pump(const Duration(seconds: 1));
      final first = t.getRect(find.text('Ready for'));
      final second = t.getRect(find.byType(RichText).at(1));
      expect(first.bottom, lessThanOrEqualTo(second.top + 1),
          reason: 'font=$font overlaps by ${first.bottom - second.top}px');
    }
  });
}
