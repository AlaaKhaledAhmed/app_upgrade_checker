/// Which Google Play release track a build belongs to.
///
/// Purpose: passed to your backend (as `track`) so it looks up the version on
/// the correct track. The public Play scrape ignores this — it only ever sees
/// the production version.
enum TrackType {
  /// The live track served to the general public.
  production,

  /// The earliest, most restricted internal test track.
  alpha,

  /// A wider pre-release test track, typically for closed/open testing.
  beta,
}
