import Foundation
import CryptoKit

class CryptoEncoder {
    static func str2data(_ string: String) -> Data {
        return Data(string.utf8)
    }

    static func data2str(_ data: Data) -> String {
        return data.map { String(format: "%02hhx", $0) }.joined()
    }

    static func md5(data: Data) -> Data {
        return Data(Insecure.MD5.hash(data: data))
    }

    static func md5(string: String) -> String {
        let stringData = CryptoEncoder.str2data(string)
        let md5Data = md5(data: stringData)
        return data2str(md5Data)
    }

    static func base64(data: Data) -> String {
        return data.base64EncodedString()
    }

    static func base64(data: Data) -> Data {
        return data.base64EncodedData()
    }

    static func base64(string: String) -> String {
        let stringData = CryptoEncoder.str2data(string)
        return stringData.base64EncodedString()
    }

//
//    static func md5(_ string: String) -> Data {
//        let data = Insecure.MD5.hash(data: Data(string.utf8))
//        return data.map {
//            String(format: "%02hhx", $0)
//        }.joined()
//    }
//
//    static func md5Base64(_ string: String) -> String {
//        let digest = Insecure.MD5.hash(data: Data(string.utf8))
//        return Data(digest).base64EncodedString()
//    }
//
//    static func base64(_ string: String) -> String {
//        let inputData = Data(string.utf8)
//        return inputData.base64EncodedString()
//    }

}
