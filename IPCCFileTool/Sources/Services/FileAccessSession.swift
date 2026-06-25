import Foundation

@MainActor
final class FileAccessSession: ObservableObject {
    enum State: Equatable {
        case idle
        case ready
        case failed(String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var logLines: [String] = []
    @Published private(set) var locks: [PermissionLock] = []

    private let fileClient: FileClient
    private let lockStore: PermissionLockStore

    init(fileClient: FileClient, lockStore: PermissionLockStore = PermissionLockStore()) {
        self.fileClient = fileClient
        self.lockStore = lockStore
        self.locks = lockStore.locks
    }

    var isReady: Bool {
        if case .ready = state { return true }
        return false
    }

    func initializeAccess() {
        appendLog("Initializing file access session...")
        state = .ready
        appendLog("File access session is ready.")
        applyLockedPermissions()
    }

    func listDirectory(at url: URL) throws -> [FileItem] {
        try requireReady()
        return try fileClient.listDirectory(at: url)
    }

    func createDirectory(named name: String, in parent: URL) throws {
        try requireReady()
        try fileClient.createDirectory(named: name, in: parent)
        appendLog("Created folder: \(name)")
    }

    func readPermissions(at url: URL) throws -> FileItem {
        try requireReady()
        return try fileClient.readPermissions(at: url)
    }

    func savePermissions(_ permissions: FilePermissions, at url: URL) throws {
        try requireReady()
        try fileClient.savePermissions(permissions, at: url)
        appendLog("Saved mode \(permissions.octalString): \(url.path)")
    }

    func saveAndLockPermissions(_ permissions: FilePermissions, at url: URL) throws {
        try savePermissions(permissions, at: url)
        lockStore.upsert(path: url.path, mode: permissions.mode)
        syncLocks()
        appendLog("Locked desired mode \(permissions.octalString): \(url.path)")
    }

    func removeLock(_ lock: PermissionLock) {
        lockStore.remove(lock)
        syncLocks()
        appendLog("Removed lock: \(lock.path)")
    }

    func applyLockedPermissions() {
        guard isReady else {
            appendLog("Skipped lock restore: session is not ready.")
            return
        }

        syncLocks()
        guard !locks.isEmpty else {
            appendLog("No locked permissions to restore.")
            return
        }

        appendLog("Restoring \(locks.count) locked permission item(s)...")
        for lock in locks {
            do {
                let permissions = FilePermissions(mode: lock.mode)
                try fileClient.savePermissions(permissions, at: lock.url)
                lockStore.markApplied(path: lock.path)
                appendLog("Restored \(lock.modeString): \(lock.path)")
            } catch {
                lockStore.markFailed(path: lock.path, error: error)
                appendLog("Restore failed: \(lock.path) - \(error.localizedDescription)")
            }
        }
        syncLocks()
    }

    func restartNetwork() {
        appendLog("Requested cellular network restart.")
    }

    func resetDefaults() {
        appendLog("Requested cleanup and default restore.")
    }

    private func requireReady() throws {
        guard isReady else {
            throw FileClientError.accessNotInitialized
        }
    }

    private func appendLog(_ message: String) {
        logLines.append(message)
        if logLines.count > 80 {
            logLines.removeFirst(logLines.count - 80)
        }
    }

    private func syncLocks() {
        locks = lockStore.locks
    }
}
