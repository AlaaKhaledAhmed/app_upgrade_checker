final class AppConstants {
  /// Default network timeout for update checks.
  static const Duration timeOut = Duration(seconds: 15);

  /// Apple's public lookup endpoint (no auth required).
  static const String iTunesLookup = 'https://itunes.apple.com/lookup';

  /// Play Store web listing base (used for the unofficial HTML fallback).
  static const String playStoreDetails =
      'https://play.google.com/store/apps/details';
}
