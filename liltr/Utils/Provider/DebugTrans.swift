import Foundation

struct DebugTransResponse: BaseResponse {
    let target: String?
    let errorMessage: String?
}

let DebugTransProviderName = "DebugTrans"

class DebugTransProvider: BaseProvider {
    static let shared = DebugTransProvider()

    let name = DebugTransProviderName

    let delay: DispatchTimeInterval = .milliseconds(Int.random(in: 50 ... 1000))

    func translate(source: String, from _: Language, to _: Language, cb: @escaping (String, Int) -> Void) {
        // 生成一个 1-1000 之间的随机数
        let randomNumber = Int.random(in: 1 ... 1000)
        // 拼接原文和随机数
        let result = "\(source) [\(randomNumber)]"

        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            cb(result, 0)
        }
    }
}
