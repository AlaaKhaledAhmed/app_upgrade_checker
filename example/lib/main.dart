import 'package:flutter/material.dart';
import 'package:app_upgrade_checker/app_upgrade_checker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App Upgrade Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: const HomePage(),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PREVIEW vs REAL
//
// A store lookup reads a *published* listing, so it cannot work while you are
// still building the app. That is what `preview:` is for: it forces an outcome
// offline, so the screen appears immediately.
//
// Every demo below passes `preview: _preview` so it always shows the screen.
// The last section is the exception — it runs a real check with no preview, and
// is where you put your own configuration.
//
// `preview` warns on every check in debug and THROWS in release builds, so it
// cannot ship by accident.
// ═════════════════════════════════════════════════════════════════════════════

/// Used by every demo except the last section: an optional update, after a beat
/// so any loading state you add is visible.
final _preview = UpdatePreview.optional(versionName: '9.9.9');

/// Your real configuration — Android reads Google Play, iOS the App Store.
///
/// Used only by the last section. Both platforms are optional: omit one to use
/// its store with default settings. Replace `appleId` with your own, or swap in
/// a [CustomSource] pointing at your backend or a hosted JSON file.
const _realConfig = AppConfig(
  android: PlayStoreSource(
    forcePolicy: ForcePolicy.auto,
    country: 'sa',
  ),
  ios: AppStoreSource(
    appleId: '6782569320',
    country: 'sa',
    forcePolicy: ForcePolicy.auto,
  ),
);

// ═════════════════════════════════════════════════════════════════════════════
// THE OTHER METHOD: CustomSource — a URL you control
//
// The store sources above read a *published* listing. A CustomSource instead
// GETs a URL of yours and expects the library's JSON contract back:
//
//   { "latestVersionCode": 55,
//     "latestVersionName": "3.5.0",
//     "minSupportedVersionCode": 50,          // builds below this are forced
//     "storeUrl": "https://…",
//     "releaseNotes": "…" }
//
// A static file and a real backend are the same thing here — only the URL
// differs. Use it for private/internal builds, stores the direct path cannot
// read (AppGallery, Amazon, Galaxy Store), or when you want to decide the
// version and the force flag yourself.
//
// IMPORTANT: the request carries **no body and no query parameters**, and the
// installed version is never sent. The endpoint only answers "what is the
// latest version?" — the comparison happens on the device. So the response is
// identical for every caller and fully cacheable, and a plain static file is
// enough.
// ═════════════════════════════════════════════════════════════════════════════

/// A) No backend at all — a JSON file hosted anywhere (GitHub raw, S3, Pages).
///
/// Nothing is sent, so this can be `const` and needs no auth.
/// These are served by GitHub Pages from `docs/version/` in this repo, so they
/// are live — press the button and the screen appears.
///
/// The URL must point at the **file**, not at the page that displays it: a
/// `github.com/…/blob/…` link returns HTML, which fails to parse as JSON and
/// reads as "you are on the latest version".
const _jsonFileConfig = AppConfig(
  android: CustomSource(
    url: 'https://alaakhaledahmed.github.io/app_upgrade/version/android.json',
    // Opened by "Update now" when the JSON itself carries no `storeUrl`.
    fallbackStoreUrl: 'https://your.site/download',
  ),
  ios: CustomSource(
    url: 'https://alaakhaledahmed.github.io/app_upgrade/version/ios.json',
  ),
);

/// B) Your backend, with headers.
///
/// `headers` is a full `Map<String, String>` — not just a token. It is also the
/// *only* channel to the server, since nothing else about the device is sent.
/// Put anything the server needs to branch on here: a staged rollout, a
/// per-segment force, a beta channel.
///
/// Not `const`: the values are built at runtime.
AppConfig backendConfig({required String token, required String userSegment}) {
  final headers = <String, String>{
    'Authorization': 'Bearer $token',
    'X-User-Segment': userSegment,
    // Header values must be strings — convert numbers yourself.
    'X-Client': 'app_upgrade_checker-example',
  };

  return AppConfig(
    android: CustomSource(
      url: 'https://api.your-backend.com/app-version/android',
      headers: headers,
    ),
    ios: CustomSource(
      url: 'https://api.your-backend.com/app-version/ios',
    ),
  );
}

// ── Themes ───────────────────────────────────────────────────────────────────
// A design is a named constructor. `copyWith` tweaks it without retyping the
// rest, so these examples stay short.

/// The shipped designs as they come: artwork, headline, description, buttons.
/// The badge pill and the feature row are off by default — see below for how to
/// switch them on.
///
/// Cosmic needs no entry here: it is what you get when no theme is passed.
final _rocketUp = AppUpgradeTheme.rocketUp();
final _superHero = AppUpgradeTheme.superHero();

// ── Opting blocks in ─────────────────────────────────────────────────────────
// `showBadge` / `showFeatures` default to false. Turning one on brings in the
// design's own content — no need to supply a badge or a feature list yourself.

/// Blocks opted in: the design supplies the badge text and the cards itself.
final _cosmicFull = AppUpgradeTheme.cosmic(
  showBadge: true,
  showFeatures: true,
);

// ── Motion ───────────────────────────────────────────────────────────────────
// `entrance` picks how the screen arrives; each design ships its own (Cosmic
// warps in, RocketUp is pulled up, SuperHero descends). Every variant stays
// under 600ms and falls back to a fade when the OS asks for reduced motion.

/// Every entrance on the same design, so the only difference is the motion.
const _entrances = <String, UpdateEntrance>{
  'rocketPull — pulled up from below': UpdateEntrance.rocketPull(),
  'warpIn — settles out of a jump': UpdateEntrance.warpIn(),
  'liftoff — the backdrop sinks': UpdateEntrance.liftoff(),
  'descend — arrives from above': UpdateEntrance.descend(),
  'slideUp — plain slide': UpdateEntrance.slideUp(),
  'none — no entrance': UpdateEntrance.none(),
  'rocketPull — faster, more parallax': UpdateEntrance.rocketPull(
    duration: Duration(milliseconds: 450),
    parallax: 0.5,
  ),
};

/// The button's breathing glow: retuned, and switched off.
const _pulses = <String, UpdatePulse?>{
  'Stronger button glow': UpdatePulse(
    period: Duration(milliseconds: 1200),
    maxBlur: 34,
    maxOpacity: 0.7,
  ),
  'No button glow': null,
};

/// Same blocks, different order and different assets: the feature row moves
/// above the headline, and the version pill is switched on.
final _reordered = AppUpgradeTheme.cosmic(
  order: const [
    UpdateSection.visual,
    UpdateSection.features,
    UpdateSection.title,
    UpdateSection.version,
    UpdateSection.description,
    UpdateSection.updateButton,
    UpdateSection.laterButton,
  ],
  // The row has to be opted in for the reordering to be visible at all.
  showFeatures: true,
  showVersion: true,
  visual: const UpdateVisual.icon(
    Icons.system_update_rounded,
    circleGradient: [Colors.deepPurple, Colors.blueAccent],
  ),
  background: const UpdateBackground.solid(Color(0xFF120B29)),
);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ── Previewed demos: the screen always appears ──
  //
  // These pass a preview and no config, because there is nothing to check —
  // the outcome is forced. That keeps each demo about the *screen*.

  /// The shipped look, with no arguments beyond the preview.
  Future<void> _promptDefault(BuildContext context) =>
      AppUpgrade.checkAndPrompt(context, preview: _preview);

  /// A specific theme — how every design and variant below is shown.
  Future<void> _promptThemed(BuildContext context, AppUpgradeTheme theme) =>
      AppUpgrade.checkAndPrompt(
        context,
        preview: _preview,
        theme: theme,
      );

  // ── The real thing: no preview ──

  /// Runs an actual store lookup using [_realConfig].
  ///
  /// Expect "check failed" until your app is actually published — that is the
  /// store telling you there is no listing to read yet, not a library problem.
  Future<void> _realCheck(BuildContext context) async {
    final result = await AppUpgrade.checkUpdate(
        config: _realConfig, preview: UpdatePreview.optional());
    if (!context.mounted) return;
    switch (result) {
      case UpdateAvailable(:final versionName):
        _snack(context, 'Real update found: $versionName');
        await AppUpgrade.showUpdateDialog(context, result);
      case NoUpdate():
        _snack(context, 'Real check: you are on the latest version');
      case UpdateCheckError(:final message):
        _snack(context, 'Real check failed — $message');
    }
  }

  /// Runs a real check against a [CustomSource] — a hosted JSON file or your
  /// backend. Identical to [_realCheck] except for the config it is handed:
  /// once a config is built, every method behaves the same from here on.
  ///
  /// Expect "check failed" for the placeholder URLs above until you point them
  /// at something that actually serves the JSON contract.
  Future<void> _customSourceCheck(
    BuildContext context,
    AppConfig config,
    String label,
  ) async {
    final result = await AppUpgrade.checkUpdate(config: config);
    if (!context.mounted) return;
    switch (result) {
      case UpdateAvailable():
        await AppUpgrade.showUpdateDialog(context, result);
        break;
      case NoUpdate():
        _snack(context, '$label: you are on the latest version');
        break;
      case UpdateCheckError(:final message):
        _snack(context, '$label failed — $message');
        break;
    }
  }

  void _snack(BuildContext context, String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AppUpgrade Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. The designs ────────────────────────────────────────────────
          const _SectionLabel(
            '1 · Designs',
            'Three looks from the same building blocks.',
          ),
          FilledButton(
            onPressed: () => _promptDefault(context),
            child: const Text('Cosmic'),
          ),
          FilledButton(
            onPressed: () => _promptThemed(context, _rocketUp),
            child: const Text('RocketUp'),
          ),
          FilledButton(
            onPressed: () => _promptThemed(context, _superHero),
            child: const Text('SuperHero'),
          ),

          // ── 2. Content ────────────────────────────────────────────────────
          const _SectionLabel(
            '2 · Content',
            'Blocks are off until you ask for them. Whatever you set is yours; '
                'the rest keeps the design.',
          ),
          FilledButton(
            onPressed: () => _promptThemed(context, _cosmicFull),
            child: const Text('Badge + features'),
          ),
          // `lang` translates every default text. Also: en, ur, es, hi, fr, id
          // — and ar/ur flip the screen to RTL on their own.
          FilledButton(
            onPressed: () => _promptThemed(
                context,
                AppUpgradeTheme.cosmic(
                    lang: ThemeLang.ar, showBadge: true, showFeatures: true)),
            child: const Text('Arabic (lang: ThemeLang.ar)'),
          ),
          FilledButton(
            onPressed: () => _promptThemed(context, _reordered),
            child: const Text('Reordered + version pill'),
          ),

          // ── 3. Motion ─────────────────────────────────────────────────────
          const _SectionLabel(
            '3 · Motion',
            'How the screen arrives, and the glow on the button.',
          ),
          for (final e in _entrances.entries)
            FilledButton(
              onPressed: () => _promptThemed(
                  context, AppUpgradeTheme.cosmic(entrance: e.value)),
              child: Text(e.key),
            ),
          for (final p in _pulses.entries)
            FilledButton(
              onPressed: () => _promptThemed(
                  context,
                  AppUpgradeTheme.cosmic()
                      .copyWith(pulse: p.value, noPulse: p.value == null)),
              child: Text(p.key),
            ),

          // ── 4. The real check ─────────────────────────────────────────────
          const _SectionLabel(
            '4 · Real check',
            'No preview: a live store lookup using your own AppConfig. Expect '
                'it to fail until the app is actually published.',
          ),
          OutlinedButton(
            onPressed: () => _realCheck(context),
            child: const Text('Run a real store check'),
          ),

          // ── 5. The other method: CustomSource ─────────────────────────────
          const _SectionLabel(
            '5 · CustomSource — a URL you control',
            'The alternative to a store lookup: the library GETs your URL and '
                'reads the JSON contract from it. Nothing about the device is '
                'sent, so a static file works exactly like a backend. These '
                'point at placeholder URLs — swap in your own to see them pass.',
          ),
          OutlinedButton(
            onPressed: () => _customSourceCheck(
              context,
              _jsonFileConfig,
              'Hosted JSON file',
            ),
            child: const Text('Check a hosted JSON file (no backend)'),
          ),
          OutlinedButton(
            onPressed: () => _customSourceCheck(
              context,
              // Built at runtime: headers are the only channel to the server,
              // so this is where a token or a rollout segment goes.
              backendConfig(token: 'demo-token', userSegment: 'beta'),
              'Backend',
            ),
            child: const Text('Check a backend (with headers)'),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, [this.subtitle]);
  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
