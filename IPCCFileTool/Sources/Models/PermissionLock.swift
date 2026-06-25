import Foundation

struct PermissionLock: Identifiable, Codable, Equatable {
    var id: UUID
    var path: String
    var mode: Int
    var createdAt: Date
    var lastAppliedAt: Date?
    var lastError: String?

    init(path: String, mode: Int) {
        self.id = UUID()
        self.path = path
        self.mode = mode
        self.createdAt = Date()
        self.lastAppliedAt = nil
        self.lastError = nil
    }

    var url: URL {
        URL(fileURLWithPath: path)
    }

    var modeString: String {
        String(format: "%04o", mode)
    }
}
