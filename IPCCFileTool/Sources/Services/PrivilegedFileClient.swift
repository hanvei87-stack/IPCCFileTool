import Foundation

/// Adapter for a lawful privileged helper, MDM-managed entitlement, or internal
/// deployment channel. Keep exploit or sandbox-bypass code out of this app.
final class PrivilegedFileClient: FileClient {
    func listDirectory(at url: URL) throws -> [FileItem] {
        throw notConfigured()
    }

    func createDirectory(named name: String, in parent: URL) throws {
        throw notConfigured()
    }

    func readPermissions(at url: URL) throws -> FileItem {
        throw notConfigured()
    }

    func savePermissions(_ permissions: FilePermissions, at url: URL) throws {
        throw notConfigured()
    }

    private func notConfigured() -> NSError {
        NSError(
            domain: "IPCCFileTool.PrivilegedFileClient",
            code: 1,
            userInfo: [
                NSLocalizedDescriptionKey: "尚未配置特权文件后端。"
            ]
        )
    }
}
