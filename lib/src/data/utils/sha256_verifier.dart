import 'dart:io';

import 'package:crypto/crypto.dart';

/// Streams [filePath] through SHA-256 in 64KB chunks and returns the hex digest.
/// Avoids loading large APKs fully into memory.
class Sha256Verifier {
  const Sha256Verifier();

  Future<String> computeSha256(String filePath) async {
    final stream = File(filePath).openRead();
    final digest = await sha256.bind(stream).first;
    return digest.toString();
  }
}
