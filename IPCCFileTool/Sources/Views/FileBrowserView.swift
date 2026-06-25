import SwiftUI

struct FileBrowserView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    let rootURL: URL

    @State private var items: [FileItem] = []
    @State private var alertMessage: String?
    @State private var newFolderName = ""
    @State private var showingNewFolder = false
    @State private var selectedItem: FileItem?

    var body: some View {
        List(items) { item in
            HStack {
                Image(systemName: item.isDirectory ? "folder.fill" : "doc.fill")
                    .foregroundStyle(item.isDirectory ? .blue : .secondary)

                if item.isDirectory {
                    NavigationLink(item.name) {
                        FileBrowserView(rootURL: item.url)
                    }
                } else {
                    Text(item.name)
                }

                Spacer()

                Button {
                    selectedItem = item
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(rootURL.lastPathComponent.isEmpty ? rootURL.path : rootURL.lastPathComponent)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingNewFolder = true
                } label: {
                    Image(systemName: "folder.badge.plus")
                }
            }
        }
        .task {
            reload()
        }
        .refreshable {
            reload()
        }
        .alert("提示", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
        .alert("新建文件夹", isPresented: $showingNewFolder) {
            TextField("文件夹名称", text: $newFolderName)
            Button("取消", role: .cancel) { newFolderName = "" }
            Button("创建") {
                createFolder()
            }
        }
        .sheet(item: $selectedItem) { item in
            PermissionEditorView(item: item)
        }
    }

    private func reload() {
        do {
            items = try accessSession.listDirectory(at: rootURL)
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    private func createFolder() {
        do {
            try accessSession.createDirectory(named: newFolderName, in: rootURL)
            newFolderName = ""
            reload()
        } catch {
            alertMessage = error.localizedDescription
        }
    }
}
