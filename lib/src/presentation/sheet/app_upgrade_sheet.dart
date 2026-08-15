import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/core/enums/update_view_type.dart';
import 'package:app_upgrade_checker/src/presentation/dialog/app_upgrade_dialog.dart';
import 'package:app_upgrade_checker/src/presentation/app_upgrade_theme.dart';

/// The built-in update card as a **bottom sheet** — [UpdateViewType.sheet].
///
/// The same card as [AppUpgradeDialog], anchored to the bottom edge with only
/// its top corners rounded and its padding clearing the home indicator. Every
/// visual decision lives in [AppUpgradeDialog]; this only positions it, so the
/// two can never drift apart.
///
/// Internal: presented by `AppUpgrade.showUpdateDialog`, which reads the
/// theme's `viewType`.
final class AppUpgradeSheet extends StatelessWidget {
  /// Whether the update is mandatory. When `true` the "Later" action is hidden
  /// and the sheet cannot be dismissed.
  final bool isMandatory;

  /// Version label shown in the version pill.
  final String? versionName;

  /// Called when the user taps the update button.
  final FutureOr<void> Function() onUpdate;

  /// Called when the user taps "Later". `null` hides the action.
  final VoidCallback? onSkip;

  /// The complete look. Defaults to [AppUpgradeTheme.cosmic].
  final AppUpgradeTheme? theme;

  /// Release notes, used when the theme's `description.text` is unset.
  final String? releaseNotes;

  const AppUpgradeSheet({
    super.key,
    required this.isMandatory,
    required this.onUpdate,
    this.onSkip,
    this.versionName,
    this.theme,
    this.releaseNotes,
  });

  @override
  Widget build(BuildContext context) {
    return AppUpgradeDialog(
      isMandatory: isMandatory,
      versionName: versionName,
      releaseNotes: releaseNotes,
      onUpdate: onUpdate,
      onSkip: onSkip,
      theme: theme,
      isSheet: true,
    );
  }
}
