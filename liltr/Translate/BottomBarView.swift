import SwiftData
import SwiftUI
import UniformTypeIdentifiers

let PART_WIDTH: CGFloat = 80
let HEIGHT: CGFloat = 20

struct BottomBarView: View {
    @Binding var targetLanguageCode: String
    @Binding var isDictionaryMode: Bool
    @ObservedObject var provider = ProviderManager.shared

    var getCopyText: () -> String
    var getSpeechText: () -> String
    var onChangeProvider: () -> Void

    var itemSwitchProvider: some View {
        return ToolbarItem(systemName: provider.usePrimary ? "circle.grid.2x1.left.filled" : "circle.grid.2x1.right.filled") {
            provider.switchProvider()
            onChangeProvider()
        }
    }

    var itemDictionary: some View {
        return ToolbarItem(systemName: isDictionaryMode ? "escape" : "character.magnify") {
            isDictionaryMode = !isDictionaryMode
        }
    }

    var itemCopy: some View {
        return ToolbarItem(systemName: "square.on.square") {
            PasteboardManager.shared.copy(getCopyText())
        }
    }

    var itemSpeech: some View {
        return ToolbarItem(systemName: "speaker.2") {
            let text = getSpeechText()
            let language = LanguageManager.getLanguageByContent(text)
            SpeechManager.start(text, language)
        }
    }

    var body: some View {
        HStack {
            if isDictionaryMode {
                itemDictionary

                Spacer()

                HStack {
                    Spacer()
                    itemCopy
                    itemSpeech
                }
                .frame(width: PART_WIDTH)

            } else {
                // MARK: left

                HStack {
                    LanguagePicker(languageCode: $targetLanguageCode, withLabel: false)
                    Spacer()
                }
                .frame(width: PART_WIDTH)

                Spacer()

                // MARK: mid

                itemSwitchProvider

                Spacer()

                // MARK: right

                HStack {
                    Spacer()
                    itemDictionary
                    itemCopy
                    itemSpeech
                }
                .frame(width: PART_WIDTH)
            }
        }
        .frame(height: HEIGHT)
    }
}
