import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../data/datasources/update_local_datasource.dart';
import '../data/datasources/update_remote_datasource.dart';
import '../data/repositories/update_repository_impl.dart';
import '../data/utils/sha256_verifier.dart';
import '../domain/usecases/check_for_update.dart';
import '../domain/usecases/download_apk.dart';
import '../domain/usecases/install_apk.dart';
import '../domain/usecases/send_checkin.dart';
import '../domain/usecases/verify_apk.dart';
import '../platform/android_installer.dart';
import 'cubit/update_cubit.dart';
import 'ulak_updater_config.dart';

/// Top-level entry point for the package.
///
/// `UlakUpdater` owns a single state machine ([UpdateCubit]) and the
/// [UlakUpdaterConfig] you provide. Call [init] once during app startup
/// before `runApp`, then wrap your home widget with `UpdateGate`.
///
/// ```dart
/// await UlakUpdater.init(
///   config: const UlakUpdaterConfig(baseUrl: 'https://updates.example.com'),
/// );
/// runApp(const MyApp());
/// ```
///
/// Accessing [config] or [cubit] before [init] throws [StateError].
class UlakUpdater {
  UlakUpdater._();

  static final UlakUpdater _instance = UlakUpdater._();

  /// The singleton instance. Use [init] before reading [config] or [cubit].
  static UlakUpdater get instance => _instance;

  late UlakUpdaterConfig _config;
  late UpdateCubit _cubit;
  bool _initialized = false;

  /// The configuration passed to [init].
  ///
  /// Throws [StateError] if [init] has not yet been called.
  UlakUpdaterConfig get config {
    _ensureInit();
    return _config;
  }

  /// The state machine driving the update flow. Exposed for advanced apps
  /// that want to build a custom UI instead of using `UpdateGate`.
  ///
  /// Throws [StateError] if [init] has not yet been called.
  UpdateCubit get cubit {
    _ensureInit();
    return _cubit;
  }

  void _ensureInit() {
    if (!_initialized) {
      throw StateError('UlakUpdater.init(...) must be called before use');
    }
  }

  /// Initializes the singleton with the given [config].
  ///
  /// This wires up Hive (local storage for the device UUID and last
  /// successful check), the Dio HTTP client, the data sources, the
  /// repository, the use cases, and the [UpdateCubit]. After this call
  /// returns, [instance] is ready to use.
  ///
  /// `init` is idempotent — calling it more than once is a no-op.
  /// Must be invoked **after** `WidgetsFlutterBinding.ensureInitialized()`
  /// and **before** `runApp`.
  static Future<void> init({required UlakUpdaterConfig config}) async {
    final i = _instance;
    if (i._initialized) {
      return;
    }
    i._config = config;

    await Hive.initFlutter();
    final box = await Hive.openBox<dynamic>(UpdateLocalDataSource.boxName);

    final dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.checkTimeout,
      sendTimeout: config.checkTimeout,
      receiveTimeout: config.checkTimeout,
      responseType: ResponseType.json,
      validateStatus: (s) => s != null && s >= 200 && s < 300,
    ),);

    final remote = UpdateRemoteDataSource(dio: dio);
    final local = UpdateLocalDataSource(box: box);
    const installer = AndroidInstaller();
    const verifier = Sha256Verifier();

    final repo = UpdateRepositoryImpl(
      remote: remote,
      local: local,
      installer: installer,
      verifier: verifier,
      channel: config.channel,
    );

    final pkg = await PackageInfo.fromPlatform();
    final currentCode = int.tryParse(pkg.buildNumber) ?? 1;
    final currentName = pkg.version.isEmpty ? '0.0.0' : pkg.version;

    i._cubit = UpdateCubit(
      checkForUpdate: CheckForUpdate(repo),
      downloadApk: DownloadApk(repo),
      verifyApk: VerifyApk(repo),
      installApk: InstallApk(repo),
      sendCheckin: SendCheckin(repo),
      currentVersionCode: currentCode,
      currentVersionName: currentName,
    );

    i._initialized = true;
  }
}
