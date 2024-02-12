import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TopBarView: View {
    @Environment(\.openWindow) private var openWindow
    @Default(\.floatOnTop) var floatOnTop

    var body: some View {
        HStack {
            Spacer()
            ToolbarItem(systemName: "gearshape", action: {
                WindowManager.open(openWindow: openWindow, id: .settings)
            })
            ToolbarItem(systemName: floatOnTop ? "pin.fill" : "pin", action: {
                floatOnTop = !floatOnTop
                float()
            })
        }
        .padding(EdgeInsets(top: 1, leading: 100, bottom: 0, trailing: 0))
        .onAppear {
            float()
        }
    }

    func float() {
        WindowManager.float(id: .translate, enable: floatOnTop)
    }

}

#Preview("TopBar", traits: .fixedLayout(width: 300, height: 200)) {
    TopBarView()
}
