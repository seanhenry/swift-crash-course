import Foundation
//: [<- Back to Optionals](Optionals)
//: # Swift Crash Course
//: ## Value Types
/*:
The big difference with Swift types is that they are all 1st class citizens. This means structs and enums can now contain methods and functions. Methods can even contain methods! They can also implement protocols and be extended (like an Objective-C category).
*/
protocol Emojiable {
  func toEmoji() -> String
}

enum Suit {
  case Spades
  case Diamonds
  case Clubs
  case Hearts
}

extension Suit: Emojiable {

  func toEmoji() -> String {
    switch self {
    case .Spades:
      return "♠️"
    case .Diamonds:
      return "♦️"
    case .Clubs:
      return "♣️"
    case .Hearts:
      return "♥️"
    }
  }
}

func method() {
  func innerMethod() {

  }
  class InnerClass {

  }
}
Suit.Clubs.toEmoji()
/*:
### Structs
Structs are a very important and exciting development in Swift. They are value types meaning they are not pointers to a piece of memory. This means that everytime you assign a value type to a property it creates a copy of itself.

Think of a value type like an NSInteger in Objective-C.

    -(void)increment:(NSInteger)i {
        i++;
    }
    NSInteger i = 0; // i is 0
    [self increment:i]; // i is still 0

Value types have certain benefits over classes:
* Safer code because changing a struct in one place doesn't change it in the other.
* Structs can't be subclassed which often leads to better design.
* Copying a structure each time it is assigned helps in a multithreaded environment.

Structs work particularly well for model objects and it is a good idea to implement the equatable protocol since you can't compare pointers.
*/
struct PlayingCard: Equatable {
  let number: Int
  let suit: Suit
}

func ==(lhs: PlayingCard, rhs: PlayingCard) -> Bool {
  return lhs.number == rhs.number && lhs.suit == rhs.suit
}
PlayingCard(number: 2, suit: .Clubs) == PlayingCard(number: 2, suit: .Clubs)
PlayingCard(number: 2, suit: .Clubs) == PlayingCard(number: 3, suit: .Hearts)
/*:
### Structs for Undo
Imagine you have a simple text editor app. You want to keep a track of the user's changes so they can revert them later. Structs provide a natural way to keep a record of the previous states of your user's text.
*/
struct Document {
    var text = ""

    mutating func append(string: String) {
        text += string
    }
}

class HistoryManager {
    var array = [Document]()

    func append(string :String) {
        var doc = currentDocument()
        doc.append(string)
        array.append(doc)
    }

    func revert() {
        array.popLast()
    }

    func currentDocument() -> Document {
        return array.last ?? Document()
    }
}

let historyManager = HistoryManager()

historyManager.append("Hello")
historyManager.currentDocument().text

historyManager.append(" Woarld")
historyManager.currentDocument().text

historyManager.revert()
historyManager.currentDocument().text

historyManager.append(" World")
historyManager.currentDocument().text
/*:
### Enums
Enums are also incredibly useful.

They can be simple cases like the `Suit` enum.

Or they can be backed by a type.
*/
enum TypeBacked: String {
  case Value1 = "SomeValue"
  case Value2 // my value is Value2
}
TypeBacked(rawValue: "SomeValue")
TypeBacked(rawValue: "Value2")
//: They can even contain different types and multiple things.
enum MultipleEnum {
  case Message(String)
  case Error(NSError, String)
}
MultipleEnum.Message("A message")
MultipleEnum.Error(NSError(domain: "domain", code: 123, userInfo: nil), "An error occurred")
//: They can even derive their value from a generic type.
enum Result<ResultType, FailureType> {
  case Success(ResultType)
  case Failure(FailureType)
}
/*:
A common pattern in Objective-C, perhaps when doing something asynchronous, is to provide a block with the result and/or an error. 

    - (void)performRequestWithCompletion:(void(^)(NSString *result, NSError *error))completion {

    }

    [self performRequestWithCompletion:^(NSString *result, NSError *error) {

    }];

There is so much ambiguity here. We could assume that when there is a result there is no error and vice versa but there's no compile time way to guarantee that fact.

The above enum quite elegantly fixes this problem.
*/
func performRequestWithCompletion(completion: (Result<String, NSError>) -> ()) {
  completion(.Success("yay!"))
}

performRequestWithCompletion { (result) -> () in
  switch result {
  case .Success(let string):
    print("success! \(string)")
  case .Failure(let error):
    print("boo \(error)")
  }
}
//: Collections like Arrays and Dictionaries benefit greatly from being value types and is the subject of the [next chapter](Collections).
