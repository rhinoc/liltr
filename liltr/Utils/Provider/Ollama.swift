import Alamofire
import Foundation

struct OllamaResult: Decodable {
    let role: String
    let content: String
}

struct OllamaResponse: BaseResponse {
    let model: String
    let created_at: String
    let message: OllamaResult
    let done: Bool

    var target: String? {
        return message.content
    }

    var errorMessage: String? {
        return nil
    }
}

let OllamaProviderName = "Ollama"

class OllamaProvider: BaseProvider {
    static let shared = OllamaProvider()
    let delay: DispatchTimeInterval = .seconds(1)
    let name = OllamaProviderName

    var apiUrl: String {
        return Defaults.shared.OllamaAPI.isEmpty ? "http://localhost:11434/api/chat" : Defaults.shared.OllamaAPI
    }

    var model: String {
        return Defaults.shared.OllamaModel.isEmpty ? "qwen2" : Defaults.shared.OllamaModel
    }

    func translate(source: String, from _: Language, to: Language, cb: @escaping (_ target: String, _ errorCode: Int) -> Void) {
        let prompt = "Assuming you are a seasoned translator, please translate the following source text to \(to.name) as target language, ensuring accuracy while trying to retain emotion and natural flow. Your response should ONLY contain the translated result.\n The source text is: ```\(source)```"
        let parameters: [String: Any] = [
            "model": model,
            "stream": false,
            "messages": [
                [
                    "role": "user",
                    "content": prompt,
                ],
            ],
        ]

        debugPrint("[OllamaProvider] parameters:", parameters)

        AF.request(apiUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .cacheResponse(using: .cache)
            .cURLDescription(calling: { curl in
                print(curl)
            })
            .responseDecodable(of: OllamaResponse.self) { response in
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
