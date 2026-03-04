/// Holds all user-facing text for the built-in update widgets.
///
/// Use this to localize the update dialog, banner, and block screen
/// into any language. Factory constructors are provided for common
/// languages.
///
/// ```dart
/// final result = await VersionGate(
///   strings: UpdateStrings.arabic(),
/// ).check();
/// ```
class UpdateStrings {
  /// Dialog / block screen title (e.g., "Update Available").
  final String title;

  /// Dialog / block screen body message.
  ///
  /// Use `{storeVersion}` and `{localVersion}` as placeholders —
  /// they are replaced at runtime by the widget.
  final String message;

  /// Text for the primary "Update" button.
  final String updateButtonText;

  /// Text for the secondary "Later" / dismiss button.
  final String laterButtonText;

  /// Label shown above the release notes section.
  final String releaseNotesTitle;

  /// Banner message shown in [UpdateBanner].
  ///
  /// Use `{storeVersion}` as a placeholder.
  final String bannerMessage;

  /// Text for the dismiss button in the banner.
  final String dismissButtonText;

  /// Title for the forced-update block screen.
  final String blockScreenTitle;

  /// Message for the forced-update block screen.
  ///
  /// Use `{storeVersion}` and `{localVersion}` as placeholders.
  final String blockScreenMessage;

  /// Button text on the forced-update block screen.
  final String blockScreenButtonText;

  const UpdateStrings({
    this.title = 'Update Available',
    this.message =
        'Version {storeVersion} is now available. You are using version {localVersion}.',
    this.updateButtonText = 'Update Now',
    this.laterButtonText = 'Later',
    this.releaseNotesTitle = "What's new:",
    this.bannerMessage =
        'Version {storeVersion} is available. Tap Update to get the latest features.',
    this.dismissButtonText = 'Dismiss',
    this.blockScreenTitle = 'Update Required',
    this.blockScreenMessage =
        'A new version ({storeVersion}) is required to continue using this app. You are currently on version {localVersion}.',
    this.blockScreenButtonText = 'Go to Store',
  });

  /// English (default).
  const factory UpdateStrings.english() = UpdateStrings;

  /// Arabic (العربية).
  factory UpdateStrings.arabic() => const UpdateStrings(
        title: 'تحديث متاح',
        message:
            'الإصدار {storeVersion} متاح الآن. أنت تستخدم الإصدار {localVersion}.',
        updateButtonText: 'تحديث الآن',
        laterButtonText: 'لاحقاً',
        releaseNotesTitle: 'ما الجديد:',
        bannerMessage:
            'الإصدار {storeVersion} متاح. اضغط تحديث للحصول على أحدث الميزات.',
        dismissButtonText: 'تجاهل',
        blockScreenTitle: 'تحديث مطلوب',
        blockScreenMessage:
            'الإصدار الجديد ({storeVersion}) مطلوب لمتابعة استخدام التطبيق. أنت حالياً على الإصدار {localVersion}.',
        blockScreenButtonText: 'الذهاب إلى المتجر',
      );

  /// Spanish (Español).
  factory UpdateStrings.spanish() => const UpdateStrings(
        title: 'Actualización disponible',
        message:
            'La versión {storeVersion} ya está disponible. Estás usando la versión {localVersion}.',
        updateButtonText: 'Actualizar ahora',
        laterButtonText: 'Más tarde',
        releaseNotesTitle: 'Novedades:',
        bannerMessage:
            'La versión {storeVersion} está disponible. Toca Actualizar para obtener las últimas funciones.',
        dismissButtonText: 'Descartar',
        blockScreenTitle: 'Actualización requerida',
        blockScreenMessage:
            'Se requiere una nueva versión ({storeVersion}) para continuar usando esta app. Actualmente tienes la versión {localVersion}.',
        blockScreenButtonText: 'Ir a la tienda',
      );

  /// French (Français).
  factory UpdateStrings.french() => const UpdateStrings(
        title: 'Mise à jour disponible',
        message:
            'La version {storeVersion} est maintenant disponible. Vous utilisez la version {localVersion}.',
        updateButtonText: 'Mettre à jour',
        laterButtonText: 'Plus tard',
        releaseNotesTitle: 'Nouveautés :',
        bannerMessage:
            'La version {storeVersion} est disponible. Appuyez sur Mettre à jour pour obtenir les dernières fonctionnalités.',
        dismissButtonText: 'Ignorer',
        blockScreenTitle: 'Mise à jour requise',
        blockScreenMessage:
            'Une nouvelle version ({storeVersion}) est nécessaire pour continuer à utiliser cette application. Vous êtes actuellement sur la version {localVersion}.',
        blockScreenButtonText: 'Aller au store',
      );

  /// German (Deutsch).
  factory UpdateStrings.german() => const UpdateStrings(
        title: 'Update verfügbar',
        message:
            'Version {storeVersion} ist jetzt verfügbar. Sie verwenden Version {localVersion}.',
        updateButtonText: 'Jetzt aktualisieren',
        laterButtonText: 'Später',
        releaseNotesTitle: 'Was ist neu:',
        bannerMessage:
            'Version {storeVersion} ist verfügbar. Tippen Sie auf Aktualisieren, um die neuesten Funktionen zu erhalten.',
        dismissButtonText: 'Verwerfen',
        blockScreenTitle: 'Update erforderlich',
        blockScreenMessage:
            'Eine neue Version ({storeVersion}) ist erforderlich, um diese App weiterhin zu nutzen. Sie verwenden derzeit Version {localVersion}.',
        blockScreenButtonText: 'Zum Store',
      );

  /// Turkish (Türkçe).
  factory UpdateStrings.turkish() => const UpdateStrings(
        title: 'Güncelleme mevcut',
        message:
            'Sürüm {storeVersion} şimdi mevcut. Sürüm {localVersion} kullanıyorsunuz.',
        updateButtonText: 'Şimdi güncelle',
        laterButtonText: 'Daha sonra',
        releaseNotesTitle: 'Yenilikler:',
        bannerMessage:
            'Sürüm {storeVersion} mevcut. En son özellikleri almak için Güncelle\'ye dokunun.',
        dismissButtonText: 'Kapat',
        blockScreenTitle: 'Güncelleme gerekli',
        blockScreenMessage:
            'Bu uygulamayı kullanmaya devam etmek için yeni bir sürüm ({storeVersion}) gereklidir. Şu anda {localVersion} sürümünü kullanıyorsunuz.',
        blockScreenButtonText: 'Mağazaya git',
      );

  /// Urdu (اردو).
  factory UpdateStrings.urdu() => const UpdateStrings(
        title: 'اپ ڈیٹ دستیاب ہے',
        message:
            'ورژن {storeVersion} اب دستیاب ہے۔ آپ ورژن {localVersion} استعمال کر رہے ہیں۔',
        updateButtonText: 'ابھی اپ ڈیٹ کریں',
        laterButtonText: 'بعد میں',
        releaseNotesTitle: 'نیا کیا ہے:',
        bannerMessage:
            'ورژن {storeVersion} دستیاب ہے۔ تازہ ترین خصوصیات حاصل کرنے کے لیے اپ ڈیٹ پر ٹیپ کریں۔',
        dismissButtonText: 'نظر انداز کریں',
        blockScreenTitle: 'اپ ڈیٹ ضروری ہے',
        blockScreenMessage:
            'اس ایپ کو استعمال جاری رکھنے کے لیے نیا ورژن ({storeVersion}) ضروری ہے۔ آپ فی الحال ورژن {localVersion} پر ہیں۔',
        blockScreenButtonText: 'اسٹور پر جائیں',
      );

  /// Chinese Simplified (简体中文).
  factory UpdateStrings.chinese() => const UpdateStrings(
        title: '有可用更新',
        message: '版本 {storeVersion} 现已可用。您正在使用版本 {localVersion}。',
        updateButtonText: '立即更新',
        laterButtonText: '稍后',
        releaseNotesTitle: '更新内容：',
        bannerMessage: '版本 {storeVersion} 可用。点击更新获取最新功能。',
        dismissButtonText: '忽略',
        blockScreenTitle: '需要更新',
        blockScreenMessage:
            '需要新版本 ({storeVersion}) 才能继续使用此应用。您当前使用的是版本 {localVersion}。',
        blockScreenButtonText: '前往商店',
      );

  /// Japanese (日本語).
  factory UpdateStrings.japanese() => const UpdateStrings(
        title: 'アップデートがあります',
        message: 'バージョン {storeVersion} が利用可能です。現在バージョン {localVersion} を使用しています。',
        updateButtonText: '今すぐ更新',
        laterButtonText: '後で',
        releaseNotesTitle: '新機能：',
        bannerMessage: 'バージョン {storeVersion} が利用可能です。更新をタップして最新機能を入手してください。',
        dismissButtonText: '閉じる',
        blockScreenTitle: 'アップデートが必要です',
        blockScreenMessage:
            'このアプリを引き続き使用するには、新しいバージョン ({storeVersion}) が必要です。現在バージョン {localVersion} を使用しています。',
        blockScreenButtonText: 'ストアへ',
      );

  /// Korean (한국어).
  factory UpdateStrings.korean() => const UpdateStrings(
        title: '업데이트 가능',
        message: '버전 {storeVersion}을(를) 사용할 수 있습니다. 현재 버전 {localVersion}을(를) 사용 중입니다.',
        updateButtonText: '지금 업데이트',
        laterButtonText: '나중에',
        releaseNotesTitle: '새로운 기능:',
        bannerMessage: '버전 {storeVersion}을(를) 사용할 수 있습니다. 업데이트를 탭하여 최신 기능을 받으세요.',
        dismissButtonText: '닫기',
        blockScreenTitle: '업데이트 필요',
        blockScreenMessage:
            '이 앱을 계속 사용하려면 새 버전 ({storeVersion})이 필요합니다. 현재 버전 {localVersion}을(를) 사용 중입니다.',
        blockScreenButtonText: '스토어로 이동',
      );

  /// Replaces `{storeVersion}` and `{localVersion}` placeholders
  /// in the given [template] string.
  String resolve(String template, String storeVersion, String localVersion) {
    return template
        .replaceAll('{storeVersion}', storeVersion)
        .replaceAll('{localVersion}', localVersion);
  }
}
