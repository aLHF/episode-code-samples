
protocol Describable {
  var describe: String { get }
}

struct Describing<A> {
  let describe: (A) -> String

  func contramap<B>(_ f: @escaping (B) -> A) -> Describing<B> {
    return Describing<B> { b in
      self.describe(f(b))
    }
  }
}

struct PostgresConnInfo {
  var database: String
  var hostname: String
  var password: String
  var port: Int
  var user: String
}


let compactWitness = Describing<PostgresConnInfo> { conn in
  return "PostgresConnInfo(database: \"\(conn.database)\", hostname: \"\(conn.hostname)\", password: \"\(conn.password)\", port: \"\(conn.port)\", user: \"\(conn.user)\")"
}

let secureCompactWitness = compactWitness.contramap { (conn: PostgresConnInfo) -> PostgresConnInfo in
  return PostgresConnInfo(database: conn.database, hostname: conn.hostname, password: "******", port: conn.port, user: conn.user)
}

let localhostPostgres = PostgresConnInfo(
  database: "pointfreeco_development",
  hostname: "localhost",
  password: "",
  port: 5432,
  user: "pointfreeco"
)

print(secureCompactWitness.describe(localhostPostgres))

compactWitness.describe(localhostPostgres)

let prettyWitness = Describing<PostgresConnInfo> {
  """
  PostgresConnInfo(
  database: \"\($0.database)\",
  hostname: \"\($0.hostname)\",
  password: \"\($0.password)\",
  port: \"\($0.port)\",
  user: \"\($0.user)\"
  )
  """
}

let securePrettyWitness = prettyWitness.contramap { (conn: PostgresConnInfo) -> PostgresConnInfo in
  return PostgresConnInfo(database: conn.database, hostname: conn.hostname, password: "******", port: conn.port, user: conn.user)
}

prettyWitness.describe(localhostPostgres)
print(securePrettyWitness.describe(localhostPostgres))

let connectionWitness = Describing<PostgresConnInfo> {
  "postgres://\($0.user):\($0.password)@\($0.hostname):\($0.port)/\($0.database)"
}

connectionWitness.describe(localhostPostgres)

//extension PostgresConnInfo: Describable {
//  var describe: String {
//    return "PostgresConnInfo(database: \"\(self.database)\", hostname: \"\(self.hostname)\", password: \"\(self.password)\", port: \"\(self.port)\", user: \"\(self.user)\")"
//  }
//}

//extension PostgresConnInfo: Describable {
//  var describe: String {
//    return """
//PostgresConnInfo(
//  database: \"\(self.database)\",
//  hostname: \"\(self.hostname)\",
//  password: \"\(self.password)\",
//  port: \"\(self.port)\",
//  user: \"\(self.user)\"
//)
//"""
//  }
//}

extension PostgresConnInfo: Describable {
  var describe: String {
    return "postgres://\(self.user):\(self.password)@\(self.hostname):\(self.port)/\(self.database)"
  }
}


print(localhostPostgres.describe)

func print<A>(tag: String, _ value: A, _ witness: Describing<A>) {
  print("[\(tag)] \(witness.describe(value))")
}

func print<A: Describable>(tag: String, _ value: A) {
  print("[\(tag)] \(value.describe)")
}

print(tag: "debug", localhostPostgres, connectionWitness)
print(tag: "debug", localhostPostgres, prettyWitness)
print(tag: "debug", localhostPostgres)


extension Int: Describable {
  var describe: String {
    return "\(self)"
  }
}

2.describe


protocol EmptyInitializable {
  init()
}

struct EmptyInitializing<A> {
  let create: () -> A
}

extension String: EmptyInitializable {
}
extension Array: EmptyInitializable {
}
extension Int: EmptyInitializable {
  init() {
    self = 1
  }
}
extension Optional: EmptyInitializable {
  init() {
    self = nil
  }
}

[1, 2, 3].reduce(0, +)

extension Array {
  func reduce<Result: EmptyInitializable>(_ accumulation: (Result, Element) -> Result) -> Result {
    return self.reduce(Result(), accumulation)
  }
}

[1, 2, 3].reduce(+)
[[1, 2], [], [3, 4]].reduce(+)
["Hello", " ", "Blob"].reduce(+)

protocol Combinable {
  func combine(with other: Self) -> Self
}

struct Combining<A> {
  let combine: (A, A) -> A
}

extension Int: Combinable {
  func combine(with other: Int) -> Int {
    return self * other
  }
}
extension String: Combinable {
  func combine(with other: String) -> String {
    return self + other
  }
}
extension Array: Combinable {
  func combine(with other: Array) -> Array {
    return self + other
  }
}
extension Optional: Combinable {
  func combine(with other: Optional) -> Optional {
    return self ?? other
  }
}

extension Array where Element: Combinable {
  func reduce(_ initial: Element) -> Element {
    return self.reduce(initial) { $0.combine(with: $1) }
  }
}

extension Array /* where Element: Combinable */ {
  func reduce(_ initial: Element, _ combining: Combining<Element>) -> Element {
    return self.reduce(initial, combining.combine)
  }
}

[1, 2, 3].reduce(1)
[[1, 2], [], [3, 4]].reduce([])
[nil, nil, 3].reduce(nil)

let sum = Combining<Int>(combine: +)
[1, 2, 3, 4].reduce(0, sum)

let product = Combining<Int>(combine: *)
[1, 2, 3, 4].reduce(1, product)


extension Array where Element: Combinable & EmptyInitializable {
  func reduce() -> Element {
    return self.reduce(Element()) { $0.combine(with: $1) }
  }
}

extension Array {
  func reduce(_ initial: EmptyInitializing<Element>, _ combining: Combining<Element>) -> Element {
    return self.reduce(initial.create(), combining.combine)
  }
}


[1, 2, 3, 4].reduce()
[[1, 2], [], [3, 4]].reduce()
[nil, nil, 3].reduce()

let zero = EmptyInitializing<Int> { 0 }
[1, 2, 3, 4].reduce(zero, sum)
let one = EmptyInitializing<Int> { 1 }
[1, 2, 3, 4].reduce(one, product)



//extension Int: Combinable {
//  func combine(with other: Int) -> Int {
//    return self * other
//  }
//}

/*:
 1. Translate the Equatable protocol into an explicit datatype struct Equating.
 */

struct Equating<A> {
  let isEqual: (A, A) -> Bool
}

let equate1 = Equating<Int>(isEqual: ==)

/*:
 2. Currently in Swift (as of 4.2) there is no way to extend tuples to conform to protocols. Tuples are what is known as “non-nominal”, which means they behave differently from the types that you can define. For example, one cannot make tuples Equatable by implementing extension (A, B): Equatable where A: Equatable, B: Equatable. To get around this Swift implements overloads of == for tuples, but they aren’t truly equatable, i.e. you cannot pass a tuple of equatable values to a function wanting an equatable value.

 However, protocol witnesses have no such problem! Demonstrate this by implementing the function pair: (Combining<A>, Combining<B>) -> Combining<(A, B)>. This function allows you to construct a combining witness for a tuple given two combining witnesses for each component of the tuple.
 */

func pair<A, B>(_ a: Combining<A>, b: Combining<B>) -> Combining<(A, B)> {
  return Combining<(A, B)> { lhs, rhs in
    let newA = a.combine(lhs.0, rhs.0)
    let newB = b.combine(lhs.1, rhs.1)
    return (newA, newB)
  }
}

/*:
 3. Functions in Swift are also “non-nominal” types, which means you cannot extend them to conform to protocols. However, again, protocol witnesses have no such problem! Demonstrate this by implementing the function pointwise: (Combining<B>) -> Combining<(A) -> B>. This allows you to construct a combining witness for a function given a combining witnesss for the type you are mapping into. There is exactly one way to implement this function.
 */

func pointwise<A, B>(_ value: Combining<B>) -> Combining<(A) -> B> {
  return Combining<(A) -> B> { lhs, rhs in
    return { a in
      value.combine(lhs(a), rhs(a))
    }
  }
}

/*:
 4. One of Swift’s most requested features was “conditional conformance”, which is what allows you to express, for example, the idea that an array of equatable values should be equatable. In Swift it is written extension Array: Equatable where Element: Equatable. It took Swift nearly 4 years after its launch to provide this capability!

 So, then it may come as a surprise to you to know that “conditional conformance” was supported for protocol witnesses since the very first day Swift launched! All you need is generics. Demonstrate this by implementing a function array: (Combining<A>) -> Combining<[A]>. This is saying that conditional conformance in Swift is nothing more than a function between protocol witnesses.
 */

func array<A>(_ value: Combining<A>) -> Combining<[A]> {
  return Combining { lhs, rhs in
    fatalError() // add all elements/just concat array/zip ???
  }
}

/*:
 5.Currently all of our witness values are just floating around in Swift, which may make some feel uncomfortable. There’s a very easy solution: implement witness values as static computed variables on the datatype! Try this by moving a few of the witnesses from the episode to be static variables. Also try moving the pair, pointwise and array functions to be static functions on the Combining datatype.
 */

extension PostgresConnInfo {
  static var prettyWitness: Describing<PostgresConnInfo> {
    return Describing<PostgresConnInfo> {
      """
      PostgresConnInfo(
      database: \"\($0.database)\",
      hostname: \"\($0.hostname)\",
      password: \"\($0.password)\",
      port: \"\($0.port)\",
      user: \"\($0.user)\"
      )
      """
    }
  }
}

extension Combining {
  func pair<B>(_ b: Combining<B>) -> Combining<(A, B)> {
    return Combining<(A, B)> { (lhs, rhs) in
      return (self.combine(lhs.0, rhs.0), b.combine(lhs.1, rhs.1))
    }
  }

//  func pointwise<B>() -> Combining<(A) -> B> {
//    return Combining<(A) -> B> { (lhs: (A) -> B, rhs: (A) -> B) in
//      return { a in
//        self.combine(lhs(a), rhs(a))
//      }
//    }
//  }
}

/*:
 6.Protocols in Swift can have “associated types”, which are types specified in the body of a protocol but aren’t determined until a type conforms to the protocol. How does this translate to an explicit datatype to represent the protocol?
 */

// Another Generic

/*:
 7. Translate the RawRepresentable protocol into an explicit datatype struct RawRepresenting. You will need to use the previous exercise to do this.
 */

struct RawRepresenting<A, RawValue> {
  let representing: (A) -> RawValue?
}

enum Test6: String {
  case first
}

RawRepresenting<String, Test6> { Test6(rawValue: $0) }

/*
 8. Protocols can inherit from other protocols, for example the Comparable protocol inherits from the Equatable protocol. How does this translate to an explicit datatype to represent the protocol?
 */

// Below

/*:
 9. Translate the Comparable protocol into an explicit datatype struct Comparing. You will need to use the previous exercise to do this.
 */

struct Comparing<A> {
  let equate: Equating<A>

  let less: (A, A) -> Bool
}

/*:
 10. We can combine the best of both worlds by using witnesses and having our default protocol, too. Define a DefaultDescribable protocol which provides a static member that returns a default witness of Describing<Self>. Using this protocol, define an overload of print(tag:) that doesn’t require a witness.
 */

protocol DefaultDescribable {
  static var describe: Describing<Self> { get }
}

func print<A: DefaultDescribable>(tag: String, _ value: A) {
  print("[\(tag)] \(A.describe.describe(value))") // naming xD
}
