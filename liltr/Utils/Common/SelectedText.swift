import Carbon.HIToolbox
import Foundation

class SelectedTextManager {
    public static let shared = SelectedTextManager()

    func getText(_ completion: @escaping (String?, Error?) -> Void) {
        let textByAX = _getByAX()
        debugPrint("[SelectedTextManager#_getByAX] ->", textByAX)
        if textByAX != nil, !textByAX!.isEmpty {
            completion(textByAX, nil)
            return
        }

        _getByAppleScript { textByAS, _ in
            debugPrint("[SelectedTextManager#_getByAppleScript] ->", textByAS)
            if textByAS != nil, !textByAX!.isEmpty {
                completion(textByAS, nil)
                return
            }
        }

        _getByCopy { textByCopy, error in
            debugPrint("[SelectedTextManager#_getByCopy] ->", textByCopy)
            completion(textByCopy, error)
        }
    }

    private func _getByAX() -> String? {
        let systemWideElement = AXUIElementCreateSystemWide()

        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        var selectedTextValue: AnyObject?
        let errorCode = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &selectedTextValue)

        if errorCode == .success {
            let selectedTextElement = selectedTextValue as! AXUIElement
            var selectedText: AnyObject?
            let textErrorCode = AXUIElementCopyAttributeValue(selectedTextElement, kAXSelectedTextAttribute as CFString, &selectedText)

            if textErrorCode == .success, let selectedTextString = selectedText as? String {
                return selectedTextString
            } else {
                debugPrint("[getSelectedText] AXUIElementCopyAttributeValue errorCode invalid:", textErrorCode)
                return nil
            }
        } else {
            debugPrint("[getSelectedText] errorCode invalid:", errorCode.rawValue.description)
            return nil
        }
    }

    private func _getByAppleScript(_ completion: @escaping (String?, Error?) -> Void) {
        let bundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? ""
        func isSafari(_ bundleId: String) -> Bool {
            return bundleId == "com.apple.Safari"
        }

        func isChromium(_ bundleId: String) -> Bool {
            return bundleId == "com.google.Chrome" || bundleId == "com.microsoft.edgemac"
        }

        if isSafari(bundleID) {
            let source = """
                tell application id "\(bundleID)"
                    tell front document
                        set selection_text to do JavaScript "window.getSelection().toString();"
                    end tell
                end tell
            """
            executeAppleScript(source, completion: completion)
        } else if isChromium(bundleID) {
            let source = """
                tell application id "\(bundleID)"
                    tell active tab of front window
                        set selection_text to execute javascript "window.getSelection().toString();"
                    end tell
                end tell
            """
            executeAppleScript(source, completion: completion)
        } else {
            completion(nil, nil)
        }
    }

    // https://stackoverflow.com/a/49502614
    private func _getByCopy(_ completion: @escaping (String?, Error?) -> Void) {
        let oldChangeCount = PasteboardManager.shared.changeCount
        let oldText = PasteboardManager.shared.content
        let src = CGEventSource(stateID: .combinedSessionState)!
        let cKeyCode: CGKeyCode = 0x08
        let keyDownEvent = CGEvent(keyboardEventSource: src, virtualKey: cKeyCode, keyDown: true)
        keyDownEvent?.flags = .maskCommand
        let keyUpEvent = CGEvent(keyboardEventSource: src, virtualKey: cKeyCode, keyDown: false)
        keyDownEvent?.post(tap: .cghidEventTap)
        keyUpEvent?.post(tap: .cghidEventTap)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { // wait 0.05s for copy.
            let newChangeCount = PasteboardManager.shared.changeCount
            let newText = PasteboardManager.shared.content

            if oldChangeCount == newChangeCount {
                // indicate last copy trigger has failed
                completion(nil, nil)
                return
            }

            PasteboardManager.shared.copy(oldText)
            completion(newText, nil)
        }
    }
}
