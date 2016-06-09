import Swift
//: [Previous](@previous)
/*:
 # Generic Protocols
 *Consider the following example.*
 
 I would like to create a generic way to cache data. I would also like to fetch that data transparently; i.e. I would like to have one method call that will fetch cached data if it exists or fetch from a remote location if not.
 
 This can be achieved using a generic class:
 */
struct MyData {}

class DataStoreClass<DataType> {

    private(set) var data: DataType?

    func fetch(completion: (DataType) -> ()) {
        if let data = data {
            completion(data)
            return
        }
        fetchRemotely(completion)
    }

    func fetchRemotely(completion: (DataType) -> ()) {
        fatalError() // must be implemented by sub class
    }
}

class MyDataStoreClass: DataStoreClass<MyData> {

    override func fetchRemotely(completion: (MyData) -> ()) {
        // pretend to fetch from URL
        completion(MyData())
    }
}
/*:
 Although this technique will work it is trying to take advantage of the concept of an abstract method which Swift doesn't currently support.
 
 It will not be immediately obvious to fresh eyes that you must override the `fetchRemotely(_:)` method.
 
 One way to solve this issue is to use a protocol with a default implementation.
 */
protocol DataStoreProtocol: class {

    associatedtype DataType
    var data: DataType? { get set }
    func fetch(completion: (DataType) -> ())
    func fetchRemotely(completion: (DataType) -> ())
}
//: The implementation of `fetch(_:)` is the same as before.
extension DataStoreProtocol {

    func fetch(completion: (DataType) -> ()) {
        if let data = data {
            completion(data)
            return
        }
        fetchRemotely(completion)
    }
}
//: Now when creating a specific data store we are forced implement the `fetchRemotely(_:)` method otherwise we will get a compiler error.
class MyDataStoreImpl: DataStoreProtocol {

    var data: MyData?
    func fetchRemotely(completion: (MyData) -> ()) {
        // pretend to fetch from URL
        completion(MyData())
    }
}
/*:
 ## Type Erasure
 Generic protocols have a flaw of their own. Once they contain an associated type they can no longer be referenced directly.
 */
// compiler error
//let p: DataStoreProtocol = MyDataStoreImpl()
//: You may now only pass in the protocol as a generic constraint.
func doSomething<T: DataStoreProtocol>(dataStore: T) {
    dataStore.fetch { _ in }
}
/*:
 This is a problem because passing around a data store by its concrete type violates the dependency inversion principle. For example, I could have a HTTPDataStore and FileDataStore but could not take advantage of polymorphism. This would make the code much more rigid and difficult to change.
 
 Type erasure solves this problem by wrapping the generic protocol within a generic class. Apple use this pattern for `SequenceType` and `CollectionType`.
 
 `AnySequence` allows us to pass around a sequence type containing a specific element type which is useful for encapulating a specific data structure. If the actual data structure is encapsulated then changing the data structure is easy.
 */
protocol EncapsulatingExampleProtocol {
    var dataStructure: AnySequence<Int> { get }
    func printData()
}

class EncapsulatingExample: EncapsulatingExampleProtocol {

    var dataStructure: AnySequence<Int> = AnySequence([1, 2, 3])

    func printData() {
        for data in dataStructure {
            print(data)
        }
    }
}
EncapsulatingExample().printData()
/*:
 - experiment: Try replacing the Array with another data structure like a Set without changing the interface of the protocol or the implementation of `printData()`.
 */
/*:
 ## Creating Type Erasure
 Implementing type erasure is quite straight forward. You must create a wrapper that forwards all methods to a generic protocol.
 */
class AnyDataStore<DataType>: DataStoreProtocol {

    private let _fetch: ((DataType) -> ()) -> ()
    private let _fetchRemotely: ((DataType) -> ()) -> ()
    private let setData: (DataType?) -> ()
    private let getData: () -> (DataType?)

    var data: DataType? {
        set { setData(newValue) }
        get { return getData() }
    }

    init<T: DataStoreProtocol where T.DataType == DataType>(_ dataStore: T) {
        _fetch = dataStore.fetch
        _fetchRemotely = dataStore.fetchRemotely
        setData = { data in dataStore.data = data }
        getData = { dataStore.data }
    }

    func fetch(completion: (DataType) -> ()) {
        _fetch(completion)
    }

    func fetchRemotely(completion: (DataType) -> ()) {
        _fetchRemotely(completion)
    }
}
/*:
 Type erasure isn't pretty especially with a property but now we can use polymorphism with a generic protocol which allows us to change the implementation without changing the interface.
 */
class HTTPDataStore: DataStoreProtocol {
    var data: MyData?

    func fetchRemotely(completion: (MyData) -> ()) {
        print("fetching from server")
        completion(MyData())
    }
}

class FileDataStore: DataStoreProtocol {
    var data: MyData?

    func fetchRemotely(completion: (MyData) -> ()) {
        print("loading from file")
        completion(MyData())
    }
}

class PolymorphismExample {

    let dataStore: AnyDataStore<MyData>
    init(dataStore: AnyDataStore<MyData>) {
        self.dataStore = dataStore
    }

    func doSomething() {
        dataStore.fetch { data in
            // do something with data
        }
    }
}

PolymorphismExample(dataStore: AnyDataStore(HTTPDataStore())).doSomething()
PolymorphismExample(dataStore: AnyDataStore(FileDataStore())).doSomething()
/*:
 Hopefully Swift will have better support for generic protocols expecially since there is such a heavy focus on protocol oriented programming. But this is a pattern we can use in the meantime to get the most out of our protocols.
 
 ## Testing
 We can also use type erasure to create one mock for any DataType.
 */
class MockDataStore<DataType>: DataStoreProtocol {

    var data: DataType?

    var didFetch = false
    func fetch(completion: (DataType) -> ()) {
        didFetch = true
    }

    var didFetchRemotely = false
    func fetchRemotely(completion: (DataType) -> ()) {
        didFetchRemotely = true
    }
}
let mockedDataStore = MockDataStore<MyData>()
let sut = PolymorphismExample(dataStore: AnyDataStore(mockedDataStore))
sut.doSomething()
XCTAssert(mockedDataStore.didFetch)
