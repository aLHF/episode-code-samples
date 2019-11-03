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

import Foundation

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

/*
1. Create a parser char: Parser<Character> that will parser a single character off the front of the input string.
*/
let character = Parser<Character> { str in
  return str.popFirst()
}

character.run("439i2")

/*
2. Create a parser whitespace: Parser<Void> that consumes all of the whitespace from the front of the input string. Note that this parser is of type Void because we probably don’t care about the actual whitespace we consumed, we just want it consumed.
*/
let whitespace = Parser<Void> { str in
  while str.first?.isWhitespace == true { str.popFirst() }
  return ()
}

whitespace.run("ghel")
whitespace.run("   hello")
whitespace.run(" world")

/*
3. Right now our int parser doesn’t work for negative numbers, for example int.run("-123") will fail. Fix this deficiency in int.
*/
let allInts = Parser<Int> { str in
//  let isNegative = character.run(&str) == "-" // consumes a character even if it's not - sign
  let isNegative: Bool
  if str.first == "-" {
    str.popFirst()
    isNegative = true
  } else {
    isNegative = false
  }

  let prefix = str.prefix(while: { $0.isNumber })
  guard let int = Int(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return isNegative ? -int : int
}

allInts.run("42")
allInts.run("-42")

/*
4. Create a parser double: Parser<Double> that consumes a double from the front of the input string.
*/
let allDoubles = Parser<Double> { str in
  //  let isNegative = character.run(&str) == "-" // consumes a character even if it's not - sign
  let isNegative: Bool
  if str.first == "-" {
    str.popFirst()
    isNegative = true
  } else {
    isNegative = false
  }

  let integerDigits = str.prefix(while: { $0.isNumber })
  let hasFractionalDigits = str.dropFirst(integerDigits.count).first == "."

  if hasFractionalDigits {
    let fractionalDigits = str.dropFirst(integerDigits.count + 1).prefix(while: { $0.isNumber })

    if Double(fractionalDigits) != nil {
      guard let number = Double("\(integerDigits).\(fractionalDigits)") else { return nil } // probably should return integerDigits part
      str.removeFirst(integerDigits.count + fractionalDigits.count + 1)
      return isNegative ? -number : number
    } else {
      guard let number = Double(integerDigits) else { return nil }
      str.removeFirst(integerDigits.count)
      return isNegative ? -number : number
    }
  } else {
    guard let number = Double(integerDigits) else { return nil }
    str.removeFirst(integerDigits.count)
    return isNegative ? -number : number
  }
}

allDoubles.run(".3")

/*
5. Define a function literal: (String) -> Parser<Void> that takes a string, and returns a parser which will parse that string from the beginning of the input. This exercise shows how you can build complex parsers: you can use a function to take some up-front configuration, and then use that data in the definition of the parser.
*/
func literal(_ string: String) -> Parser<Void> {
  return Parser { str in
    guard str.hasPrefix(string) else { return () }
    str.removeFirst(string.count)
    return ()
  }
}

literal("remove me").run("remove meHello, world!")

/*
6. In this episode we mentioned that there is a correspondence between functions of the form (A) -> A and functions (inout A) -> Void. We even covered this in a previous episode, but it is instructive to write it out again. So, define two functions toInout and fromInout that will transform functions of the form (A) -> A to functions (inout A) -> Void, and vice-versa.
*/

func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
  return { a in
    let result = f(a)
    a = result
  }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
  return { a in
    var copy = a
    f(&copy)
    return copy
  }
}


