## 0.1.0

- Initial release.
- Android-only self-hosted in-app updater.
- App-startup version check against a Ulak server.
- APK download with progress + SHA-256 verification.
- One-tap install via `REQUEST_INSTALL_PACKAGES` (no Device Owner required).
- Mandatory release flag hard-blocks the host app until the user updates.
- Soft offline policy: unreachable server lets the host app proceed.
- Anonymous device check-in (UUID + versionCode) for telemetry.
- Clean Architecture (data / domain / presentation), `Either<Failure, T>` (fpdart), `flutter_bloc` Cubit.
