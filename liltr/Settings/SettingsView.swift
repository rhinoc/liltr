import SwiftUI
import SwiftData
import Sparkle

struct SettingsView: View {
    private let _updater: SPUUpdater

    init(updater: SPUUpdater) {
        self._updater = updater
    }

    private func _handleIncomingURL(_ url: URL) {
        guard url.scheme == APP_NAME else {
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        let action = components.host
        guard action == SchemeAction.settings.rawValue else {
            return
        }
    }

    var body: some View {
        VStack {
            let generalTabPane = TabPane(label: "General", icon: "gear", view: AnyView(GeneralView()))
            let providersTabPane = TabPane(label: "Providers", icon: "cube.box", view: AnyView(ProvidersView()))
            let aboutTabPane = TabPane(label: "About", icon: "info.circle", view: AnyView(AboutView(updater: _updater)))
            VStack(alignment: .center) {
                Spacer()
                    .frame(height: 6)
                Text("Settings")
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 6)
            }

            TopTabView(tabPanes: [generalTabPane, providersTabPane, aboutTabPane])
        }
        .foregroundColor(.secondary)
        .edgesIgnoringSafeArea(.all)
        .onOpenURL(perform: { url in
            _handleIncomingURL(url)
        })
    }
}
