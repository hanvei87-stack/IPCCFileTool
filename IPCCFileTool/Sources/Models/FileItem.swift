import Foundation

struct FileItem: Identifiable, Hashable {
    let url: URL
    let isDirectory: Bool
    let permissions: FilePermissions
    let ownerName: String
    let groupName: String

    var id: String { url.path }
    var name: String { url.lastPathComponent.isEmpty ? url.path : url.lastPathComponent }
}
