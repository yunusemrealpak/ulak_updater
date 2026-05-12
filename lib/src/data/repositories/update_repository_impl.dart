import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/release_info.dart';
import '../../domain/failures/update_failure.dart';
import '../../domain/repositories/update_repository.dart';
import '../../platform/android_installer.dart';
import '../datasources/update_local_datasource.dart';
import '../datasources/update_remote_datasource.dart';
import '../utils/sha256_verifier.dart';

class UpdateRepositoryImpl implements UpdateRepository {
  UpdateRepositoryImpl({
    required this.remote,
    required this.local,
    required this.installer,
    required this.verifier,
    required this.channel,
  });

  final UpdateRemoteDataSource remote;
  final UpdateLocalDataSource local;
  final AndroidInstaller installer;
  final Sha256Verifier verifier;
  final String channel;

  CancelToken? _activeDownload;

  @override
  Future<Either<UpdateFailure, ReleaseInfo>> getCurrentRelease() async {
    try {
      final m = await remote.getCurrentRelease(channel);
      await local.markSuccessfulCheck(DateTime.now());
      return right(m.toEntity());
    } on DioException catch (e) {
      return left(_mapDio(e));
    } catch (e) {
      return left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<UpdateFailure, String>> downloadApk({
    required ReleaseInfo info,
    required void Function(int received, int total) onProgress,
  }) async {
    try {
      final dir = await getExternalStorageDirectory() ?? await getApplicationCacheDirectory();
      final shaPrefix = info.sha256.length >= 8 ? info.sha256.substring(0, 8) : info.sha256;
      final filePath = '${dir.path}/ulak-${info.versionCode}-$shaPrefix.apk';

      // If a previously downloaded file exists, drop it so we always have a clean copy.
      final existing = File(filePath);
      if (await existing.exists()) {
        await existing.delete();
      }

      _activeDownload = CancelToken();
      await remote.downloadFile(
        url: info.downloadUrl,
        savePath: filePath,
        cancelToken: _activeDownload!,
        onProgress: onProgress,
      );
      return right(filePath);
    } on DioException catch (e) {
      return left(_mapDio(e));
    } catch (e) {
      return left(StorageFailure(e.toString()));
    } finally {
      _activeDownload = null;
    }
  }

  @override
  Future<Either<UpdateFailure, Unit>> verifyApk({
    required String filePath,
    required String expectedSha256,
  }) async {
    try {
      final actual = await verifier.computeSha256(filePath);
      if (actual.toLowerCase() != expectedSha256.toLowerCase()) {
        return Left(IntegrityFailure(
          'SHA-256 mismatch (expected ${expectedSha256.substring(0, 8)}…, got ${actual.substring(0, 8)}…)',
        ));
      }
      return const Right(unit);
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }

  @override
  Future<Either<UpdateFailure, Unit>> installApk(String filePath) async {
    try {
      final canInstall = await installer.canInstall();
      if (!canInstall) {
        await installer.requestInstallPermission();
        return const Left(InstallPermissionFailure(
          'REQUEST_INSTALL_PACKAGES permission required',
        ));
      }
      await installer.installApk(filePath);
      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(InstallFailure(e.message ?? 'install failed'));
    } catch (e) {
      return left(InstallFailure(e.toString()));
    }
  }

  @override
  Future<void> sendCheckin({
    required int currentVersionCode,
    required String currentVersionName,
  }) async {
    try {
      final uuid = await local.getOrCreateUuid();
      await remote.sendCheckin(
        uuid: uuid,
        versionCode: currentVersionCode,
        versionName: currentVersionName,
      );
    } catch (_) {
      // fire-and-forget; caller does not see this
    }
  }

  @override
  Future<String> getDeviceUuid() => local.getOrCreateUuid();

  void cancelActiveDownload() {
    _activeDownload?.cancel('user cancelled');
  }

  UpdateFailure _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(e.message ?? 'connection error');
      case DioExceptionType.badCertificate:
        return NetworkFailure('TLS certificate error: ${e.message}');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode ?? 0;
        return ServerFailure(
          e.response?.data?.toString() ?? 'bad response',
          code,
        );
      case DioExceptionType.cancel:
        return const NetworkFailure('cancelled');
      case DioExceptionType.unknown:
        return NetworkFailure(e.message ?? 'unknown network error');
    }
  }
}

