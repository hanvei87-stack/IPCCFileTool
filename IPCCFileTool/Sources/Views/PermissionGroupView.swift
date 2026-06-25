import SwiftUI

struct PermissionGroupView: View {
    let title: String
    @Binding var read: Bool
    @Binding var write: Bool
    @Binding var execute: Bool

    var body: some View {
        Section(title) {
            Toggle("Read", isOn: $read)
            Toggle("Write", isOn: $write)
            Toggle("Execute", isOn: $execute)
        }
    }
}
