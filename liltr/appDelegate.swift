import AppKit
import UserNotifications
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let content = response.notification.request.content
        if content.categoryIdentifier == "translate" {
            switch response.actionIdentifier {
            case "copy":
                PasteboardManager.shared.copy(content.body)
                break
            case "speak":
                let language = LanguageManager.getLanguageByContent(content.body)
                SpeechManager.start(content.body, language)
                break
            case "expand":
                NSWorkspace.shared.open(SchemeURLManager.getUrlByAction(SchemeAction.translateInWindow, querys: ["src": content.title]))
                break
            default:
                break
            }
        }
        completionHandler()
    }
}
