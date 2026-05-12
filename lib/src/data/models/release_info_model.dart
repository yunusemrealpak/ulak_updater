import '../../domain/entities/release_info.dart';

class ReleaseInfoModel {
  const ReleaseInfoModel({
    required this.versionCode,
    required this.versionName,
    required this.sha256,
    required this.fileSize,
    required this.downloadUrl,
    required this.mandatory,
    required this.releaseNotes,
    required this.publishedAt,
  });

  final int versionCode;
  final String versionName;
  final String sha256;
  final int fileSize;
  final String downloadUrl;
  final bool mandatory;
  final String releaseNotes;
  final DateTime publishedAt;

  factory ReleaseInfoModel.fromJson(Map<String, dynamic> json) {
    return ReleaseInfoModel(
      versionCode: (json['versionCode'] as num).toInt(),
      versionName: json['versionName'] as String,
      sha256: json['sha256'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      downloadUrl: json['downloadUrl'] as String,
      mandatory: json['mandatory'] as bool? ?? false,
      releaseNotes: json['releaseNotes'] as String? ?? '',
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );
  }

  ReleaseInfo toEntity() => ReleaseInfo(
        versionCode: versionCode,
        versionName: versionName,
        sha256: sha256,
        fileSize: fileSize,
        downloadUrl: downloadUrl,
        mandatory: mandatory,
        releaseNotes: releaseNotes,
        publishedAt: publishedAt,
      );
}
