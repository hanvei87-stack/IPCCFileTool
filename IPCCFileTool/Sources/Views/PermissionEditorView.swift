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
        NavigationStack {
            Form {
                Section("Permission") {
                    HStack {
                        Text("Mode")
                        Spacer()
                        Text(permissions.octalString)
                    }
                    HStack {
                        Text("Owner")
                        Spacer()
                        Text(item.ownerName)
                    }
                    HStack {
                        Text("Group")
                        Spacer()
                        Text(item.groupName)
                    }
                }

                PermissionGroupView(title: "User", read: $permissions.userRead, write: $permissions.userWrite, execute: $permissions.userExecute)
                PermissionGroupView(title: "Group", read: $permissions.groupRead, write: $permissions.groupWrite, execute: $permissions.groupExecute)
                PermissionGroupView(title: "Other", read: $permissions.otherRead, write: $permissions.otherWrite, execute: $permissions.otherExecute)

                Section("Lock") {
                    Button("Save and Lock Mode") {
                        saveAndLock()
                    }
                    Text("A locked mode is saved by this app and restored whenever the file access session is initialized.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(item.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
        .alert("Notice", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("Guide") {
                showingGuide = true
            }
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        .sheet(isPresented: $showingGuide) {
            PermissionSaveGuideView(
                path: item.url.path,
                currentMode: item.permissions.octalString,
                targetMode: permissions.octalString,
                reason: guideReason ?? alertMessage ?? "Permission save failed"
            )
        }
    }

    private func save() {
        do {
            try accessSession.savePermissions(permissions, at: item.url)
            dismiss()
        } catch {
            guideReason = error.localizedDescription
            alertMessage = "\(error.localizedDescription)\n\nInitialize file access, then try saving again."
        }
    }

    private func saveAndLock() {
        do {
            try accessSession.saveAndLockPermissions(permissions, at: item.url)
            dismiss()
        } catch {
            guideReason = error.localizedDescription
            alertMessage = "\(error.localizedDescription)\n\nThe lock is only useful after this mode can be applied at least once."
        }
    }
}
