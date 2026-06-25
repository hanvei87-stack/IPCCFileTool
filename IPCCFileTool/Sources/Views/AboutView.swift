import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("App") {
                    LabeledContent("Name", value: "IPCC Tool")
                    LabeledContent("Version", value: "1.0")
                }

                Section("Design") {
                    Text("This is an original file and IPCC utility scaffold. File browsing, folder creation, permission saving, and permission locks all use one shared access session.")
                }
            }
            .navigationTitle("About")
        }
    }
}
