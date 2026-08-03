/// The vertical building blocks of the built-in update screen.
///
/// Every design uses the **same** blocks — what changes between designs is
/// their order, their colors and their content. A theme declares the order it
/// wants via [AppUpgradeTheme.order], and the screen renders the blocks in
/// exactly that sequence:
///
/// ```dart
/// AppUpgradeTheme.cosmic().copyWith(
///   order: const [
///     UpdateSection.visual,
///     UpdateSection.features,   // features moved above the title
///     UpdateSection.title,
///     UpdateSection.updateButton,
///   ],
/// );
/// ```
///
/// A block left out of the list is not rendered, so the order list doubles as a
/// coarse visibility switch. For per-block toggles that keep the order intact,
/// use the `show*` flags on [AppUpgradeTheme].
enum UpdateSection {
  /// The top artwork: Lottie animation, image or icon ([UpdateVisual]).
  visual,

  /// The small pill above the headline (e.g. `"✦ NEW UPDATE AVAILABLE"`).
  badge,

  /// The two-line headline with a highlighted last word ([UpdateTitle]).
  title,

  /// The version pill (e.g. `"v3.5.0"`).
  version,

  /// The body paragraph under the headline.
  description,

  /// The row of feature cards ([UpdateFeature]).
  features,

  /// The primary call-to-action.
  updateButton,

  /// The dismiss ("Later") action. Never rendered for a mandatory update.
  laterButton,
}
