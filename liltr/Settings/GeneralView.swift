import SwiftUI
import WebKit
import KeyboardShortcuts
import ServiceManagement

struct AlignedText: View {
    let text: String
    let width: Float
    let alignment: Alignment

    init(text: String, width: Float = 135, alignment: Alignment = .trailing) {
        self.text = text
        self.width = width
        self.alignment = alignment
    }

    var body: some View {
        Text(text)
            .frame(width: CGFloat(width), alignment: alignment)
            .fontWeight(.semibold)
    }
}

struct GeneralView: View {
    @Default(\.launchAtLogin) var launchAtLogin
    @Default(\.hotKey) var hotKey
    @Default(\.ocrHotKey) var ocrHotKey
    @Default(\.hotKeyTriggerInNotification) var hotKeyTriggerInNotification
    @Default(\.primaryLanguage) var primaryLanguage
    @Default(\.secondaryLanguage) var secondaryLanguage
    @Default(\.menuIconSymbol) var menuIconSymbol
    @Default(\.preProcessSource) var preProcessSource

    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                AlignedText(text: "Startup")
                Toggle(isOn: $launchAtLogin, label: {
                    Text("Launch at Login")
                }).toggleStyle(.checkbox)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }
            }

            Spacer()
                .frame(height: 20)

            HStack {
                AlignedText(text: "Translate HotKey")
                KeyboardShortcuts.Recorder(for: .translate, onChange: onHotkeyChange)
            }

            HStack {
                AlignedText(text: "OCR HotKey")
                KeyboardShortcuts.Recorder(for: .ocr, onChange: onOCRHotkeyChange)
            }

            HStack {
                AlignedText(text: "HotKey Action")
                Toggle(isOn: $hotKeyTriggerInNotification, label: {
                    Text("In-Notification Mode")
                }).toggleStyle(.checkbox)
            }

            Spacer()
                .frame(height: 20)

            HStack {
                AlignedText(text: "Primary Language")
                LanguagePicker(languageCode: $primaryLanguage, withLabel: true)
            }
            HStack {
                AlignedText(text: "Secondary Language")
                LanguagePicker(languageCode: $secondaryLanguage, withLabel: true)
            }

            Spacer()
                .frame(height: 20)

            HStack {
                AlignedText(text: "Preprocess")
                Toggle(isOn: $preProcessSource, label: {
                    Text("Preprocess Source Text")
                }).toggleStyle(.checkbox)
            }

            //            HStack {
            //                AlignedText(text: "Icon Symbol")
            //                TextField("Icon Symbol", text: $menuIconSymbol)
            //                    .frame(width: 130)
            //            }
        }
        .frame(width: 400, height: 230)
    }

    func setLaunchAtLogin(_ enable: Bool) {
        do {
            if enable {
                if SMAppService.mainApp.status == .enabled {
                    try? SMAppService.mainApp.unregister()
                }

                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            debugPrint("[Settings] Failed to \(enable ? "enable" : "disable") launch at login: \(error.localizedDescription)")
        }
    }

    func onHotkeyChange(hotkey: KeyboardShortcuts.Shortcut?) {
        if hotkey != nil {
            self.hotKey = hotkey!.description
        } else {
            self.hotKey = ""
        }
    }

    func onOCRHotkeyChange(hotkey: KeyboardShortcuts.Shortcut?) {
        if hotkey != nil {
            self.ocrHotKey = hotkey!.description
        } else {
            self.ocrHotKey = ""
        }
    }
}

#Preview("Provider", traits: .fixedLayout(width: 400, height: 500)) {
    GeneralView()
        .padding()
}
