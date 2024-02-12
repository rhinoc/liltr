import Foundation
import NaturalLanguage

let LANGUAGE_ARRAY = [
    Language(code: "zh-CN", flag: "🇨🇳", name: "简体中文"),
    Language(code: "en-US", flag: "🇺🇸", name: "English"),
    Language(code: "ja-JP", flag: "🇯🇵", name: "日本語"),
    Language(code: "ko-KR", flag: "🇰🇷", name: "한국어"),
    Language(code: "fr-FR", flag: "🇫🇷", name: "Français"),
    Language(code: "es-ES", flag: "🇪🇸", name: "Español"),
    Language(code: "pt-PT", flag: "🇵🇹", name: "Português"),
    Language(code: "it-IT", flag: "🇮🇹", name: "Italiano"),
    Language(code: "de-DE", flag: "🇩🇪", name: "Deutsch"),
    Language(code: "tr-TR", flag: "🇹🇷", name: "Türkçe"),
    Language(code: "th-TH", flag: "🇹🇭", name: "ไทย"),
    Language(code: "ar-AE", flag: "🇸🇦", name: "العربية"),
    Language(code: "id-ID", flag: "🇮🇩", name: "Bahasa Indonesia"),
    Language(code: "ms-MY", flag: "🇲🇾", name: "Bahasa Melayu"),
    Language(code: "vi-VN", flag: "🇻🇳", name: "Tiếng Việt"),
    Language(code: "hi-IN", flag: "🇮🇳", name: "हिन्दी")
]

let LANGUAGE_DICT = Dictionary(uniqueKeysWithValues: LANGUAGE_ARRAY.map { ($0.code, $0) })

class LanguageManager {
    static var primaryLanguage: Language {
        return LanguageManager.getLanguageByCode(Defaults.shared.primaryLanguage)!
    }

    static var secondaryLanguage: Language {
        return LanguageManager.getLanguageByCode(Defaults.shared.secondaryLanguage)!
    }

    static func getShortCode(_ code: String) -> String {
        if code.contains("-") {
            return String(code.split(separator: "-")[0])
        } else if code.contains("_") {
            return String(code.split(separator: "-")[0])
        }
        return code
    }

    static func getLanguageByCode(_ code: String) -> Language? {
        if LANGUAGE_DICT[code] != nil {
            return LANGUAGE_DICT[code]
        }

        let shortCode = getShortCode(code)
        for language in LANGUAGE_ARRAY {
            if shortCode == language.shortCode {
                return language
            }
        }

        return nil
    }

    static func getStandardCode(_ code: String) -> String? {
        return getLanguageByCode(code)?.code
    }

    static func getLanguageByContent(_ content: String) -> Language {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(content)

        if let language = recognizer.dominantLanguage {
            let code = language.rawValue.description
            debugPrint("[LanguageManager] getLanguageByContent", code)
            return getLanguageByCode(code) ?? secondaryLanguage
        }

        return secondaryLanguage
    }

    static func getFromTo(_ source: String, _ oldTargetLanguage: Language?) -> (Language, Language)? {
        if source.isEmpty {
            return nil
        }

        let recognizedLanguage = LanguageManager.getLanguageByContent(source)
        var targetLanguage = oldTargetLanguage
        if targetLanguage != nil && recognizedLanguage.shortCode == targetLanguage!.shortCode {
            if oldTargetLanguage!.code != Defaults.shared.primaryLanguage {
                targetLanguage = primaryLanguage
            } else {
                targetLanguage = secondaryLanguage
            }
        }

        return (recognizedLanguage, targetLanguage ?? recognizedLanguage)
    }
}
