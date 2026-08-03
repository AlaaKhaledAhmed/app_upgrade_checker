import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade/app_upgrade.dart';

void main() {
  test('partial style keeps the design values', () {
    final t = AppUpgradeTheme.cosmic(
      updateButton: const UpdateButtonStyle(text: 'اشترِ الآن'),
    );
    expect(t.updateButton.text, 'اشترِ الآن'); // mine
    expect(t.updateButton.gradient, isNotNull); // Cosmic's
    expect(t.updateButton.gradient,
        CosmicDesign.updateButtonFor(ThemeLang.en).gradient);
    expect(t.updateButton.borderColor,
        CosmicDesign.updateButtonFor(ThemeLang.en).borderColor);
    expect(
        t.updateButton.icon, CosmicDesign.updateButtonFor(ThemeLang.en).icon);
  });

  test('untouched design is unchanged', () {
    final t = AppUpgradeTheme.cosmic();
    expect(
        t.updateButton.text, CosmicDesign.updateButtonFor(ThemeLang.en).text);
    expect(t.updateButton.gradient,
        CosmicDesign.updateButtonFor(ThemeLang.en).gradient);
  });

  test('defaults still resolve', () {
    const s = UpdateButtonStyle();
    expect(s.text, 'UPDATE NOW');
    expect(s.radius, 20);
    expect(s.textColor, Colors.white);
    expect(s.fontWeight, FontWeight.bold);
  });
}
