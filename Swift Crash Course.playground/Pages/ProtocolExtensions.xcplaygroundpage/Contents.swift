import Foundation
import CoreGraphics
//: [<- Back to Collection Types](Collections)
//: # Swift Crash Course
//: ## Extensions
extension String {
    func prepend(other: String) -> String {
        return other + self
    }
}
"extensions".prepend("Swift ")
/*:
### Conditional Extensions
Extensions in Swift are very similar to categories in Objective-C. They are a way to extend functionality of types without creating a subclass.

New in Swift is the ability to conditionally extend a type. In the previous page we created a protocol extension. Let's look and explain this simple example.
*/
extension Array where Element: Hashable {

  func filterDuplicates() -> [Element] {
    return Array(Set<Element>(self))
  }
}
/*:
We use the `where` keyword to extend `Array` but only when the `Array`'s `Element` conforms to the `Hashable` protocol.

`String` conforms to `Hashable` so an array of strings can use this method.
*/
["s", "t", "s"].filterDuplicates()
//: However, if we create a class which doesn't conform to `Hashable` we get a compiler error.
class MyClass {}
//[MyClass(), MyClass()].filterDuplicates() // Compiler fails
//: This allows us to reuse more code.
//: ### Protocol Extensions
/*:
Protocol extensions are one of the most interesting changes in Swift. They provide a way to inherit multiple implementations safely and conditionally. Think of them as default implementations for protocols.

There are few different use cases for protocol extensions:
* Extending derived methods
*/
protocol Drawable {
  func moveToPoint(x x: Int, y: Int)
  func drawLineToPoint(x x: Int, y: Int)
  func drawSquareAtPoint(x x: Int, y: Int, size: Int)
}
/*:
The `Drawable` protocol is a simple interface which allows the user to draw lines and shapes. We might have a `CoreGraphics` and `OpenGLES` implementation; however `drawSquareAtPoint x:y:` should be reusable between both implementations so we can extend this protocol.
*/
extension Drawable {

  func drawSquareAtPoint(x x: Int, y: Int, size: Int) {
    moveToPoint(x: x, y: y)
    drawLineToPoint(x: x, y: y + size)
    drawLineToPoint(x: x + size, y: y + size)
    drawLineToPoint(x: x + size, y: y)
    drawLineToPoint(x: x, y: y)
  }
}
//: This means that when conforming to the `Drawable` protocol we don't need to implement that method.
struct ConsoleDrawable: Drawable {

  func moveToPoint(x x: Int, y: Int) {
    print("Moving to point (\(x), \(y))")
  }

  func drawLineToPoint(x x: Int, y: Int) {
    print("Drawing to point (\(x), \(y))")
  }
}
ConsoleDrawable().drawSquareAtPoint(x: 0, y: 0, size: 5)
/*:
* An alternative to inheritance.

Inheritance may not be suitable or your objects may be value types which do not support inheritance. 

In this next example we have a game. We want our game objects to be rendered on screen and collide with other objects so we create protocols to define this behaviour.
*/
protocol Renderable {
  var name: String { get }
  var frame: CGRect { get set }
  func draw()
}
protocol Collidable {
  var frame: CGRect { get }
  func collides(collidable: Collidable) -> Bool
}
/*:
We want to get the most out of value types so we will be using `struct`s to define our game objects. `struct`s don't support inheritance so can't inherit behaviour from a base class.
*/
extension Renderable {
  func draw() {
    print("Drawing \(name) to coordinates \(frame)")
  }
}
extension Collidable {
  func collides(collidable: Collidable) -> Bool {
    return frame.intersects(collidable.frame)
  }
}
/*:
This solution works particularly well because now we can inherit specific behaviours from each protocol extension.

Protocol extensions allows us to choose which behaviours to inherit so we can have a background object that cannot collide with other objects but is drawn on screen. We can also have characters such as `Hero` and `Enemy` who can collide with each other.
*/
struct BackgroundObject: Renderable {

  var name = "BackgroundObject"
  var frame = CGRect(x: 0, y: 0, width: 50, height: 50)
}

struct Hero: Renderable, Collidable {
  var name = "Hero"
  var frame = CGRect(x: 10, y: 0, width: 20, height: 20)
}

struct Enemy: Renderable, Collidable {

  var name = "Enemy"
  var frame = CGRect(x: 20, y: 0, width: 10, height: 10)
}

let background = BackgroundObject()
let hero = Hero()
let enemy = Enemy()
// Render
let renderables: [Renderable] = [background, hero, enemy]
renderables.forEach { $0.draw() }
// Collide
//hero.collides(background) // Compiler fails
hero.collides(enemy)
/*:
* Reuse the same behaviour and cut down on dependencies.

We might have a `LoginViewController` and a `RegisterViewController` which share email address validation. We could inject this as a dependency but we have trouble injecting dependencies into view controllers because they are instantiated by storyboards.
*/
class LoginViewController {

  func login() {}
}
class RegisterViewController {

  func register() {}
}
//: We can write the email address validation logic once in a protocol extension and share it by both view controllers.
protocol EmailAddressValidator {

  func isEmailAddressValid(email: String) -> Bool
}

extension EmailAddressValidator {

  func isEmailAddressValid(email: String) -> Bool {
    return email.containsString("@")
  }
}

extension LoginViewController: EmailAddressValidator {}
extension RegisterViewController: EmailAddressValidator {}
LoginViewController().isEmailAddressValid("badEmail")
RegisterViewController().isEmailAddressValid("good@email.com")

