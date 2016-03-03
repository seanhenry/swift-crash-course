import UIKit
import XCPlayground
//: [<- Back to Home](Home)
//: # Swift Crash Course
//: ## Optionals
/*:
Optionals are one of the defining differences between Objective-C and Swift. Properties can have three states:

* Value: Never `nil` always has a value
*/
var neverNil: String = "Never Nil"
//neverNil = nil // Compiler fails
neverNil = "still not nil"
//let isNil = neverNil == nil // Compiler fails
/*:
* Optional: Could be `nil` or could have a value
*/
var optional: String? = "could be nil"
optional = nil
var isNil = optional == nil
/*:
* Implicitly Unwrapped Optional: Could be a `nil` value but no safety when `nil`.
*/
var implicitlyUnwrapped: String! = "could also be nil"
implicitlyUnwrapped = nil
//var startsWithHello = implicitlyUnwrapped.hasPrefix("hello") // Runtime error - DANGEROUS!!
/*:
Implicitly unwrapped optionals should be avoided at all costs. In fact, using the `!` operator often signifies a programming error.

### Accessing Optionals
Accessing pure values is straight forward - no checks are needed because we are guaranteed that the value is not `nil`.
*/
neverNil.hasPrefix("hello")
/*:
Optionals do not allow direct access. Instead you must check whether you have a value or not before accessing it. This is done by safely unwrapping your optional using `if let` syntax.
*/
let optionalView: UIView? = UIView()
//optionalView.backgroundColor = UIColor.greenColor() // Compiler fails
if let view = optionalView {
  view.backgroundColor = UIColor.greenColor()
} else {
  print("Optional view is nil")
}
/*:
Once inside the `if let` scope the new `view` constant is guaranteed to be a value.

This, whilst safe, can lead to verbose code. Swift uses the optional operator to access the underlying value *only* if it is not nil.
*/
optionalView?.backgroundColor = UIColor.greenColor()
//: This operator can be used to chain multiple optionals
let desc = optionalView?.backgroundColor?.description
/*:
The chaining works from the left. Each optional value is queried and if it is `nil` then `nil` is returned. This continues along the chain until either `nil` or the end of the chain is reached.

### Pyramid of Doom
Sometimes it is not suitable to use the `?` syntax and the `if let` syntax can lead to the Pyramid of Doom. This is when we have lots of nested `if` statements - not nice!
*/
if let optional = optional {
  if let view = optionalView {
    // uh oh!
  }
}
//: Swift allows us to unwrap multiple optionals in the same statement
if let optional = optional,
   let view = optionalView {
  // Phew
}
/*:
### Accessing Implicitly Unwrapped Optionals
Implicitly unwrapped optionals are similar to optionals and can be safely unwrapped in the same way. However, they are dangerous because the compiler does not force you to safely unwrap them.

However, there are times when these types are required. For example:
*/
extension UIImage {

  static var customImage: UIImage! {
    return UIImage(named: "custom_image")
  }
}
UIImage.customImage
/*:
Of course, this code is only safe when an image named `custom_image` is in the bundle but our unit tests will take care of that.

### Under the Hood
An optional is actually just an `enum`. The enum has 2 cases; either a value, or nil. It looks something like this:
*/
enum MyOptional<ValueType> {
  case Nil
  case Value(ValueType)
}
/*:
The `ValueType` in the triangle brackets indicates which type the optional could contain. Don't worry about this too much. The important thing is that this is either `nil` or a value.

The `?` operator basically performs a switch statement to determine which it is.
*/
var myOptional = MyOptional<String>.Value("Yoohoo!")
switch myOptional {
case .Nil:
  print("Oh dear, optional is nil")
case .Value(let value):
  print("Hurrah. The value is \(value)")
}
//: Optionals make our code much safer and greatly reduce the number of bugs. The next topic is all about [Value Types ->](ValueTypes)
