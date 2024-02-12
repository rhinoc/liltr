import SwiftUI

// https://fatbobman.com/zh/posts/appstorage/
public class Defaults: ObservableObject {
    @AppStorage("launchAtLogin") public var launchAtLogin = false
    @AppStorage("menuIconSymbol") public var menuIconSymbol = ""
    @AppStorage("floatOnTop") public var floatOnTop = false

    // MARK: HotKey
    @AppStorage("hotKey") public var hotKey = ""
    @AppStorage("ocrHotKey") public var ocrHotKey = ""
    @AppStorage("hotKeyTriggerInNotification") public var hotKeyTriggerInNotification = true

    // MARK: Language
    @AppStorage("primaryLanguage") public var primaryLanguage = LANGUAGE_ARRAY[0].code
    @AppStorage("secondaryLanguage") public var secondaryLanguage = LANGUAGE_ARRAY[1].code

    // MARK: Provider
    @AppStorage("primaryProvider") public var primaryProvider = NiuTransProviderName
    @AppStorage("secondaryProvider") public var secondaryProvider = VolcengineProviderName
    // niuTrans
    @AppStorage("\(NiuTransProviderName)SK") public var NiuTransSK = ""
    // baidu
    @AppStorage("\(BaiduProviderName)AK") public var BaiduAK = ""
    @AppStorage("\(BaiduProviderName)SK") public var BaiduSK = ""
    // volcengine
    @AppStorage("\(VolcengineProviderName)AK") public var VolcengineAK = ""
    @AppStorage("\(VolcengineProviderName)SK") public var VolcengineSK = ""
    // ali
    @AppStorage("\(AliProviderName)AK") public var AliAK = ""
    @AppStorage("\(AliProviderName)SK") public var AliSK = ""
    // big huge
    @AppStorage("\(BigHugeThesaurusProviderName)SK") public var BigHugeThesaurusSK = ""

    // MARK: Dictionary
    @AppStorage("dictionary") public var dictionary = DCSOxfordDictionaryOfEnglish

    // MARK: Advanced
    @AppStorage("preProcessSource") public var preProcessSource = true

    public static let shared = Defaults()
}

@propertyWrapper
public struct Default<T>: DynamicProperty {
    @ObservedObject private var defaults: Defaults
    private let keyPath: ReferenceWritableKeyPath<Defaults, T>
    public init(_ keyPath: ReferenceWritableKeyPath<Defaults, T>, defaults: Defaults = .shared) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { defaults[keyPath: keyPath] = newValue }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] },
            set: { value in
                defaults[keyPath: keyPath] = value
            }
        )
    }
}
