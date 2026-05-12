## 0.2.0

**Breaking change.** The Ulak server is now multi-tenant; every project
(Android `applicationId`) lives under its own slug.

- `UlakUpdaterConfig` requires a new `project` field (project slug).
- `/v1/version` is called with `?project=<slug>&channel=<ch>`.
- `/v1/checkin` body now includes the project slug.
- The download URL is read directly from the server response, so no client
  change is needed for `/v1/download/{project}/{vc}`.

Migration:
```dart
// before
UlakUpdaterConfig(baseUrl: 'https://updates.example.com')

// after
UlakUpdaterConfig(
  baseUrl: 'https://updates.example.com',
  project: 'saha',
)
```

If you upgrade the server before your devices, set
`ULAK_LEGACY_DEFAULT_PROJECT` on the server for one rollout window so
0.1.x clients keep working.

## 0.1.1

- Add dartdoc comments to all public APIs (`UlakUpdater`, `UlakUpdaterConfig`, `UlakUpdaterCopy`, `UpdateGate`, `ReleaseInfo`, `UpdateState` and subclasses, `UpdateFailure` and subclasses).
- Replace deprecated `ThemeData.dialogBackgroundColor` with `dialogTheme.backgroundColor` in bundled dialogs.
- Add missing trailing commas across the package.

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
