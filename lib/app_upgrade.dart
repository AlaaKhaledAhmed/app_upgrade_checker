/// AppUpgrade — check whether a newer version of the app is available, either
/// directly from the store (public apps) or via your backend (private/internal
/// distribution), then prompt the user to update.
///
/// This barrel exposes ONLY the public API. Everything under `src/` that is not
/// exported here is an internal implementation detail: it may change or be
/// removed in any release, so do not import it directly.
library;

// Entry point
export 'src/services/app_upgrade_service.dart' show AppUpgrade;

// Configuration the developer provides
export 'src/config/app_config.dart' show AppConfig;
export 'src/config/update_method.dart'
    show
        AndroidConfig,
        IosConfig,
        PlayStoreSource,
        AppStoreSource,
        CustomSource;

// Development only: forces an outcome with no network and no published app, so
// the screen can be built and previewed. Throws if it reaches a release build.
export 'src/config/update_preview.dart' show UpdatePreview;

// The result the developer inspects
export 'src/data/models/update_check_result.dart'
    show UpdateCheckResult, UpdateAvailable, NoUpdate, UpdateCheckError;
export 'src/data/models/app_update_data.dart' show AppUpdateData;

// Enums the developer selects / reads
export 'src/core/enums/track_type.dart' show TrackType;
export 'src/core/enums/app_error_state.dart' show AppErrorState;
export 'src/core/enums/force_policy.dart' show ForcePolicy;

// Optional helper for consumers doing their own version comparison
export 'src/services/version_comparator.dart' show VersionComparator;

// Optional built-in UI
export 'src/presentation/app_upgrade_screen.dart' show AppUpgradeScreen;

// The theme: one design per named constructor (`AppUpgradeTheme.cosmic()`,
// `.rocketUp()`, `.superHero()`), all sharing the same building blocks.
export 'src/presentation/app_upgrade_theme.dart' show AppUpgradeTheme;

// Each design's palette and blocks, so you can reuse a piece of one design
// while overriding another (e.g. keep RocketUp's gradient, swap its copy).
export 'src/presentation/theme/designs/cosmic_design.dart' show CosmicDesign;
export 'src/presentation/theme/designs/rocket_up_design.dart'
    show RocketUpDesign;
export 'src/presentation/theme/designs/super_hero_design.dart'
    show SuperHeroDesign;

// The pieces a theme is made of — pass these to customize any block.
export 'src/presentation/theme/theme_lang.dart' show ThemeLang, ThemeStrings;
export 'src/presentation/theme/update_section.dart' show UpdateSection;

// Motion: how the screen arrives, and the glow that keeps the eye on the button.
export 'src/presentation/theme/update_entrance.dart'
    show
        UpdateEntrance,
        RocketPullEntrance,
        WarpInEntrance,
        LiftoffEntrance,
        DescendEntrance,
        SlideUpEntrance,
        FadeEntrance,
        NoEntrance;
export 'src/presentation/theme/update_pulse.dart' show UpdatePulse;
export 'src/presentation/theme/update_title.dart' show UpdateTitle;
export 'src/presentation/theme/update_feature.dart' show UpdateFeature;
export 'src/presentation/theme/update_badge_style.dart'
    show UpdateBadgeStyle, UpdateTextStyle, UpdateVersionStyle;
export 'src/presentation/theme/update_button_style.dart'
    show UpdateButtonStyle, LaterButtonStyle;
export 'src/presentation/theme/update_background.dart'
    show
        UpdateBackground,
        SolidBackground,
        GradientBackground,
        AssetBackground,
        NetworkBackground,
        NoBackground;
export 'src/presentation/theme/update_visual.dart'
    show
        UpdateVisual,
        LottieVisual,
        AssetVisual,
        NetworkVisual,
        IconVisual,
        CustomVisual;
