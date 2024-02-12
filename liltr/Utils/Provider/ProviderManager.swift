import Foundation

protocol BaseProvider: ObservableObject {
    var delay: DispatchTimeInterval { get }
    var name: String { get }

    func translate(source: String, from: Language, to: Language, cb: @escaping (_ target: String, _ sourceLanguage: Language?, _ targetLanguage: Language?) -> Void)
}

protocol BaseResponse: Decodable {
    var target: String? { get }
    var errorMessage: String? { get }
}

let PROVIDER_ARRAY: [any BaseProvider] = [NiuTransProvider.shared, BaiduProvider.shared, VolcengineProvider.shared, AliProvider.shared, AppleDictionaryProvider.shared, BigHugeThesaurusProvider.shared]
let PROVIDER_DICT: [String: any BaseProvider] = Dictionary(uniqueKeysWithValues: PROVIDER_ARRAY.map { ($0.name, $0) })

struct ProviderCallbackData {
    let target: String
    let source: String
    let sourceLanguage: Language?
    let targetLanguage: Language?
    let providerName: String

    var isDictionary: Bool {
        return providerName == AppleDictionaryProviderName
    }

    init(_ result: String, _ source: String, sourceLanguage: Language? = nil, targetLanguage: Language? = nil, providerName: String) {
        self.target = result
        self.source = source
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.providerName = providerName
    }
}

class ProviderManager: ObservableObject {
    static let shared = ProviderManager()
    private var resultCache: [String: ProviderCallbackData] = [:]
    private var curQuery: String = ""

    @Published var name = PROVIDER_DICT[Defaults.shared.primaryProvider]!.name
    @Published var usePrimary = true
    @Published var isTranslating = false

    init() {}

    var provider: any BaseProvider {
        return usePrimary ? PROVIDER_DICT[Defaults.shared.primaryProvider]! : PROVIDER_DICT[Defaults.shared.secondaryProvider]!
    }

    func switchProvider() {
        usePrimary = !usePrimary
        name = provider.name
    }

    func translate(_ source: String, _ targetLanguage: Language?, _ cb: @escaping (_ data: ProviderCallbackData) -> Void) {
        var cur = targetLanguage == nil ? AppleDictionaryProvider.shared : provider
        let transformedSource = Defaults.shared.preProcessSource ? TextHandler.handle(source) : source
        if transformedSource.isEmpty {
            return
        }
//        if (regexMatched(transformedSource, "^\\b\\w+\\b$")) {
//            cur = AppleDictionaryProvider.shared
//        }
        let query = "\(CryptoEncoder.base64(string: source))_\(targetLanguage?.code ?? "nil")_\(cur.name)_\(cur.name == AppleDictionaryProviderName ? Defaults.shared.dictionary : "nil")"

        func _callback(_ target: String, _ _sourceLanguage: Language? = nil, _ _targetLanguage: Language? = nil) {
            if query == curQuery {
                let data = ProviderCallbackData(target, source, sourceLanguage: _sourceLanguage, targetLanguage: _targetLanguage?.name == _sourceLanguage?.name ? nil : _targetLanguage, providerName: cur.name)
                cb(data)
                resultCache[query] = data
                isTranslating = false
                curQuery = ""
            }
        }

        if resultCache[query] != nil {
            cb(resultCache[query]!)
            return
        }

        isTranslating = true
        curQuery = query

        let fromTo = LanguageManager.getFromTo(transformedSource, targetLanguage)
        if fromTo == nil {
            _callback("Source text can not be recognized")
            return
        }
        let (from, to) = fromTo!

        debugPrint("[ProviderManager#translate]", [
            "name": cur.name,
            "from": from.code,
            "to": to.code,
            "source": transformedSource
        ])

        return cur.translate(source: transformedSource, from: from, to: to, cb: _callback)
    }
}
