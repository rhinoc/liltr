import SwiftUI
import SwiftData
import KeyboardShortcuts
import UserNotifications
import Sparkle

let APP_NAME = Bundle.main.infoDictionary!["APP_NAME"] as! String

@main
struct liltrApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Default(\.menuIconSymbol) var menuIconSymbol
    private let updaterController: SPUStandardUpdaterController

    init() {
        updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: nil, userDriverDelegate: nil)
    }

    var body: some Scene {
        MenuBarExtra {
            AppMenu()
        } label: {
            let imageDefinedByUser = NSImage(systemSymbolName: menuIconSymbol, accessibilityDescription: APP_NAME)
            let imageDefault: NSImage = {
                let ratio = $0.size.height / $0.size.width
                $0.size.height = 18
                $0.size.width = 18 / ratio
                return $0
            }(NSImage(named: "monochrome.fill")!)
            Image(nsImage: imageDefinedByUser ?? imageDefault)
        }

        Window("Translate", id: WindowID.translate.id) {
            TranslateView()
                .frame(minWidth: 220, minHeight: 300)
        }
        .defaultSize(width: 300, height: 500)
        .windowStyle(.hiddenTitleBar)
        .handlesExternalEvents(matching: Set(arrayLiteral: SchemeAction.translateInWindow.rawValue))

        Window("Settings", id: WindowID.settings.id) {
            SettingsView(updater: updaterController.updater)
                .ignoresSafeArea(edges: .top)
                .fixedSize()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .handlesExternalEvents(matching: Set(arrayLiteral: SchemeAction.settings.rawValue))
    }
}

struct AppMenu: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openURL) private var openURL
    @Default(\.hotKey) var hotKey
    @Default(\.ocrHotKey) var ocrHotKey
    @Default(\.primaryLanguage) var primaryLanguage
    @Default(\.hotKeyTriggerInNotification) var hotKeyTriggerInNotification
    @Default(\.preProcessSource) var preProcessSource

    private func _translateInNotification(text: String) {
        ProviderManager.shared.translate(text, LanguageManager.getLanguageByCode(primaryLanguage)!) { data in
            pushNotification(title: data.source, body: data.target)
        }
    }

    private func _gotoTranslate(text: String? = nil) {
        openURL(SchemeURLManager.getUrlByAction(SchemeAction.translateInWindow, querys: ["src": text ?? ""]))
    }

    private func _gotoSettings() {
        openURL(SchemeURLManager.getUrlByAction(SchemeAction.settings))
    }

    private func _quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: hotkey
    private func _onHotKeyTranslate() {
        SelectedTextManager.shared.getText { text, _ in
            if text != nil && !text!.isEmpty && Defaults.shared.hotKeyTriggerInNotification {
                _translateInNotification(text: text!)
            } else {
                _gotoTranslate(text: text ?? "")
            }
        }
    }

    private func _onHotKeyOCR() {
        OCRManager.shared.captureWithOCR { text in
            if Defaults.shared.hotKeyTriggerInNotification {
                _translateInNotification(text: text)
            } else {
                _gotoTranslate(text: text)
            }
        }
    }

    init() {
        KeyboardShortcuts.onKeyUp(for: .translate, action: _onHotKeyTranslate)
        KeyboardShortcuts.onKeyUp(for: .ocr, action: _onHotKeyOCR)
    }

    var body: some View {
        VStack {
            Button(action: _onHotKeyTranslate, label: { Text("Translate") })
                .keyboardShortcut(string2Shortcut(hotKey))

            Button(action: _onHotKeyOCR, label: { Text("OCR Translate") })
                .keyboardShortcut(string2Shortcut(ocrHotKey))

            Button(action: _gotoSettings, label: { Text("Settings...") })

            Divider()

            Toggle(isOn: $hotKeyTriggerInNotification, label: {
                Text("In-Notification Mode")
            }).toggleStyle(.checkbox)

            Toggle(isOn: $preProcessSource, label: {
                Text("Preprocess Source Text")
            }).toggleStyle(.checkbox)

            Divider()

            Button(action: _quit, label: { Text("Quit") })
                .keyboardShortcut("q")
        }
    }
}
