import SwiftUI

public extension Color {
#if os(macOS)
    static let backgroundColor = Color(NSColor.windowBackgroundColor)
    static let secondaryBackground = Color(NSColor.underPageBackgroundColor)
    static let tertiaryBackground = Color(NSColor.controlBackgroundColor)
#else
    static let backgroundColor = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
#endif
}

extension Color {
    var hexString: String {
        let components = self.cgColor?.components
        let r = components?[0] ?? 0
        let g = components?[1] ?? 0
        let b = components?[2] ?? 0
        let a = self.cgColor?.alpha ?? 1

        let hexString = String(format: "#%02X%02X%02X%02X", (Int)(r * 255), (Int)(g * 255), (Int)(b * 255), (Int)(a * 255))
        return hexString
    }
}

extension String: Error {}

extension StringProtocol {

    var byLines: [SubSequence] { components(separated: .byLines) }
    var byWords: [SubSequence] { components(separated: .byWords) }

    func components(separated options: String.EnumerationOptions) -> [SubSequence] {
        var components: [SubSequence] = []
        enumerateSubstrings(in: startIndex..., options: options) { _, range, _, _ in components.append(self[range]) }
        return components
    }

    var firstWord: SubSequence? {
        var word: SubSequence?
        enumerateSubstrings(in: startIndex..., options: .byWords) { _, range, _, stop in
            word = self[range]
            stop = true
        }
        return word
    }
    var firstLine: SubSequence? {
        var line: SubSequence?
        enumerateSubstrings(in: startIndex..., options: .byLines) { _, range, _, stop in
            line = self[range]
            stop = true
        }
        return line
    }
}

extension View {
    func bottomFade(fadeLength: CGFloat = 20) -> some View {
        return mask(
            VStack(spacing: 0) {

                Rectangle().fill(Color.backgroundColor)

                LinearGradient(gradient: Gradient(
                    colors: [Color.backgroundColor.opacity(0), Color.backgroundColor]),
                               startPoint: .bottom, endPoint: .top
                )
                .frame(height: fadeLength)
            }
        )
    }
}

extension View {
    public func cursor(_ cursor: NSCursor) -> some View {
        if #available(macOS 13.0, *) {
            return self.onContinuousHover { phase in
                switch phase {
                case .active:
                    cursor.push()
                case .ended:
                    NSCursor.pop()
                }
            }
        } else {
            return self.onHover { inside in
                if inside {
                    cursor.push()
                } else {
                    NSCursor.pop()
                }
            }
        }
    }
}

// extension WindowGroup {
//   init<W: Identifiable, C: View>(_ titleKey: LocalizedStringKey, uniqueWindow: W, @ViewBuilder content: @escaping () -> C)
//   where W.ID == String, Content == PresentedWindowContent<String, C> {
//      self.init(titleKey, id: uniqueWindow.id, for: String.self) { _ in
//         content()
//      } defaultValue: {
//         uniqueWindow.id
//      }
//   }
// }
//
// extension OpenWindowAction {
//   func callAsFunction<W: Identifiable>(_ window: W) where W.ID == String {
//      self.callAsFunction(id: window.id, value: window.id)
//   }
// }
