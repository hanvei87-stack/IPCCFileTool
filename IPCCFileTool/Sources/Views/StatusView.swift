import SwiftUI

struct StatusView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    var body: some View {
        NavigationView {
            List {
                Section("File Access") {
                    HStack {
                        Text("State")
                        Spacer()
                        Text(accessSession.isReady ? "Ready" : "Not initialized")
                            .foregroundStyle(accessSession.isReady ? .green : .secondary)
                    }

                    Button("Initialize") {
                        accessSession.initializeAccess()
                    }
                }

                Section("Permission Locks") {
                    HStack {
                        Text("Locked items")
                        Spacer()
                        Text("\(accessSession.locks.count)")
                    }

                    Button("Restore Locked Modes") {
                        accessSession.applyLockedPermissions()
                    }
                    .disabled(!accessSession.isReady)
                }
            }
            .navigationTitle("Status")
        }
    }
}
