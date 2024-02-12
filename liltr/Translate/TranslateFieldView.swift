import SwiftUI
import SwiftData
import Combine
import UniformTypeIdentifiers

struct TranslateFieldView: View {
    @Binding var text: String
    var placeholder: String = ""
    var onChange: (() -> Void)?
    var readOnly: Bool = false
    var maxLength: Int = 5000

    @FocusState private var focused: Bool
    @State private var triggered = false
    let debouncer = PassthroughSubject<String, Never>()

    private let fontSize = CGFloat(14)
    private let paddingSize = CGFloat(10)

    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: readOnly ? .constant(text) : $text)
                    .font(.system(size: fontSize))
                    .scrollContentBackground(.hidden)
                    .padding(EdgeInsets(top: 0, leading: paddingSize, bottom: 0, trailing: paddingSize))
                    .onReceive(debouncer.debounce(for: .milliseconds(triggered ? 300 : 500), scheduler: RunLoop.main)) { _ in
                        onChange?()
                    }
                    .onChange(of: text) {
                        if text.isEmpty {
                            triggered = false
                        } else if !triggered && CharacterSet.whitespacesAndNewlines.contains(text.last!.unicodeScalars.first!) {
                            triggered = true

                        }
                        debouncer.send(text)
                    }
                    .focused($focused)
                    .bottomFade()
                    .onAppear {
                        if !readOnly {
                            focused = true
                        }
                    }
                    .onReceive(Just(text)) { _ in
                        if text.count > maxLength && !readOnly {
                            text = String(text.prefix(maxLength))
                        }
                    }

                if !readOnly && !text.isEmpty {
                    Image(systemName: "xmark.circle.fill")
                        .onTapGesture {
                            text = ""
                            onChange?()
                        }
                        .foregroundStyle(.primary.opacity(0.6))
                        .padding(EdgeInsets(top: 0, leading: paddingSize, bottom: 0, trailing: paddingSize))
                }
            }

            if text.isEmpty && !placeholder.isEmpty {
                TextEditor(text: .constant(placeholder))
                    .font(.system(size: fontSize))
                    .foregroundColor(.secondary)
                    .scrollContentBackground(.hidden)
                    .padding(EdgeInsets(top: 0, leading: paddingSize, bottom: 0, trailing: paddingSize))
                    .disabled(/*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
            }
        }
    }
}
