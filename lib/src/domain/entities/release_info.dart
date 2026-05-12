import 'package:equatable/equatable.dart';

/// Domain entity describing a release as the device sees it.
class ReleaseInfo extends Equatable {
  const ReleaseInfo({
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

  @override
  List<Object?> get props => [
        versionCode,
        versionName,
        sha256,
        fileSize,
        downloadUrl,
        mandatory,
        releaseNotes,
        publishedAt,
      ];
}
