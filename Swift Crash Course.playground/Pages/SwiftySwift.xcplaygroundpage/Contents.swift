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
 
 - example: I would like to create a type to record exactly 10 seconds of audio from the microphone. I would also like to start recording after a user defined amount of time instead of starting immediately.
 
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
 Enums provide a way to eliminate optionals.
 
 This example is quite complex but note that there are now no optionals and therefore no ambiguity of the state of the recorder. The `State` enum not only defines the state but also holds information relavant to that state *and only that state*.
 
 Programming in this way will define the behaviour of your code and make it robust and easier to understand. Unambiguous behaviour also means fewer unit tests because you no longer have to test those ambiguous edge cases. 🎉
 */
class BetterAudioRecorder {

    private enum State {
        case Unloaded
        case WaitingToRecord(NSURL, CountdownTimer)
        case Recording(NSURL, CountdownTimer)
    }

    private var state: State = .Unloaded

    func startRecording(to file: NSURL) {
        guard case .Unloaded = state else {
            cancel()
            return
        }
        state = .WaitingToRecord(file, CountdownTimer(seconds: 5))
        // start timer and call startRecording() when ready
    }

    private func startRecording() {
        if case .WaitingToRecord(let file, _) = state {
            state = .Recording(file, CountdownTimer(seconds: 10))
            // start recording
        }
    }

    func cancel() {
        switch state {
        case .WaitingToRecord(let file, let countdown):
            removeFile(file)
            stopCountdown(countdown)
            break
        case .Recording(let file, let countdown):
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
