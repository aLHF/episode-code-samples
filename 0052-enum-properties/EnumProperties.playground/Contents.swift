

struct User {
  var name: String
  var isAdmin: Bool
}

/*
let user = User(name: "Blob", isAdmin: true)

user.name
user.isAdmin

enum Validated<Valid, Invalid> {
  case valid(Valid)
  case invalid([Invalid])

  var valid: Valid? {
    guard case let .valid(value) = self else { return nil }
    return value
  }
  var invalid: [Invalid]? {
    guard case let .invalid(value) = self else { return nil }
    return value
  }
}

let validValue = Validated<Int, String>.valid(42)

let optionalValue: Int?
if case let .valid(value) = validValue {
  optionalValue = value
} else {
  optionalValue = nil
}
optionalValue


let users = [
  User(name: "Blob", isAdmin: true),
  User(name: "Blob, Sr.", isAdmin: true),
  User(name: "Blob, Jr.", isAdmin: false)
]

users
  .filter { $0.isAdmin }
  .map { $0.name }


let validatedValues: [Validated<Int, String>] = [
  .valid(1),
  .invalid(["Failed to calculate value"]),
  .valid(42)
]

validatedValues
  .filter {
    guard case .valid = $0 else { return false }
    return true
}

validatedValues
  .map { validated -> Int? in
    guard case let .valid(value) = validated else { return nil }
    return value
}

validatedValues
  .compactMap { validated -> Int? in
    guard case let .valid(value) = validated else { return nil }
    return value
}

validatedValues
  .compactMap { $0.valid }

validatedValues
  .compactMap { $0.invalid }

\Validated<Int, String>.valid

users
  .filter { $0.isAdmin }
  .map { $0.name }


prefix operator ^
prefix func ^ <Root, Value>(_ keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in root[keyPath: keyPath] }
}

validatedValues
  .compactMap(^\.valid)

validatedValues
  .compactMap(^\.invalid)

let validatedUsers: [Validated<User, String>] = [
  .valid(User(name: "Blob", isAdmin: true)),
  .invalid(["Blob Jr. is not old enough"]),
  .valid(User(name: "Blob, Sr.", isAdmin: false))
]

validatedUsers
  .compactMap(^\.valid?.name)

//validatedValues
//  .compactMap(\.valid)

users
  .filter(^\.isAdmin)
  .map(^\.name)

//users
//  .filter(\.isAdmin)
//  .map(\.name)

import Foundation

let results: [Result<Int, Error>] = [
  .success(1),
  .failure(NSError(domain: "co.pointfree", code: -1, userInfo: nil)),
  .success(42)
]

results
  .compactMap { try? $0.get() }

validatedValues
  .compactMap { validated -> Int? in
    guard case let .valid(value) = validated else { return nil }
    return value
}

results
  .compactMap { result -> Error? in
    guard case let .failure(error) = result else { return nil }
    return error
}

*/

/*
 1.While we’ve defined the gets of our enum properties, we haven’t defined our sets. Redefine Validated’s valid and invalid properties to have a setter in addition to its getter.

 2. Take the valid setter for a spin. Assign Validated<Int, String>.valid(1) to a variable and increment the number using the setter.
 */

enum Result<Value, Error> {
  case success(Value)
  case failure(Error)

  var value: Value? {
    get {
      guard case let .success(value) = self else { return nil }
      return value
    }

    set {
      guard let value = newValue else { return } // Maybe we can throw an error if the value is nil
      self = .success(value)
    }
  }

  var failure: Error? {
    guard case let .failure(value) = self else { return nil }
    return value
  }
}

enum SomeError: Error {
  case aaa
  case bbb
}

var test: Result<Int, SomeError> = .success(1)
test
test.value = 2
test
