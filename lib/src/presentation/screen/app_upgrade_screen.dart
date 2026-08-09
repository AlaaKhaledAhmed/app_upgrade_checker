import 'dart:async';

import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/core/extensions/context_extensions.dart';
import 'package:app_upgrade_checker/src/presentation/app_upgrade_theme.dart';
import 'package:app_upgrade_checker/src/presentation/shared/update_content.dart';
import 'package:app_upgrade_checker/src/presentation/screen/entrance_animator.dart';
import 'package:app_upgrade_checker/src/presentation/shared/update_blocks.dart';

/// The built-in update screen. Use it directly or let
/// `AppUpgrade.showUpdateDialog` present it for you.
///
/// The screen owns no styling of its own: it renders the blocks listed in
/// [AppUpgradeTheme.order], in that order, using the colors, texts and assets
/// the theme carries. So a new design is a new [AppUpgradeTheme] — never a
/// change here, and never a subclass (the class is `final` on purpose).
///
/// ```dart
/// AppUpgradeScreen(
///   isMandatory: false,
///   onUpdate: () => AppUpgrade.openStore(url),
///   onSkip: () => Navigator.of(context).maybePop(),
///   theme: AppUpgradeTheme.cosmic().copyWith(showFeatures: false),
/// );
/// ```
final class AppUpgradeScreen extends StatelessWidget {
  /// Whether the update is mandatory. Normally comes from the library's
  /// decision (`UpdateAvailable.isForceUpdate`). When `true`, the "Later"
  /// action is hidden and back-dismissal is blocked.
  final bool isMandatory;

  /// Version label shown in the version pill (e.g. `"3.5.0"`). The pill also
  /// needs [AppUpgradeTheme.showVersion] to be `true`.
  final String? versionName;

  /// Called when the user taps the update button — wire this to open the store.
  final FutureOr<void> Function() onUpdate;

  /// Called when the user taps "Later". Ignored when [isMandatory] is `true`;
  /// pass `null` to hide the action entirely.
  final VoidCallback? onSkip;

  /// The complete look of the screen. Defaults to
  /// [AppUpgradeTheme.cosmic].
  final AppUpgradeTheme? theme;

  /// Release notes from the store or your backend, used when the theme's
  /// `description.text` is not set.
  final String? releaseNotes;

  const AppUpgradeScreen({
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
    final t = theme ?? AppUpgradeTheme.cosmic();

    final column = Column(
      crossAxisAlignment: t.alignment,
      mainAxisSize: MainAxisSize.min,
      children: _sections(context, t),
    );

    // Split into two layers so the entrance can move them at different rates —
    // that difference is what makes the artwork look like it is pulling the page.
    final backdrop = DecoratedBox(
      decoration: UpdateBlocks.background(t.background),
      child: const SizedBox.expand(),
    );

    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: t.contentPadding,
        child: t.scrollable ? SingleChildScrollView(child: column) : column,
      ),
    );

    final scaffold = Scaffold(
      backgroundColor: Colors.transparent,
      body: EntranceAnimator(
        entrance: t.entrance,
        backdrop: backdrop,
        content: content,
      ),
    );

    return PopScope(
      // A mandatory update cannot be dismissed with the system back gesture.
      canPop: !isMandatory,
      child: t.textDirection == null
          ? scaffold
          // Lets a design read right-to-left even in an app with no RTL locale.
          : Directionality(textDirection: t.textDirection!, child: scaffold),
    );
  }

  /// Builds the blocks named in [AppUpgradeTheme.order], skipping the ones
  /// switched off, and inserting [AppUpgradeTheme.sectionSpacing] between the
  /// ones that survive.
  ///
  /// The blocks themselves come from [UpdateContent], which the dialog and the
  /// sheet share — so a theme renders the same content whichever container
  /// presents it.
  List<Widget> _sections(BuildContext context, AppUpgradeTheme t) {
    final widgets = UpdateContent(
      isMandatory: isMandatory,
      versionName: versionName,
      releaseNotes: releaseNotes,
      onUpdate: onUpdate,
      onSkip: onSkip,
      theme: t,
    ).sections(context);

    // Keeps the last block clear of the home indicator / nav bar.
    if (widgets.isNotEmpty) {
      widgets.add(SizedBox(height: context.bottom + t.sectionSpacing));
    }
    return widgets;
  }
}
