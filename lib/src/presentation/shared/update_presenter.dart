import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/core/enums/update_view_type.dart';
import 'package:app_upgrade_checker/src/presentation/dialog/app_upgrade_dialog.dart';
import 'package:app_upgrade_checker/src/presentation/screen/app_upgrade_screen.dart';
import 'package:app_upgrade_checker/src/presentation/sheet/app_upgrade_sheet.dart';
import 'package:app_upgrade_checker/src/presentation/app_upgrade_theme.dart';

/// Puts the built-in UI on screen in the form the theme's `viewType` names.
///
/// This is the only place that maps a [UpdateViewType] onto a way of presenting
/// it — a route push, a dialog route, a modal sheet — so adding a view type is a
/// change here and nowhere else. The service above it decides *whether* to
/// prompt and holds the "already prompting" lock; this decides *how* it looks.
///
/// Internal: not exported from the package barrel.
final class UpdatePresenter {
  const UpdatePresenter._();

  /// Shows [theme]'s view type and completes when the user dismisses it.
  static Future<void> show(
    BuildContext context, {
    required bool isMandatory,
    required FutureOr<void> Function() onUpdate,
    required AppUpgradeTheme? theme,
    String? versionName,
    String? releaseNotes,
    VoidCallback? onSkip,
  }) {
    final viewType = (theme ?? AppUpgradeTheme.cosmic()).viewType;

    switch (viewType) {
      case UpdateViewType.screen:
        return _pushScreen(
          context,
          AppUpgradeScreen(
            isMandatory: isMandatory,
            versionName: versionName,
            releaseNotes: releaseNotes,
            theme: theme,
            onUpdate: onUpdate,
            onSkip: onSkip,
          ),
        );

      case UpdateViewType.dialog:
        // showGeneralDialog rather than showDialog: the card plays its own
        // entrance (AppUpgradeTheme.dialogEntrance), and only this one lets the
        // route's transition be switched off so the two do not fight.
        return showGeneralDialog<void>(
          context: context,
          // A mandatory update cannot be tapped away.
          barrierDismissible: !isMandatory,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          barrierColor: Colors.black54,
          transitionDuration: Duration.zero,
          pageBuilder: (_, __, ___) => AppUpgradeDialog(
            isMandatory: isMandatory,
            versionName: versionName,
            releaseNotes: releaseNotes,
            theme: theme,
            onUpdate: onUpdate,
            onSkip: onSkip,
          ),
        );

      case UpdateViewType.sheet:
        return showModalBottomSheet<void>(
          context: context,
          isDismissible: !isMandatory,
          enableDrag: !isMandatory,
          // Lets the card size itself past half the screen; it caps its own
          // height and scrolls inside that.
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          // Flutter's own slide-up is kept here, unlike the dialog. A modal
          // sheet's route *positions* the sheet through that animation rather
          // than only fading it, so replacing it with a zero-duration
          // controller leaves the sheet parked off-screen — present in the tree
          // and never visible. The card's own DialogEntrance plays on top.
          builder: (_) => AppUpgradeSheet(
            isMandatory: isMandatory,
            versionName: versionName,
            releaseNotes: releaseNotes,
            theme: theme,
            onUpdate: onUpdate,
            onSkip: onSkip,
          ),
        );
    }
  }

  /// Pushes the full-screen variant on a transition-less route: the screen plays
  /// its own entrance (see [AppUpgradeTheme.entrance]), so the platform's push
  /// animation would fight it. The reverse transition still fades, so dismissing
  /// does not snap.
  static Future<void> _pushScreen(BuildContext context, Widget screen) {
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        fullscreenDialog: true,
        opaque: false,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, animation, secondary, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}
