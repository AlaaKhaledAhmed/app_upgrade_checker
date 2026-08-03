import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade_checker/app_upgrade_checker.dart';

void main() {
  test('lang translates every default string', () {
    final ar = AppUpgradeTheme.cosmic(lang: ThemeLang.ar, showBadge: true);
    expect(ar.badge.text, 'يتوفر تحديث جديد');
    expect(ar.title.firstLine, 'هل أنت مستعد');
    expect(ar.updateButton.text, 'حدّث الآن');
    expect(ar.laterButton.text, 'لاحقًا');
    expect(ar.features.first.title, 'أسرع');
    expect(ar.fallbackDescription, contains('حسّنّا'));
  });

  test('ar and ur flip to RTL automatically', () {
    expect(AppUpgradeTheme.cosmic(lang: ThemeLang.ar).textDirection,
        TextDirection.rtl);
    expect(AppUpgradeTheme.cosmic(lang: ThemeLang.ur).textDirection,
        TextDirection.rtl);
    expect(AppUpgradeTheme.cosmic(lang: ThemeLang.en).textDirection, isNull);
  });

  test('explicit textDirection wins over the language', () {
    final t = AppUpgradeTheme.cosmic(
        lang: ThemeLang.ar, textDirection: TextDirection.ltr);
    expect(t.textDirection, TextDirection.ltr);
  });

  test('your own text always wins over the translation', () {
    final t = AppUpgradeTheme.cosmic(
      lang: ThemeLang.ar,
      updateButton: const UpdateButtonStyle(text: 'MY LABEL'),
    );
    expect(t.updateButton.text, 'MY LABEL');
    expect(t.laterButton.text, 'لاحقًا'); // untouched -> translated
    expect(t.updateButton.gradient, isNotNull); // merge still works
  });

  test('every language is complete', () {
    for (final l in ThemeLang.values) {
      final s = ThemeStrings.of(l);
      expect(s.badge, isNotEmpty, reason: '${l.code} badge');
      expect(s.featureTitles.length, 3, reason: '${l.code} titles');
      expect(s.featureSubtitles.length, 3, reason: '${l.code} subtitles');
      expect(s.updateButton, isNotEmpty, reason: '${l.code} button');
      // and it works end-to-end on all three designs
      for (final t in [
        AppUpgradeTheme.cosmic(lang: l),
        AppUpgradeTheme.rocketUp(lang: l),
        AppUpgradeTheme.superHero(lang: l),
      ]) {
        expect(t.title.firstLine, s.titleFirst);
        expect(t.features.length, 3);
      }
    }
  });

  test('unset lang falls back to a supported language', () {
    expect(ThemeLang.values.contains(ThemeLang.device), isTrue);
    expect(AppUpgradeTheme.cosmic().title.firstLine, isNotEmpty);
  });
}
