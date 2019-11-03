/*:
 # Functional Setters Exercises

 1. As we saw with free `map` on `Array`, define free `map` on `Optional` and use it to compose setters that traverse into an optional field.
 */
func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
  return { pair in
    return (f(pair.0), pair.1)
  }
}

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
  return { pair in
    return (pair.0, f(pair.1))
  }
}

func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
  return { a in
    switch a {
    case .some(let value): return f(value)
    case .none: return nil
    }
  }
}

let test: ((Int, String?), Bool) = ((10, "aaa"), false)

test
  |> (first <<< second <<< map) { $0.uppercased() }

/*:
 2. Take the following `User` struct and write a setter for its `name` property. Add another property, and add a setter for it. What are some potential issues with building these setters?
 */
struct Location {
  let name: String
}

struct User {
  let name: String
  let phone: String
  let location: Location
}

extension User: CustomStringConvertible {
  var description: String {
    return "Name: \(name). Phone: \(phone). Location: \(location.name)"
  }
}

// When adding a new property we need to change all setters

func setName(_ f: @escaping (String) -> String) -> (User) -> User {
  return { user in
    return User(name: f(user.name), phone: user.phone, location: user.location)
  }
}

func setPhone(_ f: @escaping (String) -> String) -> (User) -> User {
  return { user in
    return User(name: user.name, phone: f(user.phone), location: user.location)
  }
}

let myUser = User(name: "User", phone: "380636932344", location: Location(name: "Kyiv"))

myUser
  |> setName { _ in "John" }
  |> setPhone { "+" + $0 }


/*:
 3. Add a `location` property to `User`, which holds a `Location`, defined below. Write a setter for `userLocationName`. Now write setters for `userLocation` and `locationName`. How do these setters compose?
 */

// TODO
func setLocationName(_ f: @escaping (String) -> String) -> (User) -> (User) {
  return { user in
    return User(name: user.name, phone: user.phone, location: Location(name: f(user.location.name)))
  }
}

myUser
  |> setLocationName { _ in return "Liverpool" }

func setLocation(_ f: @escaping (Location) -> Location) -> (User) -> (User) {
  return { user in
    return User(name: user.name, phone: user.phone, location: f(user.location))
  }
}

func setLocationName(_ f: @escaping (String) -> String) -> (Location) -> (Location) {
  return { location in
    return Location(name: f(location.name))
  }
}

myUser
  |> (setLocation <<< setLocationName) { _ in return "Dubrovnik" }
/*:
 4. Do `first` and `second` work with tuples of three or more values? Can we write `first`, `second`, `third`, and `nth` for tuples of _n_ values?
 */

// 4
func first<A, B, C, D, E>(_ f: @escaping (A) -> E) -> ((A, B, C, D)) -> (E, B, C, D) {
  return { tuple in
    (f(tuple.0), tuple.1, tuple.2, tuple.3)
  }
}

func second<A, B, C, D, E>(_ f: @escaping (B) -> E) -> ((A, B, C, D)) -> (A, E, C, D) {
  return { tuple in
    (tuple.0, f(tuple.1), tuple.2, tuple.3)
  }
}

func third<A, B, C, D, E>(_ f: @escaping (C) -> E) -> ((A, B, C, D)) -> (A, B, E, D) {
  return { tuple in
    (tuple.0, tuple.1, f(tuple.2), tuple.3)
  }
}

func fourth<A, B, C, D, E>(_ f: @escaping (D) -> E) -> ((A, B, C, D)) -> (A, B, C, E) {
  return { tuple in
    (tuple.0, tuple.1, tuple.2, f(tuple.3))
  }
}

let fourTuple = (1, 2, 3, 4)

fourTuple
  |> first(incr)
  |> second(incr)
  |> third(incr)
  |> fourth(incr)
/*:
 5. Write a setter for a dictionary that traverses into a key to set a value.
 */
func map<Key: Hashable, Value>(_ f: @escaping (Key) -> Value) -> ([Key: Value]) -> [Key: Value] {
  return { dict in
    var dict = dict
    dict.keys.forEach { dict[$0] = f($0) }
    return dict
  }
}

let someDict = ["a": "Value1", "b": "Value2", "c": "Value3"]
someDict
  |> map { $0 + "1" }
/*:
 6. What is the difference between a function of the form `((A) -> B) -> (C) -> (D)` and one of the form `(A) -> (B) -> (C) -> D`?
 */
// TODO

var firstFunc: ((Int) -> Int) -> (Int) -> Int = { someFunc in
  return { someValue in
    return 1
  }
}

var secondFunc: (Int) -> (Int) -> (Int) -> (Int) = { a in
  return { b in
    return { c in
      return 10
    }
  }
}
