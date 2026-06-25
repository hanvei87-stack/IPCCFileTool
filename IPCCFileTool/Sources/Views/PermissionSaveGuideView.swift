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
        NavigationStack {
            List {
                Section("Failure") {
                    Text(reason)
                    Text(path)
                        .font(.footnote.monospaced())
                        .foregroundStyle(.secondary)
                        .textSelection(.enabled)
                }

                Section("Diagnostics") {
                    DiagnosticRow(title: "Current mode", value: diagnostics.mode ?? currentMode)
                    DiagnosticRow(title: "Target mode", value: targetMode)
                    DiagnosticRow(title: "Exists", value: diagnostics.existsText)
                    DiagnosticRow(title: "Directory", value: diagnostics.directoryText)
                    DiagnosticRow(title: "Symlink", value: diagnostics.symlinkText)
                    DiagnosticRow(title: "Readable", value: diagnostics.readableText)
                    DiagnosticRow(title: "Writable", value: diagnostics.writableText)
                    DiagnosticRow(title: "Executable", value: diagnostics.executableText)
                    DiagnosticRow(title: "Parent writable", value: diagnostics.parentWritableText)
                    DiagnosticRow(title: "Last error", value: diagnostics.errorText)
                }

                Section("Next Steps") {
                    StepActionRow(
                        number: 1,
                        title: "Initialize file access",
                        detail: "File browsing and permission saving must share the same access session.",
                        result: stepResults[1],
                        actionTitle: accessSession.isReady ? "Ready" : "Initialize"
                    ) {
                        accessSession.initializeAccess()
                        stepResults[1] = accessSession.isReady ? "Initialized" : "Initialization failed"
                    }

                    StepActionRow(
                        number: 2,
                        title: "Check current path",
                        detail: "Confirm this process can see the selected path.",
                        result: stepResults[2],
                        actionTitle: "Check"
                    ) {
                        let nextDiagnostics = PermissionDiagnostics(path: path)
                        diagnostics = nextDiagnostics
                        stepResults[2] = nextDiagnostics.exists ? "Path exists, mode \(nextDiagnostics.mode ?? "-")" : "Path does not exist"
                    }

                    StepActionRow(
                        number: 3,
                        title: "Check write access",
                        detail: "Confirm the current process already has write access.",
                        result: stepResults[3],
                        actionTitle: "Check"
                    ) {
                        let nextDiagnostics = PermissionDiagnostics(path: path)
                        diagnostics = nextDiagnostics
                        stepResults[3] = nextDiagnostics.parentWritable ? "Parent is writable. Retry saving." : "Parent is not writable. Use a lawful helper or authorized environment."
                    }

                    StepActionRow(
                        number: 4,
                        title: "Retry save",
                        detail: "Close this sheet and save again from the permission editor.",
                        result: stepResults[4],
                        actionTitle: "Done"
                    ) {
                        stepResults[4] = "Return to the permission editor and retry."
                        dismiss()
                    }
                }

                Section("Still Failing") {
                    Text("If the error is Operation not permitted or Permission denied, this path is outside the current app process privileges. A normal self-signed app cannot modify protected system directories directly. Use a lawful helper, enterprise/MDM authorization, or a path you already own.")
                }
            }
            .navigationTitle("Save Guide")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
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

    var existsText: String { exists ? "Yes" : "No" }
    var directoryText: String { isDirectory ? "Yes" : "No" }
    var symlinkText: String { isSymlink ? "Yes" : "No" }
    var readableText: String { readable ? "Yes" : "No" }
    var writableText: String { writable ? "Yes" : "No" }
    var executableText: String { executable ? "Yes" : "No" }
    var parentWritableText: String { parentWritable ? "Yes" : "No" }
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
