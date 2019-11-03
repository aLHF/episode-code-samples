/*:
 # Setters and Key Paths Exercises

 1. In this episode we used `Dictionary`’s subscript key path without explaining it much. For a `key: Key`, one can construct a key path `\.[key]` for setting a value associated with `key`. What is the signature of the setter `prop(\.[key])`? Explain the difference between this setter and the setter `prop(\.[key]) <<< map`, where `map` is the optional map.
 */
let dictSetterType = prop(\Dictionary<String, String>.["WOW"])
let dictSetterWithoutOptionals = (prop(\Dictionary<String, String>.["WOW"]) <<< map) { _ in "123" }
/*:
 2. The `Set<A>` type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn't stop us from defining a functional setter! Define a function `elem` with signature `(A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>`, which is a functional setter that allows one to add and remove a value `a: A` to a set by providing a transformation `(Bool) -> Bool`, where the input determines if the value is already in the set and the output determines if the value should be included.
 */
func elem<A: Hashable>(_ value: A)
  -> (@escaping (Bool) -> Bool)
  -> (Set<A>)
  -> Set<A> {

    return { shouldInclude in
      return { set in
        var copy = set

        if shouldInclude(copy.contains(value)) {
          copy.insert(value)
        }

        return copy
      }
    }
}

let set1: Set<Int> = [1, 2, 3]
print(set1 |> (elem(4)) { _ in true })
/*:
 3. Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?
 */
struct Food {
  var name: String
}

struct Location {
  var name: String
}

struct User {
  var favoriteFoods: [Food]
  var location: Location
  var name: String
}

let user = User(
  favoriteFoods: [Food(name: "tacos"), Food(name: "nachos")],
  location: Location(name: "Brooklyn"),
  name: "John"
)
// prop(\User.favoriteFoods[0].name)
let updatedUser = user |> (prop(\User.favoriteFoods) <<< prop(\.[0].name)) { $0.uppercased() }
updatedUser.favoriteFoods

// Crashes when empty
/*:
 4. Recall from a [previous episode](https://www.pointfree.co/episodes/ep5-higher-order-functions) that the free `filter` function on arrays has the signature `((A) -> Bool) -> ([A]) -> [A]`. That’s kinda setter-like! What does the composed setter `prop(\\User.favoriteFoods) <<< filter` represent?
 */
func filter<A>(_ f: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { array in
    return array.filter(f)
  }
}

// ((Food) -> Bool) -> (User) -> User
let randomFilter = user |> (prop(\User.favoriteFoods) <<< filter) { _ in Bool.random() }
randomFilter.favoriteFoods
/*:
 5. Define the `Result<Value, Error>` type, and create `value` and `error` setters for safely traversing into those cases.
 */
enum Result<Value, Error> {
  case value(Value)
  case error(Error)
}

enum MyError: Error {
  case network
  case login
}

func value<Value, Error>(_ f: @escaping (Value) -> Value) -> (Result<Value, Error>) -> Result<Value, Error> {
  return { result in
    switch result {
    case .value(let value):
      return .value(f(value))

    case .error:
      return result
    }
  }
}

func error<Value, Error>(_ f: @escaping (Error) -> Error) -> (Result<Value, Error>) -> Result<Value, Error> {
  return { result in
    switch result {
    case .error(let error):
      return .error(f(error))

    case .value:
      return result
    }
  }
}

let someResult: Result<Int, MyError> = .value(10)
dump(someResult |> value { $0 * 5 })
dump(someResult |> error { _ in MyError.login })

let errorResult: Result<Int, MyError> = .error(.network)
dump(errorResult |> value { $0 * 5 })
dump(errorResult |> error { _ in MyError.login })
/*:
 6. Is it possible to make key path setters work with `enum`s?
 */
// no
/*:
 7. Redefine some of our setters in terms of `inout`. How does the type signature and composition change?
 */
func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
  return { a in
    a = f(a)
  }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
  return { a in
    var copy = a
    f(&copy)
    return copy
  }
}

func inoutProp<Root, Value>(_ keyPath: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (inout Root)
  -> Void {

    return { update in
      return { root in
        root[keyPath: keyPath] = update(root[keyPath: keyPath])
      }
    }
}

func |> <A>(_ value: A, f: (inout A) -> Void) -> A {
  var copy = value
  f(&copy)
  return copy
}

let check = user |> (inoutProp(\User.favoriteFoods)) { _ in [Food(name: "Tenderloin")] }
check.favoriteFoods

let newCheck = inoutProp(\User.favoriteFoods) <<< map <<< prop(\.name)

let someValue = (10, user)

let whatsHere = someValue |> (second <<< prop(\User.name)) { _ in "" } // for inout we should redeclare <<< or second

func second<A, B>(_ f: @escaping (inout B) -> Void) -> ((A, B)) -> (A, B) {
  return { pair in
    var copy = pair.1
    f(&copy)

    return (pair.0, copy)
  }
}

let andNow = someValue |> (second <<< inoutProp(\User.name)) { _ in "" }

let last = inoutProp(\User.name)({ _ in "Jordan" }) |> fromInout
