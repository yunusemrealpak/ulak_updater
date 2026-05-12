/// ulak_updater — self-hosted in-app updater for Android Flutter apps.
///
/// Public API:
///   - [UlakUpdater.init] — call once before runApp().
///   - [UlakUpdaterConfig] — configures base URL, timeouts, copy.
///   - [UpdateGate] — wrap your home widget; gates host app behind update flow.
///
/// Internal layers (data/domain/presentation/platform) are exported for
/// advanced use (custom UI), but most apps only need the three above.
library;

export 'src/presentation/ulak_updater.dart';
export 'src/presentation/ulak_updater_config.dart';
export 'src/presentation/widgets/update_gate.dart';

export 'src/domain/entities/release_info.dart';
export 'src/domain/entities/update_state.dart';
export 'src/domain/failures/update_failure.dart';
