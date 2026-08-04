import 'package:flutter/material.dart';

import 'package:app_upgrade_checker/src/core/enums/update_view_type.dart';
import 'package:app_upgrade_checker/src/core/extensions/context_extensions.dart';
import 'package:app_upgrade_checker/src/presentation/app_upgrade_theme.dart';
import 'package:app_upgrade_checker/src/presentation/theme/theme_defaults.dart';
import 'package:app_upgrade_checker/src/presentation/theme/update_section.dart';
import 'package:app_upgrade_checker/src/presentation/shared/update_content.dart';
import 'package:app_upgrade_checker/src/presentation/dialog/dialog_entrance_animator.dart';
import 'package:app_upgrade_checker/src/presentation/shared/update_blocks.dart';

/// The built-in update **card** — the body of both [UpdateViewType.dialog] and
/// [UpdateViewType.sheet].
///
/// It renders the same blocks as the full screen, from the same theme, in the
/// theme's own order and honouring every `show*` flag. Two things differ:
///
/// - the artwork is pulled out of the column into a header strip, so it sits on
///   the background above the text no matter where `order` puts it;
/// - the whole thing is bounded to [maxHeightFactor] of the screen and scrolls
///   inside that, so a long release note or a large system font cannot push it
///   past the viewport.
///
/// The card carries no colors of its own: the header and the body both paint
/// the theme's own `background`, so a design's palette arrives for free.
///
/// Internal: presented by `AppUpgrade.showUpdateDialog`, which reads the
/// theme's `viewType`.
final class AppUpgradeDialog extends StatelessWidget {
  /// Whether the update is mandatory. When `true` the "Later" action is hidden
  /// and the card cannot be dismissed.
  final bool isMandatory;

  /// Version label shown in the version pill.
  final String? versionName;

  /// Called when the user taps the update button.
  final VoidCallback onUpdate;

  /// Called when the user taps "Later". `null` hides the action.
  final VoidCallback? onSkip;

  /// The complete look. Defaults to [AppUpgradeTheme.cosmic].
  final AppUpgradeTheme? theme;

  /// Release notes, used when the theme's `description.text` is unset.
  final String? releaseNotes;

  /// Anchors the card to the bottom edge and rounds only its top corners.
  final bool isSheet;

  /// The tallest the card may get, as a fraction of the screen. It scrolls
  /// inside this, so the cap is a guard against overflow rather than a target —
  /// with the shipped blocks the card lands well under it.
  static const double maxHeightFactor = 0.85;

  /// Corner radius of the card.
  static const double cornerRadius = 28;

  /// Height of the artwork strip, as a fraction of the screen.
  static const double headerHeightFactor = 0.17;

  /// Caps the body paragraph inside the card, unless the theme sets its own
  /// `maxLines`. A long release note is the one block that can fill the card by
  /// itself; the full screen has no such limit because it scrolls freely.
  static const int descriptionMaxLines = 4;

  /// Gap between blocks inside the card.
  ///
  /// The theme's `sectionSpacing` (20) is tuned for a full screen, where the
  /// blocks have a whole viewport to breathe in; at card width the same gap
  /// reads as loose. A caller who sets `sectionSpacing` themselves overrides
  /// this.
  static const double blockSpacing = 14;

  const AppUpgradeDialog({
    super.key,
    required this.isMandatory,
    required this.onUpdate,
    this.onSkip,
    this.versionName,
    this.theme,
    this.releaseNotes,
    this.isSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme ?? AppUpgradeTheme.cosmic();

    final content = UpdateContent(
      isMandatory: isMandatory,
      versionName: versionName,
      releaseNotes: releaseNotes,
      onUpdate: onUpdate,
      onSkip: onSkip,
      theme: t,
      descriptionMaxLines: descriptionMaxLines,
    );

    // The artwork leads, on the background; everything else fills the body.
    final header = content.build(context, UpdateSection.visual);
    final body = content.sections(
      context,
      skip: const {UpdateSection.visual},
      // Only when the caller left the theme's own value alone.
      spacing: t.sectionSpacing == ThemeDefaults.sectionSpacing
          ? blockSpacing
          : t.sectionSpacing,
    );

    final radius = isSheet
        ? const BorderRadius.vertical(top: Radius.circular(cornerRadius))
        : BorderRadius.circular(cornerRadius);

    final card = ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        // One background across header and body: the rounded corners are all
        // that separates the card from the barrier behind it.
        decoration: UpdateBlocks.background(t.background),
        // The blocks use InkWell for their ripples, which needs a Material
        // ancestor — the full screen gets one from its Scaffold, a card has to
        // bring its own. Transparent, so the theme's background shows through.
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null)
                SizedBox(
                  height: context.height * headerHeightFactor,
                  child: header,
                ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: _bodyPadding(context, t),
                    child: Column(
                      crossAxisAlignment: t.alignment,
                      mainAxisSize: MainAxisSize.min,
                      children: body,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final bounded = ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: context.height * maxHeightFactor,
        // Keeps the dialog from stretching edge to edge on a tablet.
        maxWidth: isSheet ? double.infinity : 460,
      ),
      child: card,
    );

    final animated = DialogEntranceAnimator(
      entrance: t.dialogEntrance,
      child: bounded,
    );

    final positioned = isSheet
        ? animated
        // A dialog sits centred, clear of the screen edges.
        : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: animated,
            ),
          );

    return PopScope(
      // A mandatory update cannot be dismissed with the system back gesture.
      canPop: !isMandatory,
      child: t.textDirection == null
          ? positioned
          // Lets a design read right-to-left even in an app with no RTL locale.
          : Directionality(textDirection: t.textDirection!, child: positioned),
    );
  }

  /// The theme's horizontal padding, plus vertical breathing room the full
  /// screen gets from its section spacing and safe area.
  ///
  /// A sheet also clears the home indicator, since it sits on the bottom edge.
  EdgeInsets _bodyPadding(BuildContext context, AppUpgradeTheme t) {
    final resolved = t.contentPadding
        .resolve(Directionality.maybeOf(context) ?? TextDirection.ltr);
    // The screen's 15 is tuned for full-bleed content; a card wants more.
    final horizontal = resolved.left < 20 ? 20.0 : resolved.left;

    return EdgeInsets.only(
      left: horizontal,
      right: horizontal,
      top: 24,
      bottom: 24 + (isSheet ? context.bottom : 0),
    );
  }
}
