import Foundation

public func XCTAssert(@autoclosure condition: () -> (Bool)) -> String {
    return condition() ? "✔︎" : "❌"
}

public struct CountdownTimer {
    let seconds: Double
}
