import Foundation

enum SchemeAction: String {
    case translateInWindow = "translate-in-window"
    case settings = "settings"
    case update = "update"
}

class SchemeURLManager {
    static func getUrlByAction(_ action: SchemeAction, querys: [String: String] = [:]) -> URL {
        var components = URLComponents()
        components.scheme = APP_NAME
        components.host = action.rawValue
        components.queryItems = querys.map {
            URLQueryItem(name: $0,
                         value: $1.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            )
        }

        return components.url!
    }
}
