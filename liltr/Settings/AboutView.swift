import Sparkle
import SwiftUI

final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}

struct AboutView: View {
    @ObservedObject private var _checkForUpdatesViewModel: CheckForUpdatesViewModel
    private let _gapSize: CGFloat = 8
    private let _updater: SPUUpdater

    init(updater: SPUUpdater) {
        _updater = updater
        _checkForUpdatesViewModel = CheckForUpdatesViewModel(updater: updater)
    }

    var body: some View {
        VStack(alignment: .center) {
            Spacer()
                .frame(height: _gapSize * 2)

            HStack(alignment: .center) {
                Image(nsImage: NSImage(named: "AppIcon")!)
                    .resizable()
                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: 100)

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(APP_NAME)")
                        .font(.system(size: 18))
                        .fontWeight(/*@START_MENU_TOKEN@*/ .bold/*@END_MENU_TOKEN@*/)
                        .foregroundStyle(.primary)

                    VStack(alignment: .leading) {
                        Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
                            .foregroundStyle(.primary)
                        Spacer()
                        Text("© rhinoc")
                        Text("2023-2024. All Rights Reserved.")
                    }
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                .frame(height: 80)
            }

            Divider()
                .padding(EdgeInsets(top: _gapSize, leading: 0, bottom: _gapSize, trailing: 0))

            HStack {
                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Text("Acknowledgements")
                })

                Spacer()

                Button(action: /*@START_MENU_TOKEN@*/ {}/*@END_MENU_TOKEN@*/, label: {
                    Text("Visit Website")
                })

                Button(action: {
                    try! _updater.start()
                    _updater.checkForUpdates()
                }, label: {
                    Text("Check Updates...")
                })
            }
            .padding(EdgeInsets(top: 0, leading: _gapSize, bottom: 0, trailing: _gapSize))
            .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
        }
        .frame(width: 450, height: 140)
    }
}
