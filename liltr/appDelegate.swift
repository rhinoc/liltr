import AppKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(_: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        if content.categoryIdentifier == "translate" {
            switch response.actionIdentifier {
            case "copy":
                PasteboardManager.shared.copy(content.body)
            case "speak":
                let language = LanguageManager.getLanguageByContent(content.body)
                SpeechManager.start(content.body, language)
            case "expand":
                NSWorkspace.shared.open(SchemeURLManager.getUrlByAction(SchemeAction.translateInWindow, querys: ["src": content.title]))
            default:
                break
            }
        }
        completionHandler()
    }
}
