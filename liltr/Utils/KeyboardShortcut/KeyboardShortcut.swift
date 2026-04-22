import AppKit
import KeyboardShortcuts
import SwiftUI

func string2Shortcut(_ str: String) -> KeyboardShortcut? {
    if str.count == 0 {
        return nil
    }

    var modifiers: SwiftUI.EventModifiers = []

    if str.contains("⌘") {
        modifiers.update(with: EventModifiers.command)
    }

    if str.contains("⌃") {
        modifiers.update(with: EventModifiers.control)
    }

    if str.contains("⌥") {
        modifiers.update(with: EventModifiers.option)
    }

    if str.contains("⇧") {
        modifiers.update(with: EventModifiers.shift)
    }

    if str.contains("⇪") {
        modifiers.update(with: EventModifiers.capsLock)
    }

    return KeyboardShortcut(KeyEquivalent(str.last!), modifiers: modifiers)
}

func withKeyboardShortcutsDisabled<T>(_ action: () -> T) -> T {
    KeyboardShortcuts.isEnabled = false
    let result = action()
    KeyboardShortcuts.isEnabled = true
    return result
}

final class HotkeyActionManager {
    static let shared = HotkeyActionManager()

    private var isRegistered = false

    private init() {}

    func register() {
        guard !isRegistered else {
            return
        }

        KeyboardShortcuts.onKeyUp(for: .translate) {
            HotkeyActionManager.shared.handleTranslate()
        }

        KeyboardShortcuts.onKeyUp(for: .ocr) {
            HotkeyActionManager.shared.handleOCR()
        }

        KeyboardShortcuts.onKeyUp(for: .ocrOnly) {
            HotkeyActionManager.shared.handleOCROnly()
        }

        isRegistered = true
    }

    func handleTranslate() {
        withKeyboardShortcutsDisabled {
            SelectedTextManager.shared.getText { text, _ in
                if let text, !text.isEmpty, Defaults.shared.hotKeyTriggerInNotification {
                    self.translateInNotification(text: text)
                } else {
                    self.openTranslate(text: text ?? "")
                }
            }
        }
    }

    func handleOCR() {
        withKeyboardShortcutsDisabled {
            OCRManager.shared.captureWithOCR { text in
                if Defaults.shared.hotKeyTriggerInNotification {
                    self.translateInNotification(text: text)
                } else {
                    self.openTranslate(text: text)
                }
            }
        }
    }

    func handleOCROnly() {
        withKeyboardShortcutsDisabled {
            OCRManager.shared.captureWithOCR { text in
                PasteboardManager.shared.copy(text)
                pushNotification(title: "OCR Result Copied", body: text)
            }
        }
    }

    private func translateInNotification(text: String) {
        let sourceLanguage = LanguageManager.getLanguageByContent(text)
        let targetLanguage = LanguageManager.fixTargetLanguage(sourceLanguage: sourceLanguage, targetLanguage: LanguageManager.primaryLanguage)

        ProviderManager.shared.translate(text, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage) { data in
            pushNotification(title: data.source, body: data.target)
        }
    }

    private func openTranslate(text: String) {
        NSWorkspace.shared.open(
            SchemeURLManager.getUrlByAction(
                SchemeAction.translateInWindow,
                querys: ["src": text]
            )
        )
    }
}
