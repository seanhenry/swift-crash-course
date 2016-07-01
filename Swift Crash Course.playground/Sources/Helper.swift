import Foundation

public func XCTAssert(@autoclosure condition: () -> (Bool)) -> String {
    return condition() ? "✔︎" : "❌"
}

public struct CountdownTimer {
    public let seconds: Double

    public init(seconds: Double) {
        self.seconds = seconds
    }
}
