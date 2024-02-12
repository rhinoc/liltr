import Foundation

extension TimeInterval {

    /**
     Checks if `since` has passed since `self`.
     
     - Parameter since: The duration of time that needs to have passed for this function to return `true`.
     - Returns: `true` if `since` has passed since now.
     */
    func hasPassed(since: TimeInterval) -> Bool {
        return Date().timeIntervalSinceReferenceDate - self > since
    }

}

// https://gist.github.com/simme/b78d10f0b29325743a18c905c5512788
class Throttler {
    static var currentWorkItem: DispatchWorkItem?
    static var lastFire: TimeInterval = 0

    static func throttle(delay: TimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {

        return { [] in
            guard Throttler.currentWorkItem == nil else { return }
            Throttler.currentWorkItem = DispatchWorkItem {
                action()
                self.lastFire = Date().timeIntervalSinceReferenceDate
                self.currentWorkItem = nil
            }

            delay.hasPassed(since: self.lastFire) ? queue.async(execute: self.currentWorkItem!) : queue.asyncAfter(deadline: .now() + delay, execute: self.currentWorkItem!)
        }
    }
}

class Debouncer {
    static var currentWorkItem: DispatchWorkItem?

    static func debounce(delay: DispatchTimeInterval, queue: DispatchQueue = .main, action: @escaping (() -> Void)) -> () -> Void {
        return {  [] in
            Debouncer.currentWorkItem?.cancel()
            Debouncer.currentWorkItem = DispatchWorkItem { action() }
            queue.asyncAfter(deadline: .now() + delay, execute: self.currentWorkItem!)
        }
    }
}
