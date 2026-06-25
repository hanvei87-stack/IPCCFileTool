import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    var body: some View {
        NavigationView {
            List {
                Section("Log") {
                    LogView(lines: accessSession.logLines)
                }

                Section("IPCC") {
                    Toggle("5G+", isOn: .constant(false))
                    Toggle("Standalone 5G", isOn: .constant(false))
                    Toggle("VoNR", isOn: .constant(false))
                    Button("Initialize and Restore Locks") {
                        accessSession.initializeAccess()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Section("Tools") {
                    Button("Restart Cellular Network") {
                        accessSession.restartNetwork()
                    }
                    Button("Cleanup and Restore Defaults") {
                        accessSession.resetDefaults()
                    }
                }
            }
            .navigationTitle("IPCC Tool")
        }
    }
}
