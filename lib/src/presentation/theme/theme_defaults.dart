import 'package:flutter/widgets.dart';

import 'package:app_upgrade/src/presentation/theme/update_section.dart';

/// Neutral values every design starts from — layout, not identity.
///
/// A design references these instead of repeating them, and overrides any it
/// disagrees with. Nothing here carries a color or an asset: those are what
/// makes a design *itself*, so they always live in the design's own file.
///
/// Internal: not exported from the package barrel.
final class ThemeDefaults {
  const ThemeDefaults._();

  /// Visual → badge → title → description → features → buttons.
  ///
  /// The order most designs want; a design that wants another sequence passes
  /// its own list.
  static const List<UpdateSection> order = [
    UpdateSection.visual,
    UpdateSection.badge,
    UpdateSection.title,
    UpdateSection.description,
    UpdateSection.features,
    UpdateSection.updateButton,
    UpdateSection.laterButton,
  ];

  static const EdgeInsetsGeometry contentPadding =
      EdgeInsets.symmetric(horizontal: 15);

  static const double sectionSpacing = 20;

  static const double featureSpacing = 10;

  static const CrossAxisAlignment alignment = CrossAxisAlignment.center;

  static const String fallbackDescription =
      'A new version is ready to install.';
}
