import Foundation

final class LocalFileClient: FileClient {
    private let fileManager = FileManager.default

    func listDirectory(at url: URL) throws -> [FileItem] {
        let urls = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        return try urls
            .map { try readPermissions(at: $0) }
            .sorted { left, right in
                if left.isDirectory != right.isDirectory {
                    return left.isDirectory && !right.isDirectory
                }
                return left.name.localizedStandardCompare(right.name) == .orderedAscending
            }
    }

    func createDirectory(named name: String, in parent: URL) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !trimmed.contains("/") else {
            throw FileClientError.invalidDirectoryName
        }

        try fileManager.createDirectory(
            at: parent.appendingPathComponent(trimmed, isDirectory: true),
            withIntermediateDirectories: false
        )
    }

    func readPermissions(at url: URL) throws -> FileItem {
        let attributes = try fileManager.attributesOfItem(atPath: url.path)
        let type = attributes[.type] as? FileAttributeType
        let mode = attributes[.posixPermissions] as? Int ?? 0
        let owner = attributes[.ownerAccountName] as? String ?? "-"
        let group = attributes[.groupOwnerAccountName] as? String ?? "-"

        return FileItem(
            url: url,
            isDirectory: type == .typeDirectory,
            permissions: FilePermissions(mode: mode),
            ownerName: owner,
            groupName: group
        )
    }

    func savePermissions(_ permissions: FilePermissions, at url: URL) throws {
        let result = chmod(url.path, mode_t(permissions.mode))
        guard result == 0 else {
            throw FileClientError.posixFailure(operation: "chmod", code: errno)
        }
    }
}
