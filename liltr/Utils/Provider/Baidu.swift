import Alamofire
import Foundation

struct BaiduResult: Decodable {
    let src: String?
    let dst: String?
}

struct BaiduResponse: BaseResponse {
    let error_code: String?
    let error_msg: String?
    let trans_result: [BaiduResult]?
    let from: String?
    let to: String?

    var target: String? {
        if trans_result?.isEmpty == false {
            var result: [String] = []
            for item in trans_result! {
                result.append(item.dst!)
            }
            return result.joined(separator: "\n")
        }
        return nil
    }

    var errorMessage: String? {
        if error_msg != nil {
            return "\(error_code!): \(error_msg!)"
        }
        return nil
    }
}

let BaiduProviderName = "Baidu"

class BaiduProvider: BaseProvider {
    static let shared = BaiduProvider()
    let name = BaiduProviderName
    let delay: DispatchTimeInterval = .seconds(1)
    let apiUrl = "https://fanyi-api.baidu.com/api/trans/vip/translate"

    var ak = Defaults.shared.BaiduAK.isEmpty ? "###BAIDU_AK###" : Defaults.shared.BaiduAK
    var sk = Defaults.shared.BaiduSK.isEmpty ? "###BAIDU_SK###" : Defaults.shared.BaiduSK

    @Published var isTranslating = false

    private func _sign(q: String, salt: String) -> String {
        let str1 = "\(ak)\(q)\(salt)\(sk)"
        let str2 = CryptoEncoder.md5(string: str1).lowercased()
        return str2
    }

    func translate(source: String, from: Language, to: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        let salt = String(Int(round(Date().timeIntervalSince1970)))
        let sign = _sign(q: source, salt: salt)
        let parameters: [String: String] = [
            "q": source,
            "from": from.shortCode,
            "to": to.shortCode,
            "appid": ak,
            "salt": salt,
            "sign": sign,
        ]

        debugPrint("[BaiduProvider] parameters:", parameters)

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: URLEncoding.default)
            .cacheResponse(using: .cache)
            .responseDecodable(of: BaiduResponse.self) { response in
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
