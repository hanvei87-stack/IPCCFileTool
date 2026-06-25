import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    var body: some View {
        NavigationView {
            List {
                Section("文件访问") {
                    HStack {
                        Text("状态")
                        Spacer()
                        Text(accessSession.isReady ? "已初始化" : "未初始化")
                            .foregroundStyle(accessSession.isReady ? .green : .secondary)
                    }

                    Button("初始化") {
                        accessSession.initializeAccess()
                    }
                }

                Section("权限锁定") {
                    HStack {
                        Text("锁定项目")
                        Spacer()
                        Text("\(accessSession.locks.count)")
                    }

                    Button("恢复锁定权限") {
                        accessSession.applyLockedPermissions()
                    }
                    .disabled(!accessSession.isReady)
                }
            }
            .navigationTitle("状态")
        }
    }
}
