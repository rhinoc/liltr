struct Language {
    var code: String
    var flag: String
    var name: String

    var shortCode: String {
        return String(code.split(separator: "-")[0])
    }

    init(code: String, flag: String, name: String) {
        self.code = code
        self.flag = flag
        self.name = name
    }
}
