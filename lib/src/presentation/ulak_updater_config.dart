import 'package:equatable/equatable.dart';

/// Configuration for the updater.
///
/// Constructed by the host app and passed to `UlakUpdater.init`. Only
/// [baseUrl] and [project] are required; everything else has sensible
/// defaults. Override [copy] to localize, change [channel] to ship `beta`
/// alongside `stable`, etc.
class UlakUpdaterConfig extends Equatable {
  /// Creates a configuration. [baseUrl] and [project] are required.
  const UlakUpdaterConfig({
    required this.baseUrl,
    required this.project,
    this.channel = 'stable',
    this.checkOnStartup = true,
    this.checkTimeout = const Duration(seconds: 8),
    this.downloadTimeout = const Duration(minutes: 10),
    this.copy = const UlakUpdaterCopy(),
  })  : assert(baseUrl != '', 'baseUrl must not be empty'),
        assert(project != '', 'project slug must not be empty');

  /// Public base URL of the ulak server, e.g. `https://updates.example.com`.
  ///
  /// No trailing slash. The package appends `/v1/version` and `/v1/checkin`;
  /// the APK download URL itself comes from the server response.
  final String baseUrl;

  /// Project slug this app belongs to (server-side identifier). Required
  /// since v0.2.0 — the server uses this to look up which release stream
  /// the device should follow.
  ///
  /// Server is multi-tenant: every Android `applicationId` corresponds to
  /// exactly one project. If you publish two apps from the same Ulak server,
  /// each must have its own slug.
  final String project;

  /// Release channel to follow. The server matches releases against this
  /// string (e.g. `stable`, `beta`). Defaults to `stable`.
  final String channel;

  /// Whether the bundled `UpdateGate` should auto-check on first build.
  ///
  /// Set to `false` if you want to drive the check manually via
  /// `UlakUpdater.instance.cubit.check()`.
  final bool checkOnStartup;

  /// Timeout for the `/v1/version` request before treating the server as
  /// offline and continuing with the currently installed version.
  final Duration checkTimeout;

  /// Total timeout for the APK download.
  ///
  /// APKs can be 50–150 MB; on a slow field network the default 10 minutes
  /// is generous. Tune as needed.
  final Duration downloadTimeout;

  /// User-facing strings shown by the bundled widgets. Override to localize.
  final UlakUpdaterCopy copy;

  @override
  List<Object?> get props =>
      [baseUrl, project, channel, checkOnStartup, checkTimeout, downloadTimeout, copy];
}

/// Externalized strings shown by the bundled widgets.
///
/// All defaults are Turkish. Construct your own [UlakUpdaterCopy] and pass
/// it via [UlakUpdaterConfig.copy] to translate or rebrand the UI without
/// forking the widget tree.
class UlakUpdaterCopy extends Equatable {
  /// Creates a copy bundle. Override individual fields to translate.
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

  /// Title shown while the version check request is in flight.
  final String checkingTitle;

  /// Passive toast shown when the server is unreachable on startup.
  final String offlineNotice;

  /// Title of the optional-update dialog.
  final String optionalTitle;

  /// Primary action label on the optional-update dialog ("Install now").
  final String optionalCta;

  /// Secondary action label on the optional-update dialog ("Later").
  final String optionalLater;

  /// Title of the fullscreen mandatory-update screen.
  final String mandatoryTitle;

  /// Body text on the mandatory-update screen.
  final String mandatoryBody;

  /// Primary action label on the mandatory-update screen ("Install").
  final String mandatoryCta;

  /// Exit-app label on the mandatory-update screen.
  final String mandatoryExit;

  /// Title of the download progress dialog.
  final String downloadingTitle;

  /// Title shown while the SHA-256 of the downloaded APK is being computed.
  final String verifyingTitle;

  /// Title shown while the install intent is being dispatched.
  final String installingTitle;

  /// Title of the "permission needed" dialog (REQUEST_INSTALL_PACKAGES).
  final String permissionNeededTitle;

  /// Body text of the "permission needed" dialog.
  final String permissionNeededBody;

  /// Action label that opens the unknown-sources system settings page.
  final String permissionOpenSettings;

  /// Title of the generic error dialog.
  final String errorTitle;

  /// Retry action label on the error dialog.
  final String errorRetry;

  /// Section header for release notes inside dialogs.
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
