import Foundation

struct FilePermissions: Equatable, Hashable {
    var userRead: Bool
    var userWrite: Bool
    var userExecute: Bool
    var groupRead: Bool
    var groupWrite: Bool
    var groupExecute: Bool
    var otherRead: Bool
    var otherWrite: Bool
    var otherExecute: Bool

    init(mode: Int) {
        userRead = mode & 0o400 != 0
        userWrite = mode & 0o200 != 0
        userExecute = mode & 0o100 != 0
        groupRead = mode & 0o040 != 0
        groupWrite = mode & 0o020 != 0
        groupExecute = mode & 0o010 != 0
        otherRead = mode & 0o004 != 0
        otherWrite = mode & 0o002 != 0
        otherExecute = mode & 0o001 != 0
    }

    var mode: Int {
        var value = 0
        if userRead { value |= 0o400 }
        if userWrite { value |= 0o200 }
        if userExecute { value |= 0o100 }
        if groupRead { value |= 0o040 }
        if groupWrite { value |= 0o020 }
        if groupExecute { value |= 0o010 }
        if otherRead { value |= 0o004 }
        if otherWrite { value |= 0o002 }
        if otherExecute { value |= 0o001 }
        return value
    }

    var octalString: String {
        String(format: "%04o", mode)
    }
}
