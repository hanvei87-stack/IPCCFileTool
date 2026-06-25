import SwiftUI

struct LockedPermissionsView: View {
    @EnvironmentObject private var accessSession: FileAccessSession

    var body: some View {
        NavigationView {
            List {
                Section {
                    Button {
                        if !accessSession.isReady {
                            accessSession.initializeAccess()
                        } else {
                            accessSession.applyLockedPermissions()
                        }
                    } label: {
                        Label("Restore Locked Modes", systemImage: "lock.rotation")
                    }
                }

                Section("Locked Items") {
                    if accessSession.locks.isEmpty {
                        Text("No locked permissions yet.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(accessSession.locks) { lock in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(lock.modeString)
                                        .font(.system(.body, design: .monospaced))
                                    Spacer()
                                    if lock.lastError == nil {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                    } else {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundStyle(.orange)
                                    }
                                }

                                Text(lock.path)
                                    .font(.footnote.monospaced())
                                    .foregroundStyle(.secondary)
                                    .textSelection(.enabled)

                                if let lastAppliedAt = lock.lastAppliedAt {
                                    Text("Last applied: \(lastAppliedAt.formatted())")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                if let lastError = lock.lastError {
                                    Text(lastError)
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                        .onDelete { offsets in
                            for index in offsets {
                                accessSession.removeLock(accessSession.locks[index])
                            }
                        }
                    }
                }
            }
            .navigationTitle("Locks")
        }
    }
}
