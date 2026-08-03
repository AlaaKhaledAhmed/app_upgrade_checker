// Renders AppUpgradeScreen directly, with no update check, so a design can be
// eyeballed on a device. Run with:
//   flutter run -t lib/theme_preview.dart
import 'package:flutter/material.dart';
import 'package:app_upgrade/app_upgrade.dart';

void main() => runApp(const PreviewApp());

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AppUpgradeScreen(
        isMandatory: false,
        versionName: '3.5.0',
        // Swap this for any theme you want to eyeball.
        theme: AppUpgradeTheme.cosmic(),
        onUpdate: () {},
        onSkip: () {},
      ),
    );
  }
}
