import Alamofire
import CryptoKit
import Foundation

struct AliResult: Decodable {
    let Translated: String?
    let WordCount: String?
    let DetectedLanguage: String?
}

struct AliResponse: BaseResponse {
    let Code: String?
    let Message: String?
    let RequestId: String?
    let Data: AliResult?

    var target: String? {
        if Data?.Translated?.isEmpty == false {
            return Data!.Translated!
        }
        return nil
    }

    var errorMessage: String? {
        if Message != nil {
            return "\(Code!): \(Message!)"
        }
        return nil
    }
}

let AliProviderName = "Ali"

class AliProvider: BaseProvider {
    static let shared = AliProvider()
    let delay: DispatchTimeInterval = .seconds(1)
    let name = AliProviderName
    let apiUrl = "https://mt.cn-hangzhou.aliyuncs.com/api/translate/web/general"

    var ak = Defaults.shared.AliAK.isEmpty ? "###ALI_AK###" : Defaults.shared.AliAK
    var sk = Defaults.shared.AliSK.isEmpty ? "###ALI_SK###" : Defaults.shared.AliSK

    private func _getDate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = Locale(identifier: "en_UK")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }

    private func _getHeaders() -> HTTPHeaders {
        let date = _getDate()
        let url = URL(string: apiUrl)!
        let path = url.path
        let uuid = String(Int(round(Date().timeIntervalSince1970)))
        var headers = [
            "Accept": "application/json",
            "Content-Type": "application/json;chrset=utf-8",
            "Date": date,
            "Host": "mt.cn-hangzhou.aliyuncs.com",
            "x-acs-signature-method": "HMAC-SHA1",
            "x-acs-signature-nonce": uuid,
        ]

        let stringToSignArr: [String] = ["POST", headers["Accept"]! + "\n", headers["Content-Type"]!, headers["Date"]!, "x-acs-signature-method:HMAC-SHA1", "x-acs-signature-nonce:\(uuid)", path]
        let stringToSign = stringToSignArr.joined(separator: "\n")
        let signature = hmac_sha1(sk, stringToSign)
        let authHeader = "acs \(ak):\(signature)"
        headers.updateValue(authHeader, forKey: "Authorization")

        return dict2headers(dict: headers)
    }

    private func hmac_sha1(_ key: String, _ content: String) -> String {
        let _key = key.data(using: .utf8)!
        let data = content.data(using: .utf8)!
        let hmac = HMAC<Insecure.SHA1>.authenticationCode(for: data, using: SymmetricKey(data: _key))
        return Data(hmac).base64EncodedString()
    }

    func translate(source: String, from: Language, to: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        let parameters: [String: String] = [
            "FormatType": "text",
            "SourceText": source,
            "SourceLanguage": from.shortCode,
            "TargetLanguage": to.shortCode,
            "Scene": "general",
        ]
        let headers = _getHeaders()

        debugPrint("[AliProvider] parameters:", parameters)

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .cacheResponse(using: .cache)
            .responseDecodable(of: AliResponse.self) { response in
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
