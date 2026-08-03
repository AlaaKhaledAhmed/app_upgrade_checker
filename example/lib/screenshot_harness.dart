// Renders one design at a time for README screenshots, with no entrance
// animation so a capture is deterministic.
//
//   flutter run -t lib/screenshot_harness.dart --dart-define=DESIGN=cosmic
//
// DESIGN accepts: cosmic | rocketUp | superHero
import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/app_upgrade_checker.dart';

const _design = String.fromEnvironment('DESIGN', defaultValue: 'cosmic');

/// Screenshots should show the settled screen, and with the badge and feature
/// row on so the README conveys what each design can do.
AppUpgradeTheme _theme() {
  const settled = UpdateEntrance.none();
  return switch (_design) {
    'rocketUp' => AppUpgradeTheme.rocketUp(
        showBadge: true,
        showFeatures: true,
        entrance: settled,
      ),
    'superHero' => AppUpgradeTheme.superHero(
        showBadge: true,
        showFeatures: true,
        entrance: settled,
      ),
    _ => AppUpgradeTheme.cosmic(
        showBadge: true,
        showFeatures: true,
        entrance: settled,
      ),
  };
}

void main() => runApp(const HarnessApp());

class HarnessApp extends StatelessWidget {
  const HarnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppUpgradeScreen(
        isMandatory: false,
        onUpdate: () {},
        onSkip: () {},
        theme: _theme(),
      ),
    );
  }
}
