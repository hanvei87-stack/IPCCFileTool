# IPCCFileTool

An original SwiftUI iOS file utility inspired by the visible workflow in the reference screenshots.

This project does not reuse the reference app binary, assets, authorization checks, or patch scripts. The important design point is that file browsing, folder creation, and permission saving all share the same `FileAccessSession`.

## What It Implements

- Home tab with permission initialization status and maintenance actions.
- Filza-like File tab with a root selector, sandbox-home shortcut, folder browser, and create-folder action.
- Info button for each file or folder.
- Permission editor that reads and saves POSIX mode bits.
- Permission lock list that persists desired path/mode pairs in `permission-locks.json`.
- Permission-save guide with diagnostics for current mode, target mode, path existence, read/write/execute checks, parent writeability, and error details.
- One shared access state: after initialization, permission saving uses the same file-operation channel as folder creation.
- Pluggable file backend: `FileAccessSession` can use a sandboxed local backend or a lawful privileged backend.

## Build Notes

The repository is currently on Windows, so an installable IPA cannot be produced here. This folder now includes an Xcode project:

- `IPCCFileTool.xcodeproj`

On a Mac:

1. Open `IPCCFileTool.xcodeproj`.
2. Select target `IPCCFileTool`.
3. Set your Apple developer team and bundle identifier.
4. Run on your device, or use Product > Archive to export an IPA.

You can also start an archive build with:

```sh
sh build_on_mac.sh
```

Or use GitHub Actions:

1. Push this repository to GitHub.
2. Open the Actions tab.
3. Run `Build IPCCFileTool unsigned IPA`.
4. Download the `IPCCFileTool_unsigned_ipa` artifact.

The workflow builds with `CODE_SIGNING_ALLOWED=NO` and uploads `IPCCFileTool_unsigned.ipa`. Your installer can sign it during installation.

For normal App Store-style apps, iOS only allows access inside the app sandbox or user-picked documents. For broader system paths, you need a lawful deployment environment and your own privileged helper or entitlement. The app logic is already structured so that helper can be wired into `FileAccessSession`.

This project intentionally does not integrate FilzaJailedDS exploit, sandbox escape, APFS ownership, or dylib injection code. It can be used as a clean app-side file manager and permission editor for paths the process can already access.

## Permission Locks

The lock feature persists the desired permission state, not a runtime privilege.

Flow:

1. Open a file or folder info sheet.
2. Set the mode bits.
3. Tap `Save and Lock Mode`.
4. The app applies `chmod` through the current `FileAccessSession`.
5. If the save succeeds, the app records `{ path, mode }` in `permission-locks.json`.
6. Each future `initializeAccess()` call automatically restores every locked mode.

This means:

- If the file mode itself can be changed, the mode should remain after the app exits.
- If another process or system service resets it, the app can restore it after the next successful initialization.
- If the target path is protected and no lawful backend is configured, the lock remains queued but restore will report the failure.

## Backend Design

`FileAccessSession` is the only object the UI talks to. Folder creation and permission saving both go through this same session, which prevents the bug where one screen has access but the permission editor still refuses to save.

Current backends:

- `LocalFileClient`: uses `FileManager` and POSIX `chmod` for paths the process can legally access.
- `PrivilegedFileClient`: a placeholder adapter for your own authorized helper/service. It intentionally contains no exploit or sandbox bypass code.

To connect a lawful helper, implement these methods in `PrivilegedFileClient`:

- `listDirectory(at:)`
- `createDirectory(named:in:)`
- `readPermissions(at:)`
- `savePermissions(_:at:)`

Then initialize the app with:

```swift
FileAccessSession(fileClient: PrivilegedFileClient())
```
