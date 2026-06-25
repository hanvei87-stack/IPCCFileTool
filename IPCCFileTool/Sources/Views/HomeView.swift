import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    var body: some View {
        NavigationView {
            List {
                Section("操作日志") {
                    LogView(lines: accessSession.logLines)
                }

                Section("IPCC") {
                    Toggle("5G+", isOn: .constant(false))
                    Toggle("独立 5G", isOn: .constant(false))
                    Toggle("5G 语音", isOn: .constant(false))
                    Button("初始化并恢复锁定权限") {
                        accessSession.initializeAccess()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("辅助工具") {
                    Button("重启蜂窝网络") {
                        accessSession.restartNetwork()
                    }
                    Button("清理并恢复默认") {
                        accessSession.resetDefaults()
                    }
                }
            }
            .navigationTitle("IPCC 工具")
        }
    }
}
