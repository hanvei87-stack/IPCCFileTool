import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("主页", systemImage: "house")
                }

            StatusView()
                .tabItem {
                    Label("状态", systemImage: "bolt")
                }

            FileRootView()
                .tabItem {
                    Label("文件", systemImage: "folder")
                }

            LockedPermissionsView()
                .tabItem {
                    Label("锁定", systemImage: "lock")
                }

            AboutView()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
        }
    }
}
