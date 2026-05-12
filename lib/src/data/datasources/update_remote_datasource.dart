import 'package:dio/dio.dart';

import '../models/release_info_model.dart';

class UpdateRemoteDataSource {
  UpdateRemoteDataSource({required this.dio});
  final Dio dio;

  Future<ReleaseInfoModel> getCurrentRelease(String channel) async {
    final res = await dio.get<Map<String, dynamic>>(
      '/v1/version',
      queryParameters: {'channel': channel},
    );
    return ReleaseInfoModel.fromJson(res.data!);
  }

  Future<Response<dynamic>> downloadFile({
    required String url,
    required String savePath,
    required CancelToken cancelToken,
    required void Function(int received, int total) onProgress,
  }) {
    return dio.download(
      url,
      savePath,
      cancelToken: cancelToken,
      onReceiveProgress: onProgress,
      options: Options(
        receiveTimeout: const Duration(minutes: 10),
        followRedirects: true,
        validateStatus: (s) => s != null && s >= 200 && s < 300,
      ),
    );
  }

  Future<void> sendCheckin({
    required String uuid,
    required int versionCode,
    required String versionName,
  }) async {
    await dio.post<void>(
      '/v1/checkin',
      data: {
        'uuid': uuid,
        'versionCode': versionCode,
        'versionName': versionName,
      },
    );
  }
}
