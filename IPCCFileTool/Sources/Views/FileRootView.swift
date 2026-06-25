import SwiftUI
import UniformTypeIdentifiers

struct FileRootView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    @State private var rootURL = URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true)
    @State private var scopedURL: URL?
    @State private var showingFolderPicker = false
    @State private var alertMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                RootStatusBar(
                    rootURL: rootURL,
                    isReady: accessSession.isReady,
                    onInitialize: {
                        accessSession.initializeAccess()
                    },
                    onPickFolder: {
                        showingFolderPicker = true
                    },
                    onUseSandbox: {
                        switchRoot(to: URL(fileURLWithPath: NSHomeDirectory(), isDirectory: true))
                    }
                )

                FileBrowserView(rootURL: rootURL)
            }
            .navigationTitle("文件")
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                switchRoot(to: url)
            case .failure(let error):
                alertMessage = error.localizedDescription
            }
        }
        .alert("提示", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func switchRoot(to url: URL) {
        if let scopedURL {
            scopedURL.stopAccessingSecurityScopedResource()
        }

        if url.startAccessingSecurityScopedResource() {
            scopedURL = url
        } else {
            scopedURL = nil
        }

        rootURL = url
        if !accessSession.isReady {
            accessSession.initializeAccess()
        }
    }
}

private struct RootStatusBar: View {
    let rootURL: URL
    let isReady: Bool
    let onInitialize: () -> Void
    let onPickFolder: () -> Void
    let onUseSandbox: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(isReady ? "已初始化" : "未初始化", systemImage: isReady ? "checkmark.circle.fill" : "exclamationmark.circle")
                    .foregroundStyle(isReady ? .green : .orange)

                Spacer()

                Button("初始化", action: onInitialize)
                    .buttonStyle(.bordered)
            }

            Text(rootURL.path)
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .textSelection(.enabled)

            HStack {
                Button {
                    onPickFolder()
                } label: {
                    Label("选择文件夹", systemImage: "folder.badge.plus")
                }
                .buttonStyle(.borderedProminent)

                Button {
                    onUseSandbox()
                } label: {
                    Label("沙盒目录", systemImage: "house")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}
