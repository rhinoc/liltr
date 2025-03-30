import SwiftUI

class TabPane: Identifiable {
    public let label: String
    public let icon: String
    public let view: AnyView

    init(label: String, icon: String, view: AnyView) {
        self.label = label
        self.icon = icon
        self.view = view
    }
}

public struct TopTabView: View {
    private let tabPanes: [TabPane]

    private let sizeHolder = SizeHolder()

    @State private var activeTabLabel: String

    init(tabPanes: [TabPane], defaultActiveTabLabel: String? = nil) {
        self.tabPanes = tabPanes
        activeTabLabel = defaultActiveTabLabel ?? tabPanes.first!.label
    }

    public var tabBar: some View {
        HStack(spacing: CGFloat(sizeHolder.outerGapSize)) {
            Spacer()
            ForEach(tabPanes) { tabPane in
                TabItem(label: tabPane.label, icon: tabPane.icon, active: tabPane.label == activeTabLabel)
                    .onTapGesture(perform: {
                        self.activeTabLabel = tabPane.label
                    })
            }
            Spacer()
        }
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
            VStack(alignment: .leading) {
                tabBar
                Spacer()
                    .frame(height: CGFloat(sizeHolder.outerGapSize))
                Divider()
                if let tabPane = tabPanes.first(where: { $0.label == activeTabLabel }) {
                    tabPane.view
                }
            }
        }
    }
}

#Preview {
    VStack {
        let tab1 = TabPane(label: "tab1", icon: "1.square.fill", view: AnyView(Image(systemName: "1.square.fill")))
        let tab2 = TabPane(label: "tab2", icon: "2.square.fill", view: AnyView(Image(systemName: "2.square.fill")))
        let tab3 = TabPane(label: "tab3", icon: "3.square.fill", view: AnyView(Image(systemName: "3.square.fill")))
        VStack {
            TopTabView(tabPanes: [tab1, tab2, tab3], defaultActiveTabLabel: "tab2")
        }
    }
}
