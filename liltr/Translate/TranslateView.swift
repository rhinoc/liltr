import Combine
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import WebKit

struct HTMLStringView: NSViewRepresentable {
    typealias NSViewType = WKWebView

    let htmlContent: String

    func makeNSView(context _: Context) -> WKWebView {
        let view = WKWebView()
        view.setValue(false, forKey: "drawsBackground")
        return view
    }

    func updateNSView(_ nsView: WKWebView, context _: Context) {
        nsView.loadHTMLString(htmlContent, baseURL: nil)
    }
}

struct TranslateView: View {
    @ObservedObject private var provider = ProviderManager.shared

    @State private var sourceText: String = ""
    @State private var targetText: String = ""
    @State private var sourceLanguageCode: String = ""
    @State private var sourceLanguageAutoDetect: Bool = true
    @State private var targetLanguageCode: String = Defaults.shared.primaryLanguage
    @State private var height: CGFloat = 100
    @State private var isDictionaryMode: Bool = false

    private let MIN_HEIGHT: CGFloat = 40
    @State private var lastHeight: CGFloat = 100

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

    private let debouncer = PassthroughSubject<String, Never>()

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                // MARK: top bar

                TopBarView()
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 4))

                VStack(alignment: .leading, spacing: 0) {
                    // MARK: source text field

                    SourceFieldView(text: $sourceText, sourceLanguageCode: $sourceLanguageCode, sourceLanguageAutoDetect: $sourceLanguageAutoDetect, placeholder: "Type any words to start...", onChange: onSourceInput, debouncer: debouncer, isDictionaryMode: isDictionaryMode)
                        .frame(height: self.height)

                    // MARK: mid bar

                    MidBarView(showButton: !isDictionaryMode, isLoading: provider.isTranslating, isSwapDisabled: targetLanguageCode.isEmpty || sourceLanguageCode.isEmpty || targetText.isEmpty, onSwap: onSwap) { height in
                        self.height = floor(minMax(self.height + height, min: MIN_HEIGHT, max: geometry.size.height - 100))
                    }

                    // MARK: target text field

                    if targetText.starts(with: "<?xml") || targetText.starts(with: "<html") {
                        HTMLStringView(htmlContent: targetText)
                            .bottomFade()
                    } else {
                        TargetFieldView(text: $targetText)
                            .bottomFade()
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                    }
                }

                Spacer(minLength: 2)

                // MARK: bottom bar

                BottomBarView(targetLanguageCode: $targetLanguageCode, isDictionaryMode: $isDictionaryMode, getCopyText: getTargetText, getSpeechText: getSourceText, onChangeProvider: onSourceInput)
                    .padding(10)
                    .onChange(of: targetLanguageCode, onSourceInput)
                    .onChange(of: isDictionaryMode) { _, newValue in
                        if newValue {
                            withAnimation {
                                lastHeight = height
                                height = MIN_HEIGHT
                            }
                        } else {
                            withAnimation {
                                height = lastHeight
                            }
                        }
                        targetText = ""
                        onSourceInput()
                    }
            }
            .background(Color.backgroundColor.opacity(0.6))
            .background(BlurWindow())
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
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
        (targetLanguageCode, sourceLanguageCode) = (sourceLanguageCode, targetLanguageCode)
        sourceText = targetText
    }

    func onSourceInput() {
        if sourceText.isEmpty {
            targetText = ""
            return
        }

        // get next source language
        var nextSourceLanguage: Language
        if !sourceLanguageAutoDetect && !sourceLanguageCode.isEmpty {
            nextSourceLanguage = LanguageManager.getLanguageByCode(sourceLanguageCode)
        } else {
            nextSourceLanguage = LanguageManager.getLanguageByContent(sourceText)
        }

        // get next target language
        var nextTargetLanguage: Language
        if isDictionaryMode {
            nextTargetLanguage = nextSourceLanguage
        } else {
            nextTargetLanguage = LanguageManager.fixTargetLanguage(sourceLanguage: nextSourceLanguage, targetLanguage: LanguageManager.getLanguageByCode(targetLanguageCode))
        }

        provider.translate(sourceText, sourceLanguage: nextSourceLanguage, targetLanguage: nextTargetLanguage, updateTargetText)
    }

    func updateTargetText(_ result: ProviderCallbackData) {
        debugPrint("[updateTargetText]", result)
        
        if result.errorCode == 0 {
            targetText = result.target
        } else {
            targetText = "👾👾👾\n\n\(result.target)"
        }

        isDictionaryMode = result.isDictionary
        if result.targetLanguage != nil {
            targetLanguageCode = result.targetLanguage!.code
        }
        if result.sourceLanguage != nil {
            sourceLanguageCode = result.sourceLanguage!.code
        }
    }
}
