import 'dart:ui';

/// The language of the built-in screen's **default** texts.
///
/// Every design ships the same wording — a badge, a two-line headline, a
/// description, three feature cards and two buttons. [ThemeLang] decides which
/// language those defaults are written in:
///
/// ```dart
/// AppUpgradeTheme.cosmic(lang: ThemeLang.ar);
/// ```
///
/// Left unset, the device's language is used when it is one of the supported
/// ones, and English otherwise. Any text you set yourself always wins over the
/// translation — [ThemeLang] only supplies what you did not write.
///
/// [ar] and [ur] also flip the screen to right-to-left, unless you set
/// `textDirection` yourself.
enum ThemeLang {
  /// English — also the fallback for any unsupported device language.
  en('en'),

  /// Arabic. Right-to-left.
  ar('ar'),

  /// Urdu. Right-to-left.
  ur('ur'),

  /// Spanish.
  es('es'),

  /// Hindi.
  hi('hi'),

  /// French.
  fr('fr'),

  /// Indonesian.
  id('id');

  /// The ISO 639-1 code this language matches a device locale by.
  final String code;

  const ThemeLang(this.code);

  /// Whether this language reads right-to-left.
  bool get isRtl => this == ar || this == ur;

  /// The device's language when it is supported, [en] otherwise.
  ///
  /// Read from the platform rather than a [BuildContext], so a theme can be
  /// built as a `const`-like top-level value before any widget exists.
  static ThemeLang get device {
    final code = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    for (final lang in ThemeLang.values) {
      if (lang.code == code) return lang;
    }
    return ThemeLang.en;
  }
}

/// The default wording of the update screen, in one language.
///
/// The three designs share the same texts, so a translation is written once
/// here and serves all of them.
final class ThemeStrings {
  /// Badge pill above the headline.
  final String badge;

  /// Headline, first line.
  final String titleFirst;

  /// Headline, second line (before the highlighted word).
  final String titleSecond;

  /// The highlighted last word of the headline.
  final String titleHighlight;

  /// Body paragraph, used when neither the theme nor the response has text.
  final String description;

  /// Feature card titles, in order.
  final List<String> featureTitles;

  /// Feature card subtitles, in order.
  final List<String> featureSubtitles;

  /// Primary button label.
  final String updateButton;

  /// Dismiss link label.
  final String laterButton;

  const ThemeStrings({
    required this.badge,
    required this.titleFirst,
    required this.titleSecond,
    required this.titleHighlight,
    required this.description,
    required this.featureTitles,
    required this.featureSubtitles,
    required this.updateButton,
    required this.laterButton,
  });

  /// The wording for [lang].
  static ThemeStrings of(ThemeLang lang) => _strings[lang]!;

  static const Map<ThemeLang, ThemeStrings> _strings = {
    ThemeLang.en: ThemeStrings(
      badge: 'NEW UPDATE AVAILABLE',
      titleFirst: 'Ready for',
      titleSecond: 'something',
      titleHighlight: 'better!',
      description: "We've improved performance, fixed bugs and added new "
          'features to make your journey smoother.',
      featureTitles: ['Quicker', 'Safer', 'Smoother'],
      featureSubtitles: [
        'snappier launches',
        'hardened security',
        'polished details',
      ],
      updateButton: 'UPDATE NOW',
      laterButton: 'LATER',
    ),
    ThemeLang.ar: ThemeStrings(
      badge: 'يتوفر تحديث جديد',
      titleFirst: 'هل أنت مستعد',
      titleSecond: 'لشيء',
      titleHighlight: 'أفضل؟',
      description: 'حسّنّا الأداء، وأصلحنا الأخطاء، وأضفنا ميزات جديدة '
          'لتجربة أسلس.',
      featureTitles: ['أسرع', 'أأمن', 'أسلس'],
      featureSubtitles: [
        'تشغيل أسرع',
        'حماية أقوى',
        'تفاصيل مصقولة',
      ],
      updateButton: 'حدّث الآن',
      laterButton: 'لاحقًا',
    ),
    ThemeLang.ur: ThemeStrings(
      badge: 'نیا اپ ڈیٹ دستیاب ہے',
      titleFirst: 'کیا آپ تیار ہیں',
      titleSecond: 'کسی',
      titleHighlight: 'بہتر چیز کے لیے؟',
      description: 'ہم نے کارکردگی بہتر بنائی، خرابیاں دور کیں اور نئی '
          'خصوصیات شامل کیں تاکہ آپ کا تجربہ ہموار ہو۔',
      featureTitles: ['تیز تر', 'محفوظ تر', 'ہموار تر'],
      featureSubtitles: [
        'تیز آغاز',
        'مضبوط سیکیورٹی',
        'بہتر تفصیلات',
      ],
      updateButton: 'ابھی اپ ڈیٹ کریں',
      laterButton: 'بعد میں',
    ),
    ThemeLang.es: ThemeStrings(
      badge: 'NUEVA ACTUALIZACIÓN DISPONIBLE',
      titleFirst: '¿Listo para',
      titleSecond: 'algo',
      titleHighlight: 'mejor?',
      description: 'Hemos mejorado el rendimiento, corregido errores y añadido '
          'nuevas funciones para una experiencia más fluida.',
      featureTitles: ['Más rápido', 'Más seguro', 'Más fluido'],
      featureSubtitles: [
        'inicios ágiles',
        'seguridad reforzada',
        'detalles pulidos',
      ],
      updateButton: 'ACTUALIZAR AHORA',
      laterButton: 'MÁS TARDE',
    ),
    ThemeLang.hi: ThemeStrings(
      badge: 'नया अपडेट उपलब्ध है',
      titleFirst: 'क्या आप तैयार हैं',
      titleSecond: 'कुछ',
      titleHighlight: 'बेहतर के लिए?',
      description: 'हमने प्रदर्शन बेहतर किया, बग ठीक किए और नई सुविधाएँ जोड़ीं '
          'ताकि आपका अनुभव और आसान हो।',
      featureTitles: ['तेज़', 'सुरक्षित', 'बेहतर'],
      featureSubtitles: [
        'तेज़ शुरुआत',
        'मज़बूत सुरक्षा',
        'बेहतर विवरण',
      ],
      updateButton: 'अभी अपडेट करें',
      laterButton: 'बाद में',
    ),
    ThemeLang.fr: ThemeStrings(
      badge: 'NOUVELLE MISE À JOUR DISPONIBLE',
      titleFirst: 'Prêt pour',
      titleSecond: 'quelque chose',
      titleHighlight: 'de mieux ?',
      description: 'Nous avons amélioré les performances, corrigé des bugs et '
          'ajouté de nouvelles fonctionnalités pour une expérience plus fluide.',
      featureTitles: ['Plus rapide', 'Plus sûr', 'Plus fluide'],
      featureSubtitles: [
        'démarrages rapides',
        'sécurité renforcée',
        'détails soignés',
      ],
      updateButton: 'METTRE À JOUR',
      laterButton: 'PLUS TARD',
    ),
    ThemeLang.id: ThemeStrings(
      badge: 'PEMBARUAN BARU TERSEDIA',
      titleFirst: 'Siap untuk',
      titleSecond: 'sesuatu yang',
      titleHighlight: 'lebih baik?',
      description: 'Kami meningkatkan performa, memperbaiki bug, dan menambah '
          'fitur baru agar pengalaman Anda lebih lancar.',
      featureTitles: ['Lebih cepat', 'Lebih aman', 'Lebih mulus'],
      featureSubtitles: [
        'peluncuran gesit',
        'keamanan diperkuat',
        'detail yang rapi',
      ],
      updateButton: 'PERBARUI SEKARANG',
      laterButton: 'NANTI',
    ),
  };
}
