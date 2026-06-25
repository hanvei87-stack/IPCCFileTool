import Foundation

@MainActor
final class PermissionLockStore: ObservableObject {
    @Published private(set) var locks: [PermissionLock] = []

    private let storageURL: URL

    init(storageURL: URL? = nil) {
        if let storageURL {
            self.storageURL = storageURL
        } else {
            let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            self.storageURL = base.appendingPathComponent("permission-locks.json")
        }
        load()
    }

    func upsert(path: String, mode: Int) {
        if let index = locks.firstIndex(where: { $0.path == path }) {
            locks[index].mode = mode
            locks[index].lastError = nil
        } else {
            locks.append(PermissionLock(path: path, mode: mode))
        }
        save()
    }

    func remove(_ lock: PermissionLock) {
        locks.removeAll { $0.id == lock.id }
        save()
    }

    func markApplied(path: String) {
        guard let index = locks.firstIndex(where: { $0.path == path }) else { return }
        locks[index].lastAppliedAt = Date()
        locks[index].lastError = nil
        save()
    }

    func markFailed(path: String, error: Error) {
        guard let index = locks.firstIndex(where: { $0.path == path }) else { return }
        locks[index].lastError = error.localizedDescription
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else {
            locks = []
            return
        }
        locks = (try? JSONDecoder().decode([PermissionLock].self, from: data)) ?? []
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(locks) else { return }
        try? data.write(to: storageURL, options: [.atomic])
    }
}
