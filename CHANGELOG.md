## 1.0.1

Documentation only — no API or behaviour changes.

* Fix the screenshots on the pub.dev package page. They were embedded with
  paths relative to the repository, which pub.dev resolves against the
  `repository:` URL through its image proxy; the repository was renamed after
  1.0.0 was published, so those paths no longer pointed anywhere. They are now
  absolute URLs, which the rename cannot break again.
* Reorder the feature table in the README so the built-in localization is
  listed second, and the "no backend needed" note last.

## 1.0.0

Initial release.

* Check for a newer app version and prompt the user to update.
* Two update sources per platform:
  * `PlayStoreSource` / `AppStoreSource` — check the public store directly from
    the device (Play listing scrape / Apple iTunes Lookup). No backend.
  * `CustomSource(url, headers, fallbackStoreUrl)` — GET a URL you control (a
    static JSON file *or* your backend), returning the `AppUpdateData` contract.
    Covers private/internal distribution and non-Google stores.
* `AppConfig(android:, ios:)` — platforms configured independently; a `null`
  platform defaults to its store check.
* Entry points: `AppUpgrade.checkUpdate({config})` for full control, or
  `AppUpgrade.checkAndPrompt(context, {config, builder, theme})` to check and
  show the prompt in one call.
* `UpdateCheckResult` sealed type: `UpdateAvailable` / `NoUpdate` /
  `UpdateCheckError`.
* Force-update handling: `minSupportedVersionCode` (custom source) or
  `ForcePolicy` (auto / always / never) for the store path.
* Built-in `AppUpgradeScreen` (`final`) with three themeable designs —
  `AppUpgradeTheme.cosmic()` (default), `.rocketUp()`, `.superHero()` — or
  replaceable with your own widget via `builder`.
  * Every text, color, gradient, asset and the vertical block order is a theme
    value: `UpdateTitle`, `UpdateBackground`, `UpdateVisual`, `UpdateFeature`,
    `UpdateBadgeStyle`, `UpdateButtonStyle`, `LaterButtonStyle`,
    `UpdateVersionStyle`, `UpdateTextStyle`, plus `order` and `show*` flags.
  * `UpdateEntrance` — how the screen arrives (`rocketPull`, `warpIn`,
    `liftoff`, `descend`, `slideUp`, `fade`, `none`), and `UpdatePulse` for the
    button glow. Both honour the platform's reduce-motion setting.
  * RTL support via `textDirection` on the theme or the title.
* `UpdatePreview` — force an outcome with no network and no published app, so
  the screen can be built before release. Warns in debug, throws in release.
* Overlapping `checkUpdate` calls share one in-flight request, and the screen is
  never stacked twice — a double tap can no longer open two copies.
  `AppUpgrade.isChecking` is exposed for spinners.
* Android and iOS only. Depends on `http`, `package_info_plus`, `url_launcher`.
