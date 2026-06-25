import SwiftUI

struct PermissionEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var accessSession: FileAccessSession

    let item: FileItem

    @State private var permissions: FilePermissions
    @State private var alertMessage: String?
    @State private var guideReason: String?
    @State private var showingGuide = false

    init(item: FileItem) {
        self.item = item
        _permissions = State(initialValue: item.permissions)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("文件权限") {
                    HStack {
                        Text("权限")
                        Spacer()
                        Text(permissions.octalString)
                    }
                    HStack {
                        Text("所有者")
                        Spacer()
                        Text(item.ownerName)
                    }
                    HStack {
                        Text("组")
                        Spacer()
                        Text(item.groupName)
                    }
                }

                PermissionGroupView(title: "用户", read: $permissions.userRead, write: $permissions.userWrite, execute: $permissions.userExecute)
                PermissionGroupView(title: "组", read: $permissions.groupRead, write: $permissions.groupWrite, execute: $permissions.groupExecute)
                PermissionGroupView(title: "其他", read: $permissions.otherRead, write: $permissions.otherWrite, execute: $permissions.otherExecute)

                Section("锁定") {
                    Button("保存并锁定权限") {
                        saveAndLock()
                    }
                    Text("锁定后会保存目标权限，并在下次初始化文件访问时自动恢复。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                }
            }
        }
        .alert("提示", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("查看说明") {
                showingGuide = true
            }
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(isPresented: $showingGuide) {
            PermissionSaveGuideView(
                path: item.url.path,
                currentMode: item.permissions.octalString,
                targetMode: permissions.octalString,
                reason: guideReason ?? alertMessage ?? "权限保存失败"
            )
        }
    }

    private func save() {
        do {
            try accessSession.savePermissions(permissions, at: item.url)
            dismiss()
        } catch {
            guideReason = error.localizedDescription
            alertMessage = "\(error.localizedDescription)\n\n请先初始化文件访问，然后再尝试保存。"
        }
    }

    private func saveAndLock() {
        do {
            try accessSession.saveAndLockPermissions(permissions, at: item.url)
            dismiss()
        } catch {
            guideReason = error.localizedDescription
            alertMessage = "\(error.localizedDescription)\n\n需要至少成功应用一次权限，锁定记录才有意义。"
        }
    }
}
