import Foundation
import SwiftUI

struct LanguagePicker: View {
    @Binding var languageCode: String

    var withLabel: Bool

    var body: some View {
        Picker(selection: $languageCode) {
            ForEach(LANGUAGE_ARRAY, id: \.code) { language in
                Text("\(language.flag)\(withLabel ? " \(language.name)" : "")").tag(language.code)
            }
        } label: {}
            .frame(width: withLabel ? 130 : 50)
    }
}
