import Foundation
//: [<- Back to Optionals](Optionals)
//: # Swift Crash Course
//: ## Collection Types
//: ### Declaration
/*:
Collections are now generic meaning they contain elements of a certain type defined at compile time.
A verbose way to declare an `Array` of `String`s for example:
*/
let verboseArray: Array<String> = ["hello"]
//: Can also be written as:
let verboseArray2: [String] = ["hello"]
//: A dictionary is similar.
let verboseDictionary: Dictionary<String, Int> = ["key" : 123]
let verboseDictionary2: [String : Int] = ["key" : 123]
/*:
### Accessing Collection Types
Arrays and dictionaries are accessed in similar ways to Objective-C.
*/
verboseArray[0]
verboseDictionary["key"]
//: One noticable difference is that an array will throw a runtime error if a value doesn't exist whereas a dictionary returns an optional.
//verboseArray[1] // Compiler fails
verboseDictionary["not a key"]
/*: 
### Implicit Declaration
The preferred way to declare collections is to let the comiler figure out the type itself.
*/
let implicitArrayOfInts = [1, 2, 3]
let implicitDictionary = ["key" : 123]
implicitArrayOfInts.dynamicType
implicitDictionary.dynamicType
//: Sometimes this isn't possible in which case we should declare collections like this:
var emptyArray = [Int]()
let emptyDictionary = [String : Int]()
/*:
### Value Types
Collections in Swift are no longer classes; they are value types but more on that in the next chapter. This means no more `NSArray` and `NSMutableArray`. Instead we use let and var.
*/
var mutableArray = [1, 2, 3]
mutableArray.append(4)
let immutableArray = [1, 2, 3]
//immutableArray.append(4) // Compiler fails
/*:
Value types don't behave like class instances. Here we assign `mutableArray` to `mutableArray2` and you'll notice that changes to `mutableArray` do not affect `mutableArray2`.
*/
var mutableArray2 = mutableArray
mutableArray.append(666)

mutableArray
mutableArray2
/*:
### Bridging with Objective-C
Swift collections bridge to their Obj-C counterpart.
*/
var nsArray = NSMutableArray()
nsArray.addObject("A string")
let swiftArray = nsArray as [AnyObject]
swiftArray.dynamicType
//: However, the Swift `Array` is still a struct and is immutable.
nsArray.addObject("Another string")
swiftArray
//: You can also bridge to Objective-C arrays from Swift.
let objCArray = swiftArray as NSArray
objCArray.dynamicType
//: The bridging can be clever. Let's say we have a method accepting an Objective-C array. Swift will automatically bridge for us without having to cast.
func objCMethod(array: NSArray) {

}
objCMethod(swiftArray)
/*:
Whilst it is possible to bridge with Objective-C we should always be using the Swift SDK in Swift code.
### CollectionType Protocol
All collections implement the `CollectionType` protocol which provides a useful interface for manipulting collections of data.
*/
let array = [1, 2, 3, 4]
array[0]
array.isEmpty
array.count
array.first
array[0..<2]
/*:
### Transforming Collections
Swift Collections come with some powerful functions to help with manipulation of their data.
### Map
`map` transforms one collection to another. Let's say we have a list of prices and want to transform these prices to include a 10% off promotional offer.
*/

let prices = [2.20, 6.00, 4.50]
var transformed = prices.map { (price) -> Double in
  return price * 0.9
}
//: This is a little verbose. We can improve this with shorthand. Each argument in the block is obtained by `$n` where `n` is the index where the argument appears in the closure.
transformed = prices.map { $0 * 0.9 }
transformed
//: Or if this is not obvious enough we can name the argument and then use it as normal
transformed = prices.map { price in price * 0.9 }
transformed
//: Or if is a little difficult to read we can pass in a function.
func applyPromotion(price: Double) -> Double {
  return price * 0.9
}
transformed = prices.map(applyPromotion)
//: We can also use map to create arrays of a different type. For example, let's say we want to get an array of rounded prices.
let rounded = prices.map { Int(round($0)) }
rounded
/*:
### Filter
`filter` provides a way of quickly and easily filtering values in a collection. Let's say we only want to display products the user can afford and their budget is £5.
*/
var affordable = prices.filter { (price) -> Bool in
  return price <= 5
}
affordable = prices.filter { $0 <= 5 }
affordable
/*:
### Reduce
`reduce` converts a collection into a different object. Let's say we want to convert the array into a message.
*/
var messagePrefix = "Hello, today's prices are:"
var message = prices.reduce(messagePrefix) { $0 + " £\($1)" }
prices.reduce(messagePrefix) { (message, price) -> String in
  return message + " £\(price)"
}
message
/*:
### Chaining
You can also chain these functions together. Let's say that we want to create a message for prices the user can afford.
*/
messagePrefix = "Hello, the prices you can afford are:"
message = prices.filter { $0 <= 5 }
                .reduce(messagePrefix) { $0 + " £\($1)" }
message
/*:
### Flat Map  
Flat map can flatten a 2D collection. For example, let's say we have a collection of `Product` objects which in turn contain a collection of colours. We might want to list all the available colours.
*/
enum Color {
  case Black, White, Green
}
struct Product {
  var colors = [Color]()
}

let tShirt = Product(colors: [.Green, .Black])
let mug = Product(colors: [.White, .Black])
let products = [tShirt, mug]

var colors = products.flatMap { $0.colors }
colors
//: And for completeness we could filter out the duplicates using a protocol extension.
extension Array where Element: Hashable {

  func filterDuplicates() -> [Element] {
    return Array(Set<Element>(self))
  }
}
colors.filterDuplicates()
//: This extension allows us to filter any array whose elements conform to the `Hashable` protocol. More on protocol extensions [next ->](ProtocolExtensions)
