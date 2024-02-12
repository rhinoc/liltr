import SwiftUI

struct ToolbarItem: View {
    var systemName: String
    var action: () -> Void

    @State var hovering: Bool = false

    var body: some View {
        Button(action: action, label: {
            Image(systemName: systemName)
        })
        .buttonStyle(.plain)
        .foregroundColor(hovering ? .primary : .secondary)
        .onHover(perform: { hovering in
            self.hovering = hovering
        })
    }
}
