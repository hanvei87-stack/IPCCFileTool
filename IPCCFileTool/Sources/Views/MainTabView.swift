import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            StatusView()
                .tabItem {
                    Label("Status", systemImage: "bolt")
                }

            FileRootView()
                .tabItem {
                    Label("Files", systemImage: "folder")
                }

            LockedPermissionsView()
                .tabItem {
                    Label("Locks", systemImage: "lock")
                }

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
    }
}
