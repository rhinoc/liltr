import Foundation
import SwiftUI

enum WindowID: String, Identifiable {
    case translate
    case settings

    var id: String { self.rawValue }
}

class WindowManager {
    static func getById(_ id: WindowID) -> NSWindow? {
        let window = NSApp.windows.first(where: { $0.identifier?.rawValue == id.rawValue})
        if window == nil {
            debugPrint("[WindowManager] get window \(id) failed")
        }
        return window
    }

    static func float(id: WindowID, enable: Bool) {
        let window = getById(id)
        if window != nil {
            window!.level = enable ? .floating : .normal
        }
    }

    static func open(openWindow: OpenWindowAction, id: WindowID) {
        NSApplication.shared.activate(ignoringOtherApps: true)
        openWindow(id: id.rawValue)
        let window = getById(id)
        if window != nil {
            window!.makeKeyAndOrderFront(nil)
            window!.orderFrontRegardless()
            window!.setIsVisible(true)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
    }

    static func setSize(id: WindowID, width: CGFloat, height: CGFloat) {
        let window = getById(id)
        if window != nil {
            let origin = window!.frame.origin
            window!.setFrame(NSRect(x: origin.x, y: origin.y + window!.frame.height - height, width: width, height: height), display: true, animate: false)
        }
    }
}
