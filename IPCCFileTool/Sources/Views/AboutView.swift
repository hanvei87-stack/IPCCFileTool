import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {
                Section("应用") {
                    HStack {
                        Text("名称")
                        Spacer()
                        Text("IPCC 工具")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("说明") {
                    Text("这是一个原创的文件与 IPCC 工具。文件浏览、新建文件夹、保存权限和权限锁定都共用同一个访问会话。")
                }
            }
            .navigationTitle("关于")
        }
    }
}
