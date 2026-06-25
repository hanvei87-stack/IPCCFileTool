import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationView {
            List {
                Section("App") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text("IPCC Tool")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Design") {
                    Text("This is an original file and IPCC utility scaffold. File browsing, folder creation, permission saving, and permission locks all use one shared access session.")
                }
            }
            .navigationTitle("About")
        }
    }
}
