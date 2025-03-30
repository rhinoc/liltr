import Alamofire
import Foundation

struct NiuTransResponse: BaseResponse {
    let error_code: String?
    let error_msg: String?
    let tgt_text: String?
    let from: String
    let to: String
    let src_text: String?

    var target: String? {
        return tgt_text
    }

    var errorMessage: String? {
        if error_msg != nil && !error_msg!.isEmpty {
            return "\(error_code!): \(error_msg!)"
        }
        return nil
    }
}

let NiuTransProviderName = "NiuTrans"

class NiuTransProvider: BaseProvider {
    static let shared = NiuTransProvider()

    let name = NiuTransProviderName
    let delay: DispatchTimeInterval = .microseconds(250)
    let apiUrl = "https://api.niutrans.com/NiuTransServer/translation"

    var sk = Defaults.shared.NiuTransSK.isEmpty ? "###NIUTRANS_SK###" : Defaults.shared.NiuTransSK

    func translate(source: String, from: Language, to: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        let parameters: [String: String] = [
            "apikey": sk,
            "src_text": source,
            "from": from.shortCode,
            "to": to.shortCode,
        ]

        debugPrint("[NiuTransProvider] parameters:", parameters)

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .cacheResponse(using: .cache)
            .responseDecodable(of: NiuTransResponse.self) { response in
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
