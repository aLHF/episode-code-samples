/*:
 # Tagged Exercises

 1. Conditionally conform Tagged to ExpressibleByStringLiteral in order to restore the ergonomics of initializing our User’s email property. Note that ExpressibleByStringLiteral requires a couple other prerequisite conformances.
 */
struct Tagged<Tag, RawValue> {
  var rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(rawValue: try container.decode(RawValue.self))
  }
}

extension Tagged: Equatable where RawValue: Equatable {
  static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

enum EmailTag {}
typealias Email = Tagged<EmailTag, String>

struct User: Decodable, CustomStringConvertible {
  enum IDTag {}
  enum AgeTag {}

  typealias ID = Tagged<IDTag, Int>
  typealias Age = Tagged<AgeTag, Int>

  let id: ID
  let age: Age
  let name: String
  let email: Email

  var description: String {
    return "ID: \(id.rawValue). Age: \(age.rawValue). Name: \(name). Email: \(email.rawValue)"
  }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
  typealias IntegerLiteralType = RawValue.IntegerLiteralType

  init(integerLiteral value: RawValue.IntegerLiteralType) {
    self.init(rawValue: RawValue(integerLiteral: value))
  }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
  typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType

  init(unicodeScalarLiteral value: RawValue.UnicodeScalarLiteralType) {
    self.init(rawValue: RawValue(unicodeScalarLiteral: value))
  }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
  typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType

  init(extendedGraphemeClusterLiteral value: RawValue.ExtendedGraphemeClusterLiteralType) {
    self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: value))
  }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
  typealias StringLiteralType = RawValue.StringLiteralType

  init(stringLiteral value: RawValue.StringLiteralType) {
    self.init(rawValue: RawValue(stringLiteral: value))
  }
}

User(id: 1, age: 23, name: "John", email: "john95@gmail.com")

/*:
 2. Conditionally conform Tagged to Comparable and sort users by their id in descending order.
 */
extension Tagged: Comparable where RawValue: Comparable {
  static func < (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    return lhs.rawValue < rhs.rawValue
  }
}

let users = [
  User(id: 1, age: 23, name: "John", email: "john95@gmail.com"),
  User(id: 2, age: 23, name: "Lilly", email: "lilly95@gmail.com"),
  User(id: 3, age: 23, name: "Chris", email: "chris95@gmail.com")
]

print(users.sorted(by: { $0.id > $1.id }))
print(users.sorted(by: { $0.email > $1.email }))
/*:
 3. Let’s explore what happens when you have multiple fields in a struct that you want to strengthen at the type level. Add an age property to User that is tagged to wrap an Int value. Ensure that it doesn’t collide with User.Id. (Consider how we tagged Email.)
 */
let user3 = User(id: 1, age: 99, name: "Kirk", email: "mail@gmail.com")
user3.age == user3.age
//user3.age == user3.id
/*:
 4. Conditionally conform Tagged to Numeric and alias a tagged type to Int representing Cents. Explore the ergonomics of using mathematical operators and literals to manipulate these values.*/

extension Tagged: Numeric where RawValue: Numeric {
  init?<T>(exactly source: T) where T : BinaryInteger {
    guard let value = RawValue(exactly: source) else { return nil }

    self.init(rawValue: value)
  }

  var magnitude: RawValue.Magnitude {
    return rawValue.magnitude
  }

  static func + (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
    return Tagged(rawValue: rhs.rawValue + lhs.rawValue)
  }

  static func += (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
    lhs = Tagged(rawValue: lhs.rawValue + rhs.rawValue)
  }

  static func - (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
    return Tagged(rawValue: rhs.rawValue - lhs.rawValue)
  }

  static func -= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
    lhs = Tagged(rawValue: lhs.rawValue - rhs.rawValue)
  }

  static func * (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Tagged<Tag, RawValue> {
    return Tagged(rawValue: rhs.rawValue * lhs.rawValue)
  }

  static func *= (lhs: inout Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) {
    lhs = Tagged(rawValue: lhs.rawValue * rhs.rawValue)
  }

  typealias Magnitude = RawValue.Magnitude
}

enum Cents {}
var cents: Tagged<Cents, Int> = 10
cents += 10
cents *= 2
cents.rawValue
/*:
 5. Create a tagged type, Light<A> = Tagged<A, Color>, where A can represent whether the light is on or off. Write turnOn and turnOff functions to toggle this state.
 */
enum On {}
enum Off {}
typealias Light<A> = Tagged<A, UIColor>

func turnOn(_ light: Light<Off>) -> Light<On> {
  return Light(rawValue: light.rawValue)
}

func turnOff(_ light: Light<On>) -> Light<Off> {
  return Light(rawValue: light.rawValue)
}

let light = Light<On>(rawValue: .black)
turnOff(light)
/*:
 6. Write a function, changeColor, that changes a Light’s color when the light is on. This function should produce a compiler error when passed a Light that is off.
 */
func changeColor(_ light: inout Light<On>) {
  light = Light<On>(
    rawValue: UIColor.init(
      red: .random(in: 0...255),
      green: .random(in: 0...255),
      blue: .random(in: 0...255),
      alpha: 1
    )
  )
}

var light6 = Light<On>(rawValue: .black)
light6.rawValue
changeColor(&light6)
light6.rawValue

var light6err = Light<Off>(rawValue: .white)
//changeColor(&light6err)

/*:
 7. Create two tagged types with Double raw values to represent Celsius and Fahrenheit temperatures. Write functions celsiusToFahrenheit and fahrenheitToCelsius that convert between these units.
 */
enum CelsiusTag {}
typealias Celsius = Tagged<CelsiusTag, Double>

enum FahrenheitTag {}
typealias Fahrenheit = Tagged<FahrenheitTag, Double>

func celsiusToFahrenheit(_ celsius: Celsius) -> Fahrenheit {
  return Fahrenheit(rawValue: celsius.rawValue * 1.8 + 32)
}

func fahrenheitToCelsius(_ fahrenheit: Fahrenheit) -> Celsius {
  return Celsius(rawValue: (fahrenheit.rawValue - 32) / 1.8)
}

let cels = Celsius(rawValue: 27)
let fahr = Fahrenheit(rawValue: 80.6)
fahrenheitToCelsius(fahr).rawValue
celsiusToFahrenheit(cels).rawValue
/*:
 8. Create Unvalidated and Validated tagged types so that you can create a function that takes an Unvalidated<User> and returns an Optional<Validated<User>> given a valid user. A valid user may be one with a non-empty name and an email that contains an @.
 */
// TODO

enum ValidatedTag {}
typealias Validated<A> = Tagged<ValidatedTag, A>

enum UnvalidatedTag {}
typealias Unvalidated<A> = Tagged<UnvalidatedTag, A>

func validate(user: Unvalidated<User>) -> Optional<Validated<User>> {
  let user = user.rawValue

  guard !user.name.isEmpty else { return nil }
  guard user.email.rawValue.contains("@") else { return nil }

  return Validated(rawValue: user)
}

let user8 = Unvalidated<User>(rawValue: User(id: 1, age: 24, name: "Bob", email: "bob@email.com"))
let user8err = Unvalidated<User>(rawValue: User(id: 1, age: 24, name: "", email: "bob@email.com"))
let user8err2 = Unvalidated<User>(rawValue: User(id: 1, age: 24, name: "Bob", email: "bob.email.com"))

validate(user: user8)
validate(user: user8err)
validate(user: user8err2)

