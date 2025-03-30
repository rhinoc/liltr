import Foundation

class TextHandler {
    private static func _removeWhiteSpacesFromLine(_ line: String) -> String {
        return line.trimmingCharacters(in: .whitespaces)
    }

    private static func _removeCommentsFromLine(_ line: String) -> String {
        let trimedLine = _removeWhiteSpacesFromLine(line)
        if trimedLine.hasPrefix("/") || trimedLine.hasPrefix("*") {
            return _removeCommentsFromLine(String(trimedLine.dropFirst()))
        } else {
            return trimedLine
        }
    }

    private static func _transformCamelCase(_ word: String) -> String {
        if word == word.uppercased() {
            return word
        }

        let pattern = "(?<=.)([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: word.utf16.count)
        let result = regex?.stringByReplacingMatches(in: word, options: [], range: range, withTemplate: " $1")
        return result?.lowercased() ?? word
    }

    private static func _transformSnakeCase(_ word: String) -> String {
        return word.replacingOccurrences(of: "_", with: " ")
    }

    private static func _transformWord(_ word: String) -> String {
        return _transformSnakeCase(_transformCamelCase(word))
    }

    private static func _transformLine(_ line: String) -> String {
        let trimedLine = _removeCommentsFromLine(line)
        let words = trimedLine.split(separator: " ").map { word in
            _transformWord(String(word))
        }
        return words.joined(separator: " ")
    }

    static func handle(_ content: String) -> String {
        let originalLines = content.split(separator: "\n").filter { line in
            !line.isEmpty
        }

        let lines = originalLines.map { line in
            _transformLine(String(line))
        }

        var separator = " "
        if originalLines.first != nil && lines.first != nil && originalLines.first! == lines.first! {
            separator = "\n"
        }

        return lines.filter { !$0.isEmpty }.joined(separator: separator)
    }
}
