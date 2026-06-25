import Foundation

protocol FileClient {
    func listDirectory(at url: URL) throws -> [FileItem]
    func createDirectory(named name: String, in parent: URL) throws
    func readPermissions(at url: URL) throws -> FileItem
    func savePermissions(_ permissions: FilePermissions, at url: URL) throws
}

enum FileClientError: LocalizedError {
    case accessNotInitialized
    case invalidDirectoryName
    case posixFailure(operation: String, code: Int32)

    var errorDescription: String? {
        switch self {
        case .accessNotInitialized:
            return "Initialize file access first."
        case .invalidDirectoryName:
            return "Invalid folder name."
        case .posixFailure(let operation, let code):
            return "\(operation) failed with errno \(code)."
        }
    }
}
