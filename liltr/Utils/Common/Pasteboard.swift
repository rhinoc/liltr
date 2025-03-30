import Carbon.HIToolbox
import Foundation

class PasteboardManager {
    public static let shared = PasteboardManager()

    private let _pasteboard = NSPasteboard.general

    var changeCount: Int {
        return _pasteboard.changeCount
    }

    var content: String {
        return NSPasteboard.general.readObjects(forClasses: [NSString.self], options: nil)?.first as? String ?? ""
    }

    func copy(_ string: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(string, forType: .string)
    }
}
