import UserNotifications

func pushNotification(title: String, body: String) {
    let categoryIdentifier = "translate"
    let center = UNUserNotificationCenter.current()
    center.getNotificationSettings { (settings) in
        if settings.authorizationStatus == .authorized {
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = categoryIdentifier

            let copy = UNNotificationAction(identifier: "copy", title: "Copy")
            let speak = UNNotificationAction(identifier: "speak", title: "Speak")
            let expand = UNNotificationAction(identifier: "expand", title: "Expand", options: [.foreground])
            let category = UNNotificationCategory(identifier: categoryIdentifier, actions: [copy, speak, expand], intentIdentifiers: [])
            center.setNotificationCategories([category])

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                debugPrint("[pushNotification] request for authorization", success, error)
            }
        }
    }
}
