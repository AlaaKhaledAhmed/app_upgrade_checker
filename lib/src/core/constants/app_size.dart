class AppSize {
  /// Standard text sizes
  static double heading1 = 24; // Scalable font size for main headings
  static double heading2 = 18; // Scalable font size for sub-headings
  static double bodyText = 16; // Scalable font size for body text
  static double captionText = 14; // Scalable font size for captions
  static double smallText =
      12; // Scalable font size for small text (e.g., footnotes)

  /// Standard padding and margin values
  static double defaultPadding =
      16; // Standard padding for most elements (e.g., containers)
  static double buttonPadding = 12; // Padding for buttons
  static double formPadding = 18; // Padding for form fields or inputs
  static double iconPadding = 8; // Padding around icons

  /// Standard button sizes
  static double buttonHeight = 50; // Height of buttons
  static double buttonWidth = 200; // Width of buttons
  static double buttonFontSize = 15; // Font size for button text

  /// Icon sizes
  static double iconSize = 24; // Standard icon size
  static double mediumIconSize = 20;
  static double smallIconSize = 16; // Small icon size for less prominent icons
  static double largeIconSize = 30;
  static double veryLargeIconSize = 50; // Large icon size for main icons

  /// AppBar sizes
  static double appBarHeight = 70; // Height of the AppBar
  static double appBarTitleSize = 20; // Font size for the AppBar title
  static double appBarIconSize = 24; // Icon size in the AppBar

  /// Input fields
  static double inputFieldHeight = 48; // Height of input fields
  static double inputFieldBorderRadius = 12; // Border radius for input fields

  /// Card and Container Sizes
  static double cardRadius = 12; // Border radius for cards and containers
  static double cardElevation = 4; // Elevation for cards

  /// Standard heights and widths
  static double screenHeight = 1; // Full screen height
  static double screenWidth = 1; // Full screen width
  static double contentHeight =
      200; // Height for content (e.g., a container or section)
  static double contentWidth = 300; // Width for content

  /// Miscellaneous sizes
  static double snackBarHeight = 60; // Height for SnackBar
  static double bottomNavBarHeight = 56; // Height of the Bottom Navigation Bar

  /// Border radius for rounded corners
  static double cardCornerRadius =
      16; // Scalable radius for cards or containers
  static double buttonRadius = 5; // Radius for buttons with rounded corners

  static bool get isLargeScreen => 1 > 600;

  static double scale(double base) {
    return isLargeScreen ? base * 1.3 : base;
  }
}
