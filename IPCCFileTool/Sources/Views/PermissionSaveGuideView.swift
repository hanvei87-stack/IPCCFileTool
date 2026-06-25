import SwiftUI

struct PermissionSaveGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accessSession: FileAccessSession

    let path: String
    let currentMode: String
    let targetMode: String
    let reason: String

    @State private var stepResults: [Int: String] = [:]
    @State private var diagnostics = PermissionDiagnostics.empty

    var body: some View {
        NavigationView {
            List {
                Section("失败原因") {
                    Text(reason)
                    Text(path)
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Section("诊断信息") {
                    DiagnosticRow(title: "当前权限", value: diagnostics.mode ?? currentMode)
                    DiagnosticRow(title: "目标权限", value: targetMode)
                    DiagnosticRow(title: "路径存在", value: diagnostics.existsText)
                    DiagnosticRow(title: "目录", value: diagnostics.directoryText)
                    DiagnosticRow(title: "符号链接", value: diagnostics.symlinkText)
                    DiagnosticRow(title: "可读", value: diagnostics.readableText)
                    DiagnosticRow(title: "可写", value: diagnostics.writableText)
                    DiagnosticRow(title: "可执行", value: diagnostics.executableText)
                    DiagnosticRow(title: "父目录可写", value: diagnostics.parentWritableText)
                    DiagnosticRow(title: "最后错误", value: diagnostics.errorText)
                }

                Section("下一步") {
                    StepActionRow(
                        number: 1,
                        title: "初始化文件访问",
                        detail: "文件浏览和权限保存必须共用同一个访问会话。",
                        result: stepResults[1],
                        actionTitle: accessSession.isReady ? "已就绪" : "初始化"
                    ) {
                        accessSession.initializeAccess()
                        stepResults[1] = accessSession.isReady ? "已初始化" : "初始化失败"
                    }

                    StepActionRow(
                        number: 2,
                        title: "检查当前路径",
                        detail: "确认当前进程可以看到这个路径。",
                        result: stepResults[2],
                        actionTitle: "检查"
                    ) {
                        let nextDiagnostics = PermissionDiagnostics(path: path)
                        diagnostics = nextDiagnostics
                        stepResults[2] = nextDiagnostics.exists ? "路径存在，权限 \(nextDiagnostics.mode ?? "-")" : "路径不存在"
                    }

                    StepActionRow(
                        number: 3,
                        title: "检查写入权限",
                        detail: "确认当前进程是否已经拥有写入权限。",
                        result: stepResults[3],
                        actionTitle: "检查"
                    ) {
                        let nextDiagnostics = PermissionDiagnostics(path: path)
                        diagnostics = nextDiagnostics
                        stepResults[3] = nextDiagnostics.parentWritable ? "父目录可写，可以重试保存。" : "父目录不可写，需要合法 helper 或授权环境。"
                    }

                    StepActionRow(
                        number: 4,
                        title: "返回保存",
                        detail: "关闭本页后，在权限编辑页重新保存。",
                        result: stepResults[4],
                        actionTitle: "完成"
                    ) {
                        stepResults[4] = "请返回权限编辑页重试。"
                        dismiss()
                    }
                }

                Section("仍然失败") {
                    Text("如果错误是 Operation not permitted 或 Permission denied，说明该路径超出当前应用进程权限。普通自签应用不能直接修改受保护的系统目录，需要合法 helper、企业/MDM 授权环境，或你本来就拥有权限的可写路径。")
                }
            }
            .navigationTitle("保存说明")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            refreshDiagnostics()
        }
    }

    private func refreshDiagnostics() {
        diagnostics = PermissionDiagnostics(path: path)
    }
}

private struct PermissionDiagnostics {
    var exists = false
    var isDirectory = false
    var isSymlink = false
    var readable = false
    var writable = false
    var executable = false
    var parentWritable = false
    var mode: String?
    var error: String?

    static let empty = PermissionDiagnostics()

    init() {}

    init(path: String) {
        let fileManager = FileManager.default
        var directoryFlag: ObjCBool = false
        exists = fileManager.fileExists(atPath: path, isDirectory: &directoryFlag)
        isDirectory = directoryFlag.boolValue
        readable = fileManager.isReadableFile(atPath: path)
        writable = fileManager.isWritableFile(atPath: path)
        executable = fileManager.isExecutableFile(atPath: path)

        let parentPath = isDirectory ? path : (path as NSString).deletingLastPathComponent
        parentWritable = fileManager.isWritableFile(atPath: parentPath)

        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            if let posix = attributes[.posixPermissions] as? Int {
                mode = String(format: "%04o", posix)
            }
            if let type = attributes[.type] as? FileAttributeType {
                isSymlink = type == .typeSymbolicLink
            }
        } catch {
            self.error = error.localizedDescription
        }
    }

    var existsText: String { exists ? "是" : "否" }
    var directoryText: String { isDirectory ? "是" : "否" }
    var symlinkText: String { isSymlink ? "是" : "否" }
    var readableText: String { readable ? "是" : "否" }
    var writableText: String { writable ? "是" : "否" }
    var executableText: String { executable ? "是" : "否" }
    var parentWritableText: String { parentWritable ? "是" : "否" }
    var errorText: String { error ?? "-" }
}

private struct DiagnosticRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

private struct StepActionRow: View {
    let number: Int
    let title: String
    let detail: String
    let result: String?
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .frame(width: 28, height: 28)
                .background(Color.accentColor.opacity(0.14))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let result {
                    Text(result)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(actionTitle, action: action)
                .buttonStyle(.bordered)
        }
        .padding(.vertical, 4)
    }
}
