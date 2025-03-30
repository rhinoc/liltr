import Foundation

protocol BaseProvider: ObservableObject {
    var delay: DispatchTimeInterval { get }
    var name: String { get }

    func translate(source: String, from: Language, to: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void)
}

protocol BaseResponse: Decodable {
    var target: String? { get }
    var errorMessage: String? { get }
}

let PROVIDER_ARRAY: [any BaseProvider] = [NiuTransProvider.shared, BaiduProvider.shared, VolcengineProvider.shared, AliProvider.shared, AppleDictionaryProvider.shared, BigHugeThesaurusProvider.shared, OllamaProvider.shared, DebugTransProvider.shared]
let PROVIDER_DICT: [String: any BaseProvider] = Dictionary(uniqueKeysWithValues: PROVIDER_ARRAY.map { ($0.name, $0) })

struct ProviderCallbackData {
    let target: String
    let source: String
    let sourceLanguage: Language?
    let targetLanguage: Language?
    let providerName: String
    let errorCode: Int

    var isDictionary: Bool {
        return providerName == AppleDictionaryProviderName
    }

    init(_ result: String, _ source: String, sourceLanguage: Language? = nil, targetLanguage: Language? = nil, providerName: String, errorCode: Int) {
        target = result
        self.source = source
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.providerName = providerName
        self.errorCode = errorCode
    }
}

class ProviderManager: ObservableObject {
    static let shared = ProviderManager()
    private var resultCache: [String: ProviderCallbackData] = [:]
    private var curCacheKey: String = ""

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

    func translate(_ source: String, sourceLanguage: Language, targetLanguage: Language, _ cb: @escaping (_ data: ProviderCallbackData) -> Void) {
        // special case for dictionary
        var cur = sourceLanguage.code == targetLanguage.code ? AppleDictionaryProvider.shared : provider
        let transformedSource = Defaults.shared.preProcessSource ? TextHandler.handle(source) : source
        if transformedSource.isEmpty {
            return
        }

        // get cached key
        let cacheKey = "\(CryptoEncoder.base64(string: source))_\(sourceLanguage.code)_\(targetLanguage.code)_\(cur.name)"

        func _callback(_ target: String, _ errorCode: Int) {
            debugPrint("[ProviderManager#callback]", [
                "source": source,
                "target": target,
            ])

            if cacheKey != curCacheKey {
                return
            }

            let data = ProviderCallbackData(target, source, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage, providerName: cur.name, errorCode: errorCode)
            cb(data)

            if errorCode == 0 {
                resultCache[cacheKey] = data
            }

            isTranslating = false
            curCacheKey = ""
        }

        if resultCache[cacheKey] != nil {
            cb(resultCache[cacheKey]!)
            return
        }

        isTranslating = true
        curCacheKey = cacheKey

        debugPrint("[ProviderManager#translate]", [
            "name": cur.name,
            "from": sourceLanguage.code,
            "to": targetLanguage.code,
            "source": transformedSource,
        ])

        return cur.translate(source: transformedSource, from: sourceLanguage, to: targetLanguage, cb: _callback)
    }
}
