import UIKit
//: # Swift Crash Course
//: ## Syntax
//: ### Types
//:Declaring a type is easy - no more header files 😀! Possible types are class, protocol, struct and enum.
class MyClass {

}

protocol MyProtocol {

}

struct MyStruct {

}

enum MyEnum {
    case Thing
}
/*:
### Inheritance
Just like Objective-C you can extend classes and implement protocols.

> Note: You cannot subclass structs or enums but more on that later.
*/
class MySubClass: MyClass {

}
class MyImplementedProtocol: MyClass, MyProtocol {
  
}
/*:
### Properties
Can be declared as `var` or `let` (variables or constants).

> Note: `let` comes from mathematical language. E.g. `let x = 5`

Variables can be changed:
*/
var mutableProperty = true
mutableProperty = false
//: However constants cannot be changed:
let immutableProperty = true
//immutableProperty = false // Compiler fails
/*:
Interestingly, constants behave differently when they are structs compared to classes.

Let's experiment with `UIView` which is a class. Notice how you can mutate the view by changing its background colour.
*/
let view = UIView()
view.backgroundColor = UIColor.greenColor()
//view = UIView() // Compiler fails
/*:
This is different for a struct. Take an `Array` struct. This cannot be mutated.
*/
let array = [1, 2, 3]
//array.append(4) // Compiler fails
/*:
We will discover why in the Structs chapter.

### Methods and Functions
A simple method:
*/
func myMethod() {

}
myMethod()
//: Returning something:
func returnMethod() -> String {
  return "hello!"
}
var result = returnMethod()
//: Method with parameters:
func addNumber(number: Int) {

}
addNumber(5)
//: We can also have the ability to provide default parameters. Very useful for injection for tests:
func defaultMethod(param: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {

}
defaultMethod()
defaultMethod(NSUserDefaults())
//: Parameters are named by default except for the 1st one but you can explicitly name the 1st one by repeating the paramter name.
func explicitlyNamedParam(param param: String) {
  
}
explicitlyNamedParam(param: "Yo")
//: You can also remove parameter labels using `_`.
func removedParameterLabel(param1: String, _ param2: String) {

}
removedParameterLabel("Hello", "World")
/*:
### Initialise and Deinitialise
Like Objective-C, Swift has methods for initialising and deinitialising. Notice how `value` is set in `init(value:)`. Swift properties must be set before the class can be fully initialised even if the property is nil.
*/
class InitClass {

  let value: String

  init(value: String) {
    self.value = value
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
}
let initInstance = InitClass(value: "something")
/*:
You can also use convenience initialiser like `[NSArray array]` in Objective-C. A convenience initialiser must call self.init(...).
*/
extension InitClass {

  convenience init() {
    self.init(value: "default")
  }
}
let initConvenience = InitClass()
/*:
### Iterating
Say goodbye to the traditional for loop `for (int i = 0; i < count; i++)`.

Usually iterating through a collection won't require this and you can use the `for in` syntax:

> Note how the type of `number` is inferred because the element type of the array is `Int`
*/
let numbers = [1, 2, 3]
for number in numbers {
  if number == 1 {
    "You're number 1!"
  }
}
for n in numbers where n % 2 == 0 {
    n
}
//: If you really have to iterate the old way we iterate through an range of integers:
for i in 0..<5 {

}
/*:
This is the same as `for (int i = 0; i < 5; i++)`

### While
While hasn't changed much but `do-while` becomes `repeat-while`:
*/
var i = 1
while i == 1 {
  i--
}

repeat {
  i++
} while i == 0

/*:
### Switch
Switch statements have changed too.

Now `case` statements do not fall through by default and you must handle all cases.
*/
i = 0
switch i {
case 0:
  "You don't have any"
case 1...3:
  "You have a few"
case _ where i > 1000:
  "You have too many"
default:
  "You have many"
}
/*:
### Guard
`guard` statements are used for an early exit strategy. The compiler guarantees that the current scope is exited if the condition fails.
*/
let point = CGPoint(x: 11, y: 10)
func drawPoint(point: CGPoint) -> String {
  let rect = CGRect(x: 0, y: 0, width: 10, height: 20)
  guard rect.contains(point) else {
    return "Will not draw the point \(point)"
  }
  return "Will draw the point \(point)"
}
drawPoint(point)
/*:
### Defer
`defer` statements are Swift's answer to `finally` in most language's `try` `catch` but can be used anywhere. Code within a deter statement is always executed at the end of the scope.
*/
func advanceAfter(inout x: Int) -> Int {
    defer {
        x += 1
    }
    return x
}
var x = 0
advanceAfter(&x) // Think ++i in C++
x
/*:
Now we have a good idea about Swift syntax, let's look at a fundamental concept in Swift: [Optionals ->](Optionals).
*/
