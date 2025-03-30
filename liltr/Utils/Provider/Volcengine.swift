import Alamofire
import CryptoKit
import Foundation

struct VolcengineError: Decodable {
    let Code: String?
    let Message: String?
}

struct VolcengineResponseMetadata: Decodable {
    let RequestId: String?
    let Action: String?
    let Version: String?
    let Service: String?
    let Region: String?
    let Error: VolcengineError?
}

struct VolcengineTranslation: Decodable {
    let Translation: String
    let DetectedSourceLanguage: String
}

struct VolcengineResponse: BaseResponse {
    let ResponseMetadata: VolcengineResponseMetadata
    let TranslationList: [VolcengineTranslation]?

    var target: String? {
        if TranslationList?.isEmpty == false {
            var result: [String] = []
            for item in TranslationList! {
                result.append(item.Translation)
            }
            return result.joined(separator: "\n")
        }

        return nil
    }

    var errorMessage: String? {
        if ResponseMetadata.Error?.Message != nil {
            return "\(ResponseMetadata.Error!.Code!): \(ResponseMetadata.Error!.Message!)"
        }
        return nil
    }
}

let VolcengineProviderName = "Volcengine"

class VolcengineProvider: BaseProvider {
    static let shared = VolcengineProvider()

    let name = VolcengineProviderName
    let delay: DispatchTimeInterval = .microseconds(300)
    var apiUrl: String {
        return "https://\(host)\(uri)?\(queryString)"
    }

    var ak: String {
        return Defaults.shared.VolcengineAK.isEmpty ? "###VOLCENGINE_AK###" : Defaults.shared.VolcengineAK
    }

    var sk: String {
        return Defaults.shared.VolcengineSK.isEmpty ? "###VOLCENGINE_SK###" : Defaults.shared.VolcengineSK
    }

    private let host = "translate.volcengineapi.com"
    private let uri = "/"
    private let queryString = "Action=TranslateText&Version=2020-06-01"
    private let region = "cn-north-1"
    private let service = "translate"

    private func _getSignedHeaders(headers: [String: String]) -> String {
        var result: [String] = []
        for (key, _) in headers {
            result.append(key.lowercased())
        }
        result = result.sorted { $0 < $1 }
        return result.joined(separator: ";")
    }

    private func _getCanonicalHeaders(headers: [String: String]) -> String {
        var result: [String] = []
        for (key, value) in headers {
            result.append("\(key.lowercased()):\(value.trimmingCharacters(in: .whitespaces))")
        }
        result = result.sorted { $0 < $1 }
        return result.joined(separator: "\n") + "\n"
    }

    private func _getXDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let xDate = dateFormatter.string(from: date)
        return xDate
    }

    private func _sign(contentHashed: String, headers: [String: String]) -> String {
        // step 1
        let method = "POST"
        let canonicalHeaders = _getCanonicalHeaders(headers: headers)
        let signedHeaders = _getSignedHeaders(headers: headers)
        let canoicalRequest = [method, uri, queryString, canonicalHeaders, signedHeaders, contentHashed].joined(separator: "\n")

        // step 2
        let algorithm = "HMAC-SHA256"
        let xDate = headers["X-Date"]!
        let shortDate = String(xDate.prefix(8))
        let credentialScope = [shortDate, region, service, "request"].joined(separator: "/")
        let canonicalRequestHashed = _hashSha256(content: canoicalRequest)
        let stringToSign = [algorithm, xDate, credentialScope, canonicalRequestHashed].joined(separator: "\n")

        // step 3
        let kDate = _hmacSha256(sk.data(using: .utf8)!, shortDate)
        let kRegion = _hmacSha256(kDate, region)
        let kService = _hmacSha256(kRegion, service)
        let kSigning = _hmacSha256(kService, "request")
        let signature = CryptoEncoder.data2str(_hmacSha256(kSigning, stringToSign))
        let authorization = "HMAC-SHA256 Credential=\(ak)/\(credentialScope), SignedHeaders=\(signedHeaders), Signature=\(signature)"

        return authorization
    }

    func _hmacSha256(_ key: Data, _ content: String) -> Data {
        let hmac = HMAC<SHA256>.authenticationCode(for: content.data(using: .utf8)!, using: SymmetricKey(data: key))
        return Data(hmac)
    }

    func _hashSha256(content: String) -> String {
        let digest = SHA256.hash(data: content.data(using: .utf8)!)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    func translate(source: String, from: Language, to: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        let parameters: [String: Any] = [
            "SourceLanguage": from.shortCode,
            "TargetLanguage": to.shortCode,
            "TextList": source.split(separator: "\n"),
        ]

        let date = _getXDate()
        let contentHashed = _hashSha256(content: String(data: try! JSONSerialization.data(withJSONObject: parameters, options: []), encoding: .utf8)!)

        var headers = [
            "Content-Type": "application/json",
            "Host": host,
            "X-Date": date,
        ]

        let authorization = _sign(contentHashed: contentHashed, headers: headers)
        headers.updateValue(authorization, forKey: "Authorization")

        debugPrint("[VolcengineProvider] parameters:", parameters, headers)

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: dict2headers(dict: headers))
            .cacheResponse(using: .cache)
            .responseDecodable(of: VolcengineResponse.self) { response in
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
