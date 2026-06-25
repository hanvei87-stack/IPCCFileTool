import SwiftUI

struct PermissionGroupView: View {
    let title: String
    @Binding var read: Bool
    @Binding var write: Bool
    @Binding var execute: Bool

    var body: some View {
        Section(title) {
            Toggle("读", isOn: $read)
            Toggle("写", isOn: $write)
            Toggle("执行", isOn: $execute)
        }
    }
}
