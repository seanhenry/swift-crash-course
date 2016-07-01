import Foundation
//: [Back to Generic Protocols](GenericProtocols)
/*:
 # Swifty Swift
 ## To nil or not to nil?
 Perhaps the most important change in Swift. Sir Charles Antony Richard Hoare invented the null reference and later said this about the subject:
 
 - note: I call it my billion-dollar mistake. It was the invention of the null reference in 1965. At that time, I was designing the first comprehensive type system for references in an object oriented language (ALGOL W). My goal was to ensure that all use of references should be absolutely safe, with checking performed automatically by the compiler. But I couldn't resist the temptation to put in a null reference, simply because it was so easy to implement. This has led to innumerable errors, vulnerabilities, and system crashes, which have probably caused a billion dollars of pain and damage in the last forty years. In recent years, a number of program analysers like PREfix and PREfast in Microsoft have been used to check references, and give warnings if there is a risk they may be non-null. More recent programming languages like Spec# have introduced declarations for non-null references. This is the solution, which I rejected in 1965.
 
 Now with Swift we can, *and should*, move away from using null references.
 1. **Always prefer** non-optionals.
 2. **Always prefer** optionals over implicitly unwrapped optionals.
 3. **Always avoid** implicitly unwrapped optionals.

 - note: Sometimes implicitly unwrapped optionals can't be avoided such as @IBOutlet but if you find yourself requiring them elsewhere think long and hard about why.
 
 Swift 3 actually removes the `ImplicitlyUnwrappedOptional` type ([SE0054](https://github.com/apple/swift-evolution/blob/master/proposals/0054-abolish-iuo.md)) stating "IUO is a valuable tool for importing Objective-C APIs but is a transitional technology that represents the lack of language features that could more elegantly handle the problem."
 */

/*:
 ### Avoiding nil
 Sometimes nil is difficult to avoid. Consider the following example:
 
 - example: I would like to create a program to record exactly 10 seconds of audio from the microphone. I would also like to start recording after a user defined amount of time instead of starting immediately.
 
 It feels like we need optionals here. One for the file to record to and one for each countdown timers.
 */
class OptionalAudioRecorder {

    private var file: NSURL?
    private var countdownUntilRecordingStarts: CountdownTimer?
    private var countdownUntilRecordingFinishes: CountdownTimer?

    func startRecording(to file: NSURL) {
        self.file = file
        countdownUntilRecordingStarts = CountdownTimer(seconds: 5)
    }
}
/*:
 When we start to add more functionality such as `cancel` we cannot be sure of the state.
 */
extension OptionalAudioRecorder {

    func cancel() {
        if let _ = countdownUntilRecordingStarts { // is waiting to record
            // stop countdown
            // stop recording from microphone
        }
        if let _ = countdownUntilRecordingFinishes { // is recording
            // stop countdown
            // stop recording from microphone
        }
        if let _ = file { // unsure of state
            // delete file
        }
    }
}
/*:
 The following example uses and enum to provide a way to eliminate optionals.
 */
class BetterAudioRecorder {

    private enum State {
        case Idle
        case WaitingToRecord(NSURL, CountdownTimer)
        case Recording(NSURL, CountdownTimer)
    }

    private var state: State = .Idle

    func startRecording(to file: NSURL) {
        guard case .Idle = state else {
            cancel()
            return
        }
        state = .WaitingToRecord(file, CountdownTimer(seconds: 5))
        // start timer and call startRecording() when ready
    }

    private func startRecording() {
        if case let .WaitingToRecord(file, _) = state {
            state = .Recording(file, CountdownTimer(seconds: 10))
            // start recording
        }
    }

    func cancel() {
        switch state {
        case let .WaitingToRecord(file, countdown):
            removeFile(file)
            stopCountdown(countdown)
            break
        case let .Recording(file, countdown):
            removeFile(file)
            stopCountdown(countdown)
            stopRecording()
            break
        default:
            break
        }
    }

    private func removeFile(file: NSURL) {}
    private func stopCountdown(countdown: CountdownTimer) {}
    private func stopRecording() {}
}

/*:
 This example is quite complex but note that there are now no optionals and therefore no ambiguity of the state of the recorder. The `State` enum not only defines the state but also holds information relavant to that state *and only that state*.

 Programming in this way will define the behaviour of your code and make it robust and easier to understand. Unambiguous behaviour also means fewer unit tests because you no longer have to test those ambiguous edge cases. 🎉
 */

/*:
 ## Embrace value types
 Another incredibly important feature of Swift. Value types offer great benefits as described in an [earlier chapter](ValueTypes) but when should you use them?
 
 ### Value Type
 - Where comparing state makes sense.
 - No asynchronous behaviour.
 - State is not shared with other objects.
 
 ### Reference Type
 - Where comparing instances makes sense.
 - Behaviour is asynchronous.
 - State is shared between other objects.
 
 ### Examples of value types:
 - Models objects.
 - URL request builder.
 - JSON parser.
 
 ### Examples of reference types:
 - Feature flags.
 - Network operations.
 - VIPER components.
 */
/*:
 ## Naming
 The language we use to name properties and methods has become a real focus for Swift 3. These are likely to change over time so read about them [here](https://swift.org/documentation/api-design-guidelines/).
 
 Naming is also important when bridging from Objective-C. [This article](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html) describes how to optimise name Objective-C code for swift. See `NS_SWIFT_NAME`, `NS_SWIFT_UNAVAILABLE`, and `NS_REFINED_FOR_SWIFT`.

 ## Overloading and Default Arguments
 Swift offers these new features language features and we should take advantage of them when designing our APIs. For example, Objective-C animation APIs have the following methods:
 
 `- (void)animateWithDuration:animations:`
 
 `- (void)animateWithDuration:animations:completion:`
 
 Now in Swift we should write:
 */
func animate(forSeconds duration: Double, animations: () -> (), completion: ((Bool) -> ())? = nil) {

}
//: We can still call the method in all the same ways as before.
animate(forSeconds: 1, animations: {

})

animate(forSeconds: 1, animations: {

}, completion: { _ in

})
/*:
 ## Playing nicely with Objective-C
 Another challenge we face is writing Swift which can still bridge to Objective-C.
 
 The solution is simple. **Never** compromise Swift code for the sake of bridging to Objective-C. **Always** use Swift to its full potential even if it can't bridge to Objective-C.
 
 If you find yourself in a position where you must bridge Swifty Swift to Objective-C then write a simple Objective-C compatible wrapper.
 */
enum Result {
    case Success(String)
    case Failure(String)
}

class Swifty {

    func doSomething(result: Result -> ()) {
        result(.Success("Success!"))
    }
}
//: Create a wrapper for Objective-C if you need one.
class Wrapped: NSObject {
    let swifty = Swifty()

    func doSomething(result: (String?, String?) -> ()) {
        swifty.doSomething { r in
            switch r {
            case .Success(let string):
                result(string, nil)
            case .Failure(let error):
                result(nil, error)
            }
        }
    }
}
/*:
 Similarly if you find yourself needing to access a value type in Objective-C you could write a wrapper for that too. You would lose value semantics but at least your Swift code can still take advantage.
 */
struct SwiftyStruct {
    var value = "hi"
}

class WrappedStruct: NSObject {

    var swifty = SwiftyStruct()

    var value: String {
        set { swifty.value = newValue }
        get { return swifty.value }
    }
}
