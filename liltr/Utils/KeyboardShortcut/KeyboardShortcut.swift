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
