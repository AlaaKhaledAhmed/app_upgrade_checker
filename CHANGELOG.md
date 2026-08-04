## 1.0.1

* `viewType` — show the update as a full screen, a dialog or a bottom sheet.
* `dialogEntrance` — `popIn`, `slideUp`, `fade`, `none` for the dialog and sheet.
* `AppUpgrade.show` replaces `showUpdateDialog`, now deprecated.

## 1.0.0

Initial release.

* Store sources: `PlayStoreSource`, `AppStoreSource`.
* `CustomSource` — your own backend or a static JSON file.
* `AppConfig(android:, ios:)` — one source per platform.
* `AppUpgrade.checkUpdate()` and `AppUpgrade.checkAndPrompt()`.
* `UpdateCheckResult`: `UpdateAvailable` / `NoUpdate` / `UpdateCheckError`.
* Forced updates via `minSupportedVersionCode` or `ForcePolicy`.
* `AppUpgradeScreen` with three designs, 28 theme fields and a `builder`
  escape hatch.
* `UpdateEntrance` — seven entrance animations; `UpdatePulse` for the button.
* Seven languages with automatic RTL.
* `UpdatePreview` — see the screen before the app is published.
* Android and iOS only.
