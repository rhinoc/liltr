import SwiftUI

struct TabItem: View {
    private let label: String
    private let icon: String
    private let active: Bool

    private let itemWidth = 81
    private let itemHeight = 50
    private let sizeHolder: SizeHolder

    @State private var hovering: Bool = false

    init(label: String, icon: String, active: Bool, sizeBase: Float? = nil) {
        self.label = label
        self.icon = icon
        self.active = active
        self.sizeHolder = SizeHolder(base: sizeBase)
    }

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: CGFloat(sizeHolder.iconSize)))
                .fontWeight(.semibold)
            Spacer()
                .frame(height: CGFloat(sizeHolder.innerGapSize))
            Text(label)
                .font(.system(size: CGFloat(sizeHolder.fontSize)))
                .fontWeight(.semibold)
        }
        .foregroundStyle(active ? .primary : .secondary)
        .frame(width: CGFloat(itemWidth), height: CGFloat(itemHeight))
        .background(getBackgroundColor())
        .clipShape(RoundedRectangle(cornerRadius: CGFloat(sizeHolder.radiusSize)))
        .onHover(perform: { hovering in
            self.hovering = hovering
        })
    }

    private func getBackgroundColor() -> Color {
        let colorActive = Color.secondary.opacity(0.18)
        let colorHover = Color.secondary.opacity(0.1)
        let colorDefault = Color.clear
        if self.active {
            return colorActive
        } else if self.hovering {
            return colorHover
        } else {
            return colorDefault
        }
    }
}

#Preview {
    HStack {
        TabItem(label: "General", icon: "gear", active: false)
        TabItem(label: "Providers", icon: "cube.box", active: true)
        TabItem(label: "About", icon: "info.circle", active: false)
    }
    .padding()
}
