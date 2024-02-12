import Foundation

func executeAppleScript(_ appleScript: String, completion: @escaping (String?, Error?) -> Void) {
    let script = NSAppleScript(source: appleScript)
    var error: NSDictionary?
    if let resultDescriptor = script?.executeAndReturnError(&error) {
        if let resultString = resultDescriptor.stringValue {
            completion(resultString, nil)
        } else {
            completion(nil, NSError(domain: "ScriptError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Script did not return a string."]))
        }
    } else {
        completion(nil, error as? Error)
    }
}
