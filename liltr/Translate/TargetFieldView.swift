import Combine
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct TargetFieldView: View {
    @Binding var text: String
    var maxLength: Int = 5000

    @FocusState private var focused: Bool
    @State private var triggered = false

    private let fontSize = CGFloat(14)
    private let paddingSize = CGFloat(10)

    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: .constant(text))
                    .font(.system(size: fontSize))
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.never)
                    .padding(EdgeInsets(top: 0, leading: paddingSize, bottom: 0, trailing: paddingSize))
                    .focused($focused)
                    .bottomFade()
            }
        }
    }
}
