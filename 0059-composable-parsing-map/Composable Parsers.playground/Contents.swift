import Foundation

struct Parser<A> {
  let run: (inout Substring) -> A?
}

let int = Parser<Int> { str in
  let prefix = str.prefix(while: { $0.isNumber })
  guard let int = Int(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return int
}

let double = Parser<Double> { str in
  let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
  guard let match = Double(prefix) else { return nil }
  str.removeFirst(prefix.count)
  return match
}

func literal(_ literal: String) -> Parser<Void> {
  return Parser<Void> { str in
    guard str.hasPrefix(literal) else { return nil }
    str.removeFirst(literal.count)
    return ()
  }
}

func always<A>(_ a: A) -> Parser<A> {
  return Parser<A> { _ in a }
}

extension Parser {
  static var never: Parser {
    return Parser { _ in nil }
  }
}

struct Coordinate {
  let latitude: Double
  let longitude: Double
}


extension Parser {
  func run(_ str: String) -> (match: A?, rest: Substring) {
    var str = str[...]
    let match = self.run(&str)
    return (match, str)
  }
}


// map: ((A) -> B) -> (F<A>) -> F<B>

// F<A> = Parser<A>
// map: ((A) -> B) -> (Parser<A>) -> Parser<B>

// map(id) = id

[1, 2, 3]
  .map { $0 }

Optional("Blob")
  .map { $0 }


// map: (Parser<A>, (A) -> B) -> Parser<B>

extension Parser {
  func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
    return Parser<B> { str -> B? in
      self.run(&str).map(f)
    }
  }

  func fakeMap<B>(_ f: @escaping (A) -> B) -> Parser<B> {
    return Parser<B> { _ in nil }
  }
  func fakeMap2<B>(_ f: @escaping (A) -> B) -> Parser<B> {
    return Parser<B> { str in
      let matchB = self.run(&str).map(f)
      str = ""
      return matchB
    }
  }
}

int.map { $0 }
int.fakeMap { $0 }.run("123")
int
  .fakeMap2 { $0 }.run("123 Hello World")
int
  .run("123 Hello World")

let even = int.map { $0 % 2 == 0 }

even.run("123 Hello World")
even.run("42 Hello World")

let char = Parser<Character> { str in
  guard !str.isEmpty else { return nil }
  return str.removeFirst()
}

//let northSouth = Parser<Double> { str in
//  guard
//    let cardinal = str.first,
//    cardinal == "N" || cardinal == "S"
//    else { return nil }
//  str.removeFirst(1)
//  return cardinal == "N" ? 1 : -1
//}
let northSouth = char
  .map {
    $0 == "N" ? always(1.0)
      : $0 == "S" ? always(-1)
      : .never
}

let eastWest = Parser<Double> { str in
  guard
    let cardinal = str.first,
    cardinal == "E" || cardinal == "W"
    else { return nil }
  str.removeFirst(1)
  return cardinal == "E" ? 1 : -1
}

//func parseLatLong(_ str: String) -> Coordinate? {
//  var str = str[...]
//
//  guard
//    let lat = double.run(&str),
//    literal("° ").run(&str) != nil,
//    let latSign = northSouth.run(&str),
//    literal(", ").run(&str) != nil,
//    let long = double.run(&str),
//    literal("° ").run(&str) != nil,
//    let longSign = eastWest.run(&str)
//    else { return nil }
//
//  return Coordinate(
//    latitude: lat * latSign,
//    longitude: long * longSign
//  )
//}

//print(String(describing: parseLatLong("40.6782° N, 73.9442° W")))

/*
 1. Generalize the char parser created in this episode by turning it into a function func char: (CharacterSet) -> Parser<Character>. Use this parser to implement the northSouth and eastWest parsers without needing to use flatMap.
 */

func char(_ set: CharacterSet) -> Parser<Character> {
  return Parser<Character> { str in
    let first = str.first
    guard let char = first, set.isSuperset(of: CharacterSet(char.unicodeScalars)) else { return nil }
    return str.popFirst()
  }
}

char(["a"]).run("fasdj")

let northSouth1 = char(["N", "S"])
  .map { $0 == "N" ? 1 : -1 }
  .run("N")

let eastWest1 = char(["E", "W"])
  .map { $0 == "E" ? 1 : -1 }
  .run("W")

/*
 2. Define zip and flatMap on the Parser type. Start by defining what their signatures should be, and then figure out how to implement them in the simplest way possible. What gotcha to be on the look out for is that you do not want to consume any of the input string if the parser fails.
 */

extension Parser {
  func flatMap<B>(_ t: @escaping (A) -> Parser<B>) -> Parser<B> {
    return Parser<B> { str in
      let original = str
      let a = self.run(&str)

      guard
        let valueA = a, let valueB = t(valueA).run(&str)
        else
      {
        str = original
        return nil
      }

      return valueB
    }
  }

  func zip<B>(_ pa: Parser<A>, _ pb: Parser<B>) -> Parser<(A, B)> {
    return Parser<(A, B)> { str in
      let original = str

      guard
        let valueA = pa.run(&str),
        let valueB = pb.run(&str)
        else
      {
        str = original
        return nil
      }

      return (valueA, valueB)
    }
  }
}

/*
 3. Use the flatMap defined in the previous exercise to implement the northSouth and eastWest parsers. You will need to use the always and never parsers in their implementations.
 */

let northSouth3 = char(["N", "S"])
  .flatMap { $0 == "N" ? always(1) : always(-1) }

northSouth3.run("N")
northSouth3.run("S")
northSouth3.run("Z")

let eastWest3 = char(["E", "W"])
  .flatMap { $0 == "E" ? always(1) : always(-1) }

eastWest3.run("E")
eastWest3.run("W")
eastWest3.run("Q")

/*
 4. Using only map and flatMap, construct a parser for parsing a Coordinate value from the string "40.446° N, 79.982° W".
 */

dump(
  double
    .flatMap { lat in
      literal("° ")
        .flatMap { _ in
          northSouth3
            .flatMap { latSign in
              literal(", ")
                .flatMap { _ in
                  double
                    .flatMap { long in
                      literal("° ")
                        .flatMap { _ in
                          eastWest
                            .map { longSign in
                              return Coordinate(latitude: lat * Double(latSign), longitude: long * Double(longSign))
                          }
                      }
                  }
              }
          }
      }
    }
    .run("40.446° N, 79.982° W")
)
