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
        appendLog("正在初始化文件访问会话...")
        state = .ready
        appendLog("文件访问会话已就绪。")
        applyLockedPermissions()
    }

    func listDirectory(at url: URL) throws -> [FileItem] {
        try requireReady()
        return try fileClient.listDirectory(at: url)
    }

    func createDirectory(named name: String, in parent: URL) throws {
        try requireReady()
        try fileClient.createDirectory(named: name, in: parent)
        appendLog("已创建文件夹：\(name)")
    }

    func readPermissions(at url: URL) throws -> FileItem {
        try requireReady()
        return try fileClient.readPermissions(at: url)
    }

    func savePermissions(_ permissions: FilePermissions, at url: URL) throws {
        try requireReady()
        try fileClient.savePermissions(permissions, at: url)
        appendLog("已保存权限 \(permissions.octalString)：\(url.path)")
    }

    func saveAndLockPermissions(_ permissions: FilePermissions, at url: URL) throws {
        try savePermissions(permissions, at: url)
        lockStore.upsert(path: url.path, mode: permissions.mode)
        syncLocks()
        appendLog("已锁定目标权限 \(permissions.octalString)：\(url.path)")
    }

    func removeLock(_ lock: PermissionLock) {
        lockStore.remove(lock)
        syncLocks()
        appendLog("已移除锁定：\(lock.path)")
    }

    func applyLockedPermissions() {
        guard isReady else {
            appendLog("跳过锁定恢复：会话未初始化。")
            return
        }

        syncLocks()
        guard !locks.isEmpty else {
            appendLog("没有需要恢复的锁定权限。")
            return
        }

        appendLog("正在恢复 \(locks.count) 个锁定权限...")
        for lock in locks {
            do {
                let permissions = FilePermissions(mode: lock.mode)
                try fileClient.savePermissions(permissions, at: lock.url)
                lockStore.markApplied(path: lock.path)
                appendLog("已恢复 \(lock.modeString)：\(lock.path)")
            } catch {
                lockStore.markFailed(path: lock.path, error: error)
                appendLog("恢复失败：\(lock.path) - \(error.localizedDescription)")
            }
        }
        syncLocks()
    }

    func restartNetwork() {
        appendLog("已请求重启蜂窝网络。")
    }

    func resetDefaults() {
        appendLog("已请求清理并恢复默认。")
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
