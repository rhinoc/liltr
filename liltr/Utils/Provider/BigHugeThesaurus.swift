import Alamofire
import Foundation

struct BigHugeThesaurusResult: Decodable {
    let syn: [String]?
    let ant: [String]?
    let rel: [String]?
    let sim: [String]?
    let usr: [String]?
}

struct BigHugeThesaurusResponse: BaseResponse {
    let noun: BigHugeThesaurusResult?
    let verb: BigHugeThesaurusResult?
    let adjective: BigHugeThesaurusResult?
    let adverb: BigHugeThesaurusResult?

    func parseResult(result: BigHugeThesaurusResult?) -> String {
        if result == nil {
            return ""
        }

        var lines: [String] = []
        if !(result?.syn?.isEmpty ?? true) {
            lines.append("• synonyms:")
            lines.append("\t" + result!.syn!.joined(separator: " / "))
        }
        if !(result?.ant?.isEmpty ?? true) {
            lines.append("• antonyms:")
            lines.append("\t" + result!.ant!.joined(separator: " / "))
        }
        if !(result?.rel?.isEmpty ?? true) {
            lines.append("• related:")
            lines.append("\t" + result!.rel!.joined(separator: " / "))
        }
        if !(result?.sim?.isEmpty ?? true) {
            lines.append("• similar:")
            lines.append("\t" + result!.sim!.joined(separator: " / "))
        }
        if !(result?.usr?.isEmpty ?? true) {
            lines.append("• suggestions:")
            lines.append("\t" + result!.usr!.joined(separator: " / "))
        }

        return lines.joined(separator: "\n")
    }

    var target: String? {
        var parts: [String] = []
        let nounStr = parseResult(result: noun)
        if !nounStr.isEmpty {
            parts.append("[noun]")
            parts.append(nounStr + "\n")
        }
        let verbStr = parseResult(result: verb)
        if !verbStr.isEmpty {
            parts.append("[verb]")
            parts.append(verbStr + "\n")
        }
        let adjStr = parseResult(result: adjective)
        if !adjStr.isEmpty {
            parts.append("[adj]")
            parts.append(adjStr + "\n")
        }
        let advStr = parseResult(result: adverb)
        if !advStr.isEmpty {
            parts.append("[adv]")
            parts.append(advStr + "\n")
        }

        return parts.joined(separator: "\n")
    }

    var errorMessage: String? {
        return nil
    }
}

let BigHugeThesaurusProviderName = "BigHugeThesaurus"

class BigHugeThesaurusProvider: BaseProvider {
    static let shared = BigHugeThesaurusProvider()

    let name = BigHugeThesaurusProviderName
    let delay: DispatchTimeInterval = .microseconds(250)
    let apiUrl = "https://words.bighugelabs.com/api/2"

    var sk = Defaults.shared.BigHugeThesaurusSK.isEmpty ? "###BIGHUGETHESAURUS_SK###" : Defaults.shared.BigHugeThesaurusSK

    func translate(source: String, from _: Language, to _: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        let word = String(source.firstWord ?? "")
        if word.isEmpty {
            return
        }

        AF.request("\(apiUrl)/\(sk)/\(word)/json", method: .get)
            .cacheResponse(using: .cache)
            .responseDecodable(of: BigHugeThesaurusResponse.self) { response in
                if response.error != nil {
                    cb(response.error!.errorDescription!, 1000)
                } else if response.value?.errorMessage != nil {
                    cb(response.value!.errorMessage!, 1001)
                } else {
                    cb(response.value!.target!, 0)
                }
            }
    }
}
