import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_upgrade_checker/app_upgrade_checker.dart';

void main() {
  test('badge: partial merges, replace does not', () {
    final m =
        AppUpgradeTheme.cosmic(badge: const UpdateBadgeStyle(text: 'NEW'));
    expect(m.badge.text, 'NEW');
    expect(m.badge.backgroundColor,
        CosmicDesign.badgeFor(ThemeLang.en).backgroundColor);
    expect(
        m.badge.borderColor, CosmicDesign.badgeFor(ThemeLang.en).borderColor);

    // Everything is mergeable now — there is no "ignore the design" mode.
    // To drop a design value, state the value you want instead.
    final r = AppUpgradeTheme.cosmic(
        badge: const UpdateBadgeStyle(text: 'NEW', borderWidth: 0));
    expect(r.badge.text, 'NEW');
    expect(r.badge.borderWidth, 0);
  });

  test('title: partial merges', () {
    final m =
        AppUpgradeTheme.cosmic(title: const UpdateTitle(firstLine: 'مرحبا'));
    expect(m.title.firstLine, 'مرحبا');
    expect(m.title.highlightColor,
        CosmicDesign.titleFor(ThemeLang.en).highlightColor);
    expect(m.title.fontSize, CosmicDesign.titleFor(ThemeLang.en).fontSize);
  });

  test('title.of still works and keeps design colors', () {
    final m = AppUpgradeTheme.cosmic(
        title: const UpdateTitle(
            firstLine: 'a', secondLine: 'b', highlight: 'c', sparkle: '✦︎'));
    expect(m.title.firstLine, 'a');
    expect(m.title.sparkle, '✦︎');
    expect(m.title.highlightColor,
        CosmicDesign.titleFor(ThemeLang.en).highlightColor);
  });

  test('description: partial merges', () {
    final m =
        AppUpgradeTheme.cosmic(description: const UpdateTextStyle(text: 'hi'));
    expect(m.description.text, 'hi');
    expect(m.description.color, CosmicDesign.description.color);
  });

  test('laterButton: partial merges', () {
    final m = AppUpgradeTheme.cosmic(
        laterButton: const LaterButtonStyle(text: 'ليس الآن'));
    expect(m.laterButton.text, 'ليس الآن');
    expect(m.laterButton.textColor,
        CosmicDesign.laterButtonFor(ThemeLang.en).textColor);
  });

  test('feature merge works standalone', () {
    const base = UpdateFeature(title: 'A', iconColor: Colors.red);
    const mine = UpdateFeature(title: 'B');
    expect(mine.merge(base).title, 'B');
    expect(mine.merge(base).iconColor, Colors.red);
    // stating a value overrides the design's
    expect(
        const UpdateFeature(title: 'B', iconColor: Colors.blue)
            .merge(base)
            .iconColor,
        Colors.blue);
  });

  test('untouched designs unchanged', () {
    for (final t in [
      AppUpgradeTheme.cosmic(),
      AppUpgradeTheme.rocketUp(),
      AppUpgradeTheme.superHero()
    ]) {
      expect(t.title.firstLine, isNotNull);
      expect(t.badge.text, isNotEmpty);
    }
  });

  test('isEmpty and label survive', () {
    expect(const UpdateTitle().isEmpty, isTrue);
    expect(
        const UpdateTitle(
                firstLine: 'a', secondLine: 'b', highlight: 'c', sparkle: '✦︎')
            .isEmpty,
        isFalse);
    expect(const UpdateBadgeStyle(prefix: '> ', text: 'X').label, '> X');
  });

  test('feature list keeps the design card border (reported bug)', () {
    final t = AppUpgradeTheme.cosmic(
      showFeatures: true,
      features: const [
        UpdateFeature(
          icon: Icons.rocket_launch_rounded,
          title: 'أسرع',
          subtitle: 'أداء أسرع',
          iconGradient: [Colors.blue, Colors.indigo],
        ),
      ],
    );
    expect(t.features.first.title, 'أسرع'); // mine
    expect(t.features.first.iconGradient, [Colors.blue, Colors.indigo]);
    expect(t.features.first.borderColor,
        CosmicDesign.featuresFor(ThemeLang.en).first.borderColor); // the frame
    expect(t.features.first.borderColor, isNotNull);
  });

  test('extra cards beyond the design are kept', () {
    final t = AppUpgradeTheme.cosmic(
      features: List.generate(5, (i) => UpdateFeature(title: 'c$i')),
    );
    expect(t.features.length, 5);
    expect(t.features.last.title, 'c4');
  });
}
