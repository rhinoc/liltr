import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import WebKit

struct HTMLStringView: NSViewRepresentable {
    typealias NSViewType = WKWebView

    let htmlContent: String

    func makeNSView(context: Context) -> WKWebView {
        var view = WKWebView()
        view.setValue(false, forKey: "drawsBackground")
        return view
    }

    func updateNSView(_ nsView: WKWebView, context: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct TranslateView: View {
    @ObservedObject private var provider = ProviderManager.shared

    @State private var sourceText: String = ""
    @State private var targetText: String = ""
    @State private var targetLanguageCode: String = Defaults.shared.primaryLanguage
    @State private var height: CGFloat = 100
    @State private var isDictionaryMode: Bool = false

    private let MIN_HEIGHT: CGFloat = 40

    private func _handleIncomingURL(_ url: URL) {
        guard url.scheme == APP_NAME else {
            return
        }

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        let action = components.host
        guard action == SchemeAction.translateInWindow.rawValue else {
            return
        }

        let src = components.queryItems?.first(where: { $0.name == "src" })?.value ?? ""
        guard !src.isEmpty else {
            return
        }

        sourceText = src.removingPercentEncoding!
    }

    var body: some View {
        GeometryReader {geometry in
            VStack(alignment: .leading) {
                // MARK: top bar
                TopBarView()
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 4))

                VStack(alignment: .leading, spacing: 0) {
                    // MARK: source text field
                    TranslateFieldView(text: $sourceText, placeholder: "Type any words to start...", onChange: onSourceInput)
                        .frame(height: self.height)

                    // MARK: mid bar
                    MidBarView(showButton: !isDictionaryMode, isLoading: provider.isTranslating, onSwap: onSwap) { height in
                        self.height = floor(minMax(self.height + height, min: MIN_HEIGHT, max: geometry.size.height - 100))
                    }

                    // MARK: target text field
                    if targetText.starts(with: "<?xml") || targetText.starts(with: "<html") {
                        HTMLStringView(htmlContent: targetText)
                            .bottomFade()
                    } else {
                        TranslateFieldView(text: $targetText, readOnly: true)
                            .bottomFade()
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    }
                }

                Spacer(minLength: 2)
                // MARK: bottom bar
                BottomBarView(languageCode: $targetLanguageCode, isDictionaryMode: $isDictionaryMode, getCopyText: getTargetText, getSpeechText: getSourceText, onChangeProvider: onSourceInput)
                .padding(10)
                .onChange(of: targetLanguageCode, onSourceInput)
                .onChange(of: isDictionaryMode) { _, newValue in
                    if newValue {
                        withAnimation {
                            height = MIN_HEIGHT
                        }
                    }
                    targetText = ""
                    onSourceInput()
                }
            }
            .background(Color.backgroundColor.opacity(0.6))
            .background(BlurWindow())
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            .onOpenURL(perform: { url in
                _handleIncomingURL(url)
            })

        }
    }

    func getSourceText() -> String {
        return sourceText
    }

    func getTargetText() -> String {
        return targetText
    }

    func onSwap() {
        sourceText = targetText
        targetLanguageCode = targetLanguageCode == Defaults.shared.primaryLanguage ? Defaults.shared.secondaryLanguage : Defaults.shared.primaryLanguage
    }

    func onSourceInput() {
        if sourceText.isEmpty {
            targetText = ""
        } else {
            provider.translate(sourceText, isDictionaryMode ? nil : LanguageManager.getLanguageByCode(targetLanguageCode)!, updateTargetText)
        }
    }

    func updateTargetText(_ result: ProviderCallbackData) {
        self.targetText = result.target
        self.isDictionaryMode = result.isDictionary
        if result.targetLanguage != nil {
            self.targetLanguageCode = result.targetLanguage!.code
        }
    }
}
