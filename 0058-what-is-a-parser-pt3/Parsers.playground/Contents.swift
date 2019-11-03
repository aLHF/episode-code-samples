
Int("42")
Int("42-")
Double("42")
Double("42.32435")
Bool("true")
Bool("false")
Bool("f")

import Foundation

UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEF")
UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEE")
UUID.init(uuidString: "DEADBEEF-DEAD-BEEF-DEAD-BEEFDEADBEEZ")

URL.init(string: "https://www.pointfree.co")
URL.init(string: "^https://www.pointfree.co")

let components = URLComponents.init(string: "https://www.pointfree.co?ref=twitter")
components?.queryItems

let df = DateFormatter()
df.timeStyle = .none
df.dateStyle = .short
type(of: df.date(from: "1/29/17"))
df.date(from: "-1/29/17")


let emailRegexp = try NSRegularExpression(pattern: #"\S+@\S+"#)
let emailString = "You're logged in as blob@pointfree.co"
let emailRange = emailString.startIndex..<emailString.endIndex
let match = emailRegexp.firstMatch(
  in: emailString,
  range: NSRange(emailRange, in: emailString)
  )!
emailString[Range(match.range(at: 0), in: emailString)!]

//let scanner = Scanner.init(string: "A42 Hello World")
//var int = 0
//scanner.scanInt(&int)
//int

// 40.6782° N, 73.9442° W
struct Coordinate {
  let latitude: Double
  let longitude: Double
}

//typealias Parser<A> = (String) -> A

struct Parser<A> {
  //  let run: (String) -> A?
  //  let run: (String) -> (match: A?, rest: String)
  //  let run: (inout String) -> A?
  let run: (inout Substring) -> A?

  func run(_ str: String) -> (match: A?, rest: Substring) {
    var str = str[...]
    let match = self.run(&str)
    return (match, str)
  }
}

let int = Parser<Int> { str in
  let prefix = str.prefix(while: { $0.isNumber })
  guard let int = Int(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return int
}

//Substring


int.run("42")
int.run("42 Hello World")
int.run("Hello World")

let double = Parser<Double> { str in
  let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
  guard let match = Double(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return match
}

double.run("42")
double.run("42.87432893247")
double.run("42.87432 Hello World")
double.run("42.4.1.4.6")

func literal(_ literal: String) -> Parser<Void> {
  return Parser<Void> { str in
    guard str.hasPrefix(literal) else { return nil }
    str.removeFirst(literal.count)
    return ()
  }
}

literal("cat").run("cat dog")
literal("cat").run("dog cat")

func always<A>(_ a: A) -> Parser<A> {
  return Parser<A> { _ in a }
}

always("cat").run("dog")

// let never<A> = Parser { ... }
func never<A>() -> Parser<A> {
  return Parser<A> { _ in nil }
}
extension Parser {
  static var never: Parser {
    return Parser { _ in nil }
  }
}
(never() as Parser<Int>).run("dog")
Parser<Int>.never.run("dog")


// (A)       -> A
// (inout A) -> Void



enum Route {
  case home
  case profile
  case episodes
  case episode(id: Int)
}

let router = Parser<Route> { str in
  fatalError()
}

//router.run("/") // .home
//router.run("/episodes/42") // .episode(42)

//switch router.run("/episodes/42") {
//case .none:
//case .some(.home):
//case .some(.profile):
//case .some(.episodes):
//case let .some(.episode(id)):
//}

enum EnumPropertyGenerator {
  case help
  case version
  case invoke(urls: [URL], dryRun: Bool)
}

let cli = Parser<EnumPropertyGenerator> { str in
  fatalError()
}

//cli.run("generate-enum-properties --version") // .version
//cli.run("generate-enum-properties --help") // .help
//cli.run("generate-enum-properties --dry-run /path/to/file.swift") // .invoke(["/path/to/file.swift"], dryRun: true)
//
//switch cli.run("generate-enum-properties --dry-run /path/to/file.swift") {
//case .help:
//case .version:
//case .invoke:
//case nil:
//}

let northSouth = Parser<Double> { str in
  guard
    let cardinal = str.first,
    cardinal == "N" || cardinal == "S"
    else { return nil }
  str.removeFirst(1)
  return cardinal == "N" ? 1 : -1
}
let eastWest = Parser<Double> { str in
  guard
    let cardinal = str.first,
    cardinal == "E" || cardinal == "W"
    else { return nil }
  str.removeFirst(1)
  return cardinal == "E" ? 1 : -1
}

func parseLatLong(_ str: String) -> Coordinate? {
  var str = str[...]

  guard
    let lat = double.run(&str),
    literal("° ").run(&str) != nil,
    let latSign = northSouth.run(&str),
    literal(", ").run(&str) != nil,
    let long = double.run(&str),
    literal("° ").run(&str) != nil,
    let longSign = eastWest.run(&str)
    else { return nil }

  return Coordinate(
    latitude: lat * latSign,
    longitude: long * longSign
  )


  //  let parts = str.split(separator: " ")
  //  guard parts.count == 4 else { return nil }
  //  guard
  //    let lat = Double(parts[0].dropLast()),
  //    let long = Double(parts[2].dropLast())
  //    else { return nil }
  //  let latCard = parts[1].dropLast()
  //  guard latCard == "N" || latCard == "S" else { return nil }
  //  let longCard = parts[3]
  //  guard longCard == "E" || longCard == "W" else { return nil }
  //  let latSign = latCard == "N" ? 1.0 : -1
  //  let longSign = longCard == "E" ? 1.0 : -1
  //  return Coordinate(latitude: lat * latSign, longitude: long * longSign)
}

print(parseLatLong("40.6782° N, 73.9442° W"))




func parseLatLongWithScanner(_ string: String) -> Coordinate? {
  let scanner = Scanner(string: string)

  var lat: Double = 0
  guard scanner.scanDouble(&lat) else { return nil }

  guard scanner.scanString("° ", into: nil) else { return nil }

  var northSouth: NSString? = ""
  guard scanner.scanCharacters(from: ["N", "S"], into: &northSouth) else { return nil }
  let latSign = northSouth == "N" ? 1.0 : -1

  guard scanner.scanString(", ", into: nil) else { return nil }

  var long: Double = 0
  guard scanner.scanDouble(&long) else { return nil }

  guard scanner.scanString("° ", into: nil) else { return nil }

  var eastWest: NSString? = ""
  guard scanner.scanCharacters(from: ["E", "W"], into: &eastWest) else { return nil }
  let longSign = eastWest == "E" ? 1.0 : -1

  return Coordinate(latitude: lat * latSign, longitude: long * longSign)
}

/*
 1. Right now all of our parsers (int, double, literal, etc.) are defined at the top-level of the file, hence they are defined in the module namespace. While that is completely fine to do in Swift, it can sometimes improve the ergonomics of using these values by storing them as static properties on the Parser type itself. We have done this a bunch in previous episodes, such as with our Gen type and Snapshotting type.

 Move all of the parsers we have defined so far to be static properties on the Parser type. You will want to suitably constrain the A generic in the extension in order to further restrict how these parsers are stored, i.e. you shouldn’t be allowed to access the integer parser via Parser<String>.int.
 */

extension Parser where A == Int {
  static let int = Parser { str in
    let prefix = str.prefix(while: { $0.isNumber })
    guard let int = Int(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return int
  }
}

extension Parser where A == Double {
  static let double = Parser<Double> { str in
    let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
    guard let match = Double(prefix) else { return nil }
    str.removeFirst(prefix.count)
    return match
  }
}

Parser<Int>.int.run("42")
Parser<Int>.int.run("42 Hello World")
Parser<Int>.int.run("Hello World")

Parser<Double>.double.run("42")
Parser<Double>.double.run("42.87432893247")
Parser<Double>.double.run("42.87432 Hello World")
Parser<Double>.double.run("42.4.1.4.6")

/*
 2. Define map, zip and flatMap on the Parser type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume any of the input string if the parser fails.
 */

extension Parser {
  func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
    return Parser<B> { str in self.run(&str).map(f) }
  }

  func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
    return Parser<B> { str in
      guard let parserB = self.run(&str).map(f) else { return nil } // What if it fails. Maybe we shouldn't consume the string
      return parserB.run(&str)
    }
  }

  func zip<B>(_ pa: Parser<A>, pb: Parser<B>) -> Parser<(A, B)> {
    return Parser<(A, B)> { str in
      guard
        let a = pa.run(&str), // Should we consume? Should we keep the order?
        let b = pb.run(&str)
        else { return nil }

      return (a, b)
    }
  }
}

/*
 3. Create a parser end: Parser<Void> that simply succeeds if the input string is empty, and fails otherwise. This parser is useful to indicate that you do not intend to parse anymore.
 */

extension Parser where A == Void {
  static let end = Parser { str in
    if str.isEmpty {
      return ()
    } else {
      return nil
    }
  }
}

Parser<Void>.end.run("")
Parser<Void>.end.run("32")

/*
4. Implement a function that takes a predicate (Character) -> Bool as an argument, and returns a parser Parser<Substring> that consumes from the front of the input string until the predicate is no longer satisfied. It would have the signature func pred: ((A) -> Bool) -> Parser<Substring>.
*/

func something(_ predicate: @escaping (Character) -> Bool) -> Parser<Substring> {
  return Parser<Substring> { str in
    let prefix = str.prefix(while: predicate)
    guard prefix.count > 0 else { return nil }
    str.removeFirst(prefix.count)
    return prefix
  }
}

let smth = something { c in  if c == "a" || c == "b" { return true } else { return false } }
smth.run("324")

/*
 5. Implement a function that transforms any parser into one that does not consume its input at all. It would have the signature func nonConsuming: (Parser<A>) -> Parser<A>.
 */

func nonConsuming<A>(_ parser: Parser<A>) -> Parser<A> {
  return Parser<A> { _ in return nil }
}

/*
 6. Implement a function that transforms a parser into one that runs the parser many times and accumulates the values into an array. It would have the signature func many: (Parser<A>) -> Parser<[A]>
 */

func many<A>(_ parser: Parser<A>) -> Parser<[A]> {
  return Parser<[A]> { str in
    var result: [A] = []

    while let value = parser.run(&str) {
      result.append(value)
    }

    return result // When should we return nil?
  }
}

/*
 7. Implement a function that takes an array of parsers, and returns a new parser that takes the result of the first parser that succeeds. It would have the signature func choice: (Parser<A>...) -> Parser<A>.
 */

func choice<A>(_ parsers: Parser<A>...) -> Parser<A> {
  return Parser<A> { str in
    for parser in parsers {
      if let value = parser.run(&str) {
        return value
      }
    }

    return nil
  }
}

/*
 8. Implement a function that takes two parsers, and returns a new parser that returns the result of the first if it succeeds, otherwise it returns the result of the second. It would have the signature func either: (Parser<A>, Parser<B>) -> Parser<Either<A, B>> where Either is defined:

 enum Either<A, B> {
 case left(A)
 case right(B)
 }
 */

enum Either<A, B> {
  case left(A)
  case right(B)
}

func either<A, B>(_ pa: Parser<A>, pb: Parser<B>) -> Parser<Either<A, B>> {
  return Parser<Either<A, B>> { str in
    if let value = pa.run(&str) {
      return .left(value)
    } else  if let value = pb.run(&str) {
      return .right(value)
    } else {
      return nil
    }
  }
}

/*
9. Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the first and discards the second. It would have the signature func keep(_: Parser<A>, discard: Parser<B>) -> Parser<A>. Make sure to not consume any of the input string if either of the parsers fail.
 */

func keep<A, B>(_ pa: Parser<A>, discard pb: Parser<B>) -> Parser<A> {
  return Parser<A> { str in
    guard let a = pa.run(&str) else { return nil }
    pb.run(&str)
    return a
  }
}

/*
 10. Implement a function that takes two parsers and returns a new parser that runs both of the parsers on the input string, but only returns the successful result of the second and discards the first. It would have the signature func discard(_: Parser<A>, keep: Parser<B>) -> Parser<B>. Make sure to not consume any of the input string if either of the parsers fail.
 */

func discard<A, B>(_ pa: Parser<A>, keep pb: Parser<B>) -> Parser<B> {
  return Parser<B> { str in
    guard let b = pb.run(&str) else { return nil }
    pa.run(&str)
    return b
  }
}

/*
 11. Implement a function that takes two parsers and returns a new parser that returns of the first if it succeeds, otherwise it returns the result of the second. It would have the signature func choose: (Parser<A>, Parser<A>) -> Parser<A>. Consume as little of the input string when implementing this function.
 */

func choose<A>(_ pa: Parser<A>, _ pb: Parser<A>) -> Parser<A> {
  return Parser<A> { str in
    if let value = pa.run(&str) {
      return value
    } else if let value = pb.run(&str) {
      return value
    } else {
      return nil
    }
  }
}

/*
 12. Generalize the previous exercise by implementing a function of the form func choose: ([Parser<A>]) -> Parser<A>.
 */

func choose<A>(_ parsers: [Parser<A>]) -> Parser<A> {
  return Parser<A> { str in
    for parser in parsers {
      if let value = parser.run(&str) {
        return value
      }
    }

    return nil
  }
}

/*
 13. Right now our parser can only fail in a single way, by returning nil. However, it can often be useful to have parsers that return a description of what went wrong when parsing.

 Generalize the Parser type so that instead of returning an A? value it returns a Result<A, String> value, which will allow parsers to describe their failures. Update all of our parsers and the ones in the above exercises to work with this new type.
 */

enum Result<Value, Error> {
  case success(Value)
  case failure(Error)
}

struct ResultParser<A, String> {
  let run: (inout Substring) -> Result<A, String>
}

/*
 14. Right now our parser only works on strings, but there are many other inputs we may want to parse. For example, if we are making a router we would want to parse URLRequest values.

 Generalize the Parser type so that it is generic not only over the type of value it produces, but also the type of values it parses. Update all of our parsers and the ones in the above exercises to work with this new type (you may need to constrain generics to work on specific types instead of all possible input types).
 */

struct GeneralizedParser<Input, Output, String> {
  let run: (inout Input) -> Result<Output, String>
}
