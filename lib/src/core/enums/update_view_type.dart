/// How the built-in update UI is presented.
///
/// Set it on the theme; [AppUpgrade.showUpdateDialog] reads it and picks the
/// matching presentation:
///
/// ```dart
/// AppUpgrade.checkAndPrompt(
///   context,
///   theme: AppUpgradeTheme.cosmic(viewType: UpdateViewType.dialog),
/// );
/// ```
///
/// All three render the **same** blocks from the same theme — the artwork, the
/// badge, the headline, the description, the feature row and the buttons, in
/// the theme's own order, honouring every `show*` flag. What changes is the
/// container around them.
enum UpdateViewType {
  /// A full-screen page. The default, and what every release before view types
  /// existed did.
  ///
  /// Uses the theme's `entrance`.
  screen,

  /// A centred dialog over the current page: the artwork on the background
  /// above, the text and the buttons in a rounded card below.
  ///
  /// Uses the theme's `dialogEntrance`.
  dialog,

  /// The same card as [dialog], anchored to the bottom edge with only its top
  /// corners rounded.
  ///
  /// Uses the theme's `dialogEntrance`.
  sheet,
}
