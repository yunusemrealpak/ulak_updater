import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

/// Wrapper around a tiny Hive box used to persist the device UUID and the
/// timestamp of the last successful version check.
class UpdateLocalDataSource {
  UpdateLocalDataSource({required this.box});
  final Box<dynamic> box;

  static const String boxName = 'ulak_meta';
  static const String _kUuid = 'device_uuid';
  static const String _kLastCheckMs = 'last_successful_check_ms';

  Future<String> getOrCreateUuid() async {
    final cached = box.get(_kUuid) as String?;
    if (cached != null && cached.isNotEmpty) return cached;
    final fresh = const Uuid().v4();
    await box.put(_kUuid, fresh);
    return fresh;
  }

  DateTime? getLastSuccessfulCheck() {
    final ms = box.get(_kLastCheckMs) as int?;
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markSuccessfulCheck(DateTime ts) {
    return box.put(_kLastCheckMs, ts.millisecondsSinceEpoch);
  }
}
