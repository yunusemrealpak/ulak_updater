import 'package:equatable/equatable.dart';

/// Configuration for the updater. Constructed by the host app and passed
/// to [UlakUpdater.init].
class UlakUpdaterConfig extends Equatable {
  const UlakUpdaterConfig({
    required this.baseUrl,
    this.channel = 'stable',
    this.checkOnStartup = true,
    this.checkTimeout = const Duration(seconds: 8),
    this.downloadTimeout = const Duration(minutes: 10),
    this.copy = const UlakUpdaterCopy(),
  });

  /// Public base URL of the ulak server, e.g. https://ulak.tepvox.com
  final String baseUrl;

  /// Release channel to follow (server-side concept; default 'stable').
  final String channel;

  /// Whether the [UpdateGate] should auto-check on first build.
  final bool checkOnStartup;

  /// Timeout for the /v1/version request before treating as offline.
  final Duration checkTimeout;

  /// Total timeout for the APK download.
  final Duration downloadTimeout;

  /// User-facing strings (Turkish defaults). Override to localize.
  final UlakUpdaterCopy copy;

  @override
  List<Object?> get props =>
      [baseUrl, channel, checkOnStartup, checkTimeout, downloadTimeout, copy];
}

/// Externalized strings shown by the bundled widgets. All Turkish by default.
class UlakUpdaterCopy extends Equatable {
  const UlakUpdaterCopy({
    this.checkingTitle = 'Güncelleme kontrol ediliyor',
    this.offlineNotice = 'Güncelleme kontrolü yapılamadı',
    this.optionalTitle = 'Yeni sürüm hazır',
    this.optionalCta = 'Yükle',
    this.optionalLater = 'Sonra',
    this.mandatoryTitle = 'Zorunlu güncelleme',
    this.mandatoryBody = 'Devam etmek için yeni sürümü yüklemeniz gerekiyor.',
    this.mandatoryCta = 'Yükle',
    this.mandatoryExit = 'Çıkış',
    this.downloadingTitle = 'İndiriliyor',
    this.verifyingTitle = 'Doğrulanıyor',
    this.installingTitle = 'Yükleniyor',
    this.permissionNeededTitle = 'İzin gerekli',
    this.permissionNeededBody =
        'Yeni sürümü yüklemek için “Bilinmeyen kaynaklara izin ver” ayarını açın.',
    this.permissionOpenSettings = 'Ayarları aç',
    this.errorTitle = 'Bir sorun oluştu',
    this.errorRetry = 'Tekrar dene',
    this.releaseNotesTitle = 'Yenilikler',
  });

  final String checkingTitle;
  final String offlineNotice;

  final String optionalTitle;
  final String optionalCta;
  final String optionalLater;

  final String mandatoryTitle;
  final String mandatoryBody;
  final String mandatoryCta;
  final String mandatoryExit;

  final String downloadingTitle;
  final String verifyingTitle;
  final String installingTitle;

  final String permissionNeededTitle;
  final String permissionNeededBody;
  final String permissionOpenSettings;

  final String errorTitle;
  final String errorRetry;

  final String releaseNotesTitle;

  @override
  List<Object?> get props => [
        checkingTitle,
        offlineNotice,
        optionalTitle,
        optionalCta,
        optionalLater,
        mandatoryTitle,
        mandatoryBody,
        mandatoryCta,
        mandatoryExit,
        downloadingTitle,
        verifyingTitle,
        installingTitle,
        permissionNeededTitle,
        permissionNeededBody,
        permissionOpenSettings,
        errorTitle,
        errorRetry,
        releaseNotesTitle,
      ];
}
