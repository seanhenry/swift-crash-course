import Foundation

public func XCTAssert(@autoclosure condition: () -> (Bool)) -> String {
    return condition() ? "✔︎" : "❌"
}