import Foundation
import Alamofire
import SwiftUI

func dict2headers(dict: [String: String]) -> HTTPHeaders {
    var httpHeaders = HTTPHeaders()
    for (key, value) in dict {
        httpHeaders.add(name: key, value: value)
    }
    return httpHeaders
}

func minMax(_ x: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
    if x < min {
        return min
    } else if x > max {
        return max
    } else {
        return x
    }
}

func regexMatched(_ string: String, _ regex: String) -> Bool {
    do {
        let regex = try NSRegularExpression(pattern: regex)
        let range = NSRange(location: 0, length: string.utf16.count)
        let match = regex.firstMatch(in: string, options: [], range: range)

        return match != nil
    } catch let error {
        return false
    }
}
