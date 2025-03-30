import Alamofire
import Foundation
import SwiftUI

func replaceLinks(html: String) -> String {
    let regex = try! NSRegularExpression(pattern: "<a(?!\\w)[^>]*>(.*?)</a>")
    var result = html
    for match in regex.matches(in: html, range: NSRange(0 ..< result.count)).reversed() {
        let curRange = Range(match.range, in: html)!
        let letterRange = Range(match.range(at: 1), in: html)!
        let captured = String(html[letterRange])

        if captured.contains("<") {
            result.replaceSubrange(curRange, with: captured)
        } else {
            let url = SchemeURLManager.getUrlByAction(.translateInWindow, querys: ["src": captured])
            result.replaceSubrange(curRange, with: "<a class=\"explain\" href=\"\(url.absoluteString)\">\(captured)</a>")
        }
    }
    return result
}

func extractFromHTML(html: String, tag: String) -> String {
    do {
        let pattern = "(?<=<\(tag)>)(.*?)(?=</\(tag)>)"
        let regex = try NSRegularExpression(pattern: pattern, options: .dotMatchesLineSeparators)
        let nsString = html as NSString
        let matches = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))

        guard let match = matches.first else { return "" }
        let bodyContent = nsString.substring(with: match.range)

        if let data = bodyContent.data(using: .utf8), let decodedString = String(data: data, encoding: .utf8) {
            return decodedString
        } else {
            throw NSError(domain: "Invalid encoding", code: 1, userInfo: nil)
        }
    } catch {
        print("[extractFromHTML] process error: \(error)")
        return ""
    }
}

let AppleDictionaryProviderName = "AppleDictionary"

// https://github.com/tisfeng/Easydict/blob/main/docs/How-to-use-macOS-system-dictionary-in-Easydict-zh.md
// https://dictionaries.io/
class AppleDictionaryProvider: BaseProvider {
    static let shared = AppleDictionaryProvider()

    var delay: DispatchTimeInterval = .milliseconds(250)
    let name = AppleDictionaryProviderName

    var dictionary: String {
        return Defaults.shared.dictionary
    }

    private func _lookupNative(_ word: String) -> String {
        let cfWord = word as CFString
        let range = DCSGetTermRangeInString(nil, cfWord, 0)
        if let definition = DCSCopyTextDefinition(nil, cfWord, range) {
            let definitionString = String(definition.takeRetainedValue())
            return definitionString.split(separator: " | ").joined(separator: "\n")
        } else {
            return "No definition found for \(word)"
        }
    }

    private func _lookUpByDictionary(term: String, dictionary: String) -> TTTDictionaryEntry? {
        let dictionary = TTTDictionary(named: dictionary)
        let entries = dictionary.entries(forSearchTerm: term) as? [TTTDictionaryEntry]
        return entries?.first
    }

    func getDictionaries() -> [String] {
        return TTTDictionary.availableDictionaries().map { item in
            item.name
        }
    }

    private func _handleHTML(_ html: String) -> String {
        let head = extractFromHTML(html: html, tag: "head")
        let body = extractFromHTML(html: html, tag: "body")
        let trimmedBody = replaceLinks(html: body)
        let result = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
        <html
          xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
          class="apple_client-panel apple_appearance-compliant"
          aria-label="explain"
        ><head><meta charset="UTF-8"><style>:root{color-scheme: light dark;}</style>\(head)</head><body>\(trimmedBody)</body></html>
        """
        return result
    }

    func translate(source: String, from _: Language, to _: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        if !dictionary.isEmpty {
            let result = _lookUpByDictionary(term: source, dictionary: dictionary)
            if result != nil {
                cb(_handleHTML(result!.htmlWithPopoverCSS), 0)
                return
            }
        }
        let dictionaryNames = getDictionaries()
        for name in dictionaryNames {
            if name == dictionary {
                continue
            }
            let result = _lookUpByDictionary(term: source, dictionary: DCSOxfordDictionaryOfEnglish)
            if result != nil {
                cb(_handleHTML(result!.htmlWithPopoverCSS), 0)
                break
            }
        }
        cb("No definition found for \(source)", 2000)
    }
}
