import Foundation

struct HelperFileRequest: Codable, Equatable {
    enum Operation: String, Codable {
        case listDirectory
        case createDirectory
        case readPermissions
        case savePermissions
    }

    var operation: Operation
    var path: String
    var name: String?
    var mode: Int?
}

struct HelperFileItem: Codable, Equatable {
    var path: String
    var isDirectory: Bool
    var mode: Int
    var ownerName: String
    var groupName: String

    func toFileItem() -> FileItem {
        FileItem(
            url: URL(fileURLWithPath: path),
            isDirectory: isDirectory,
            permissions: FilePermissions(mode: mode),
            ownerName: ownerName,
            groupName: groupName
        )
    }
}
