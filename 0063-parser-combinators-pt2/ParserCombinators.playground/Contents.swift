
struct Parser<A> {
  let run: (inout Substring) -> A?
}

















let int = Parser<Int> { str in
  let prefix = str.prefix(while: { $0.isNumber })
  let match = Int(prefix)
  str.removeFirst(prefix.count)
  return match
}

let double = Parser<Double> { str in
  let prefix = str.prefix(while: { $0.isNumber || $0 == "." })
  let match = Double(prefix)
  str.removeFirst(prefix.count)
  return match
}

let char = Parser<Character> { str in
  guard !str.isEmpty else { return nil }
  return str.removeFirst()
}

func literal(_ p: String) -> Parser<Void> {
  return Parser<Void> { str in
    guard str.hasPrefix(p) else { return nil }
    str.removeFirst(p.count)
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





















extension Parser {
  func map<B>(_ f: @escaping (A) -> B) -> Parser<B> {
    return Parser<B> { str -> B? in
      self.run(&str).map(f)
    }
  }

  func flatMap<B>(_ f: @escaping (A) -> Parser<B>) -> Parser<B> {
    return Parser<B> { str -> B? in
      let original = str
      let matchA = self.run(&str)
      let parserB = matchA.map(f)
      guard let matchB = parserB?.run(&str) else {
        str = original
        return nil
      }
      return matchB
    }
  }
}

func zip<A, B>(_ a: Parser<A>, _ b: Parser<B>) -> Parser<(A, B)> {
  return Parser<(A, B)> { str -> (A, B)? in
    let original = str
    guard let matchA = a.run(&str) else { return nil }
    guard let matchB = b.run(&str) else {
      str = original
      return nil
    }
    return (matchA, matchB)
  }
}





func zip<A, B, C>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>
  ) -> Parser<(A, B, C)> {
  return zip(a, zip(b, c))
    .map { a, bc in (a, bc.0, bc.1) }
}
func zip<A, B, C, D>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>
  ) -> Parser<(A, B, C, D)> {
  return zip(a, zip(b, c, d))
    .map { a, bcd in (a, bcd.0, bcd.1, bcd.2) }
}
func zip<A, B, C, D, E>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>,
  _ e: Parser<E>
  ) -> Parser<(A, B, C, D, E)> {

  return zip(a, zip(b, c, d, e))
    .map { a, bcde in (a, bcde.0, bcde.1, bcde.2, bcde.3) }
}
func zip<A, B, C, D, E, F>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>,
  _ e: Parser<E>,
  _ f: Parser<F>
  ) -> Parser<(A, B, C, D, E, F)> {
  return zip(a, zip(b, c, d, e, f))
    .map { a, bcdef in (a, bcdef.0, bcdef.1, bcdef.2, bcdef.3, bcdef.4) }
}
func zip<A, B, C, D, E, F, G>(
  _ a: Parser<A>,
  _ b: Parser<B>,
  _ c: Parser<C>,
  _ d: Parser<D>,
  _ e: Parser<E>,
  _ f: Parser<F>,
  _ g: Parser<G>
  ) -> Parser<(A, B, C, D, E, F, G)> {
  return zip(a, zip(b, c, d, e, f, g))
    .map { a, bcdefg in (a, bcdefg.0, bcdefg.1, bcdefg.2, bcdefg.3, bcdefg.4, bcdefg.5) }
}





















extension Parser {
  func run(_ str: String) -> (match: A?, rest: Substring) {
    var str = str[...]
    let match = self.run(&str)
    return (match, str)
  }
}





















// 40.446° N, 79.982° W
struct Coordinate {
  let latitude: Double
  let longitude: Double
}

func prefix(while p: @escaping (Character) -> Bool) -> Parser<Substring> {
  return Parser<Substring> { str in
    let prefix = str.prefix(while: p)
    str.removeFirst(prefix.count)
    return prefix
  }
}

let zeroOrMoreSpaces = prefix(
  while: { $0 == " " })
  .map { _ in () }
//  Parser<Void> { str -> Void? in
//  let prefix = str.prefix(while: { $0 == " " })
//  str.removeFirst(prefix.count)
//  return ()
//}
let oneOrMoreSpaces = prefix(
  while: { $0 == " " })
  .flatMap {
    $0.isEmpty
      ? .never
      : always(())
}
//  Parser<Void> { str -> Void? in
//  let prefix = str.prefix(while: { $0 == " " })
//  guard !prefix.isEmpty else { return nil }
//  str.removeFirst(prefix.count)
//  return ()
//}



let northSouth = char
  .flatMap {
    $0 == "N" ? always(1.0)
      : $0 == "S" ? always(-1)
      : .never
}
let eastWest = char
  .flatMap {
    $0 == "E" ? always(1.0)
      : $0 == "W" ? always(-1)
      : .never
}
let latitude = zip(
  double,
  literal("°"),
  oneOrMoreSpaces,
  northSouth
  )
  .map { lat, _, _, latSign in lat * latSign }
let longitude = zip(
  double,
  literal("°"),
  oneOrMoreSpaces,
  eastWest
  )
  .map { long, _, _, longSign in long * longSign }
let coord = zip(
  zeroOrMoreSpaces,
  latitude,
  literal(","),
  oneOrMoreSpaces,
  longitude
  )
  .map { _, lat, _, _, long in
    Coordinate(
      latitude: lat,
      longitude: long
    )
}



coord.run("40.446° N, 79.982° W")


coord.run("40.446°   N,   79.982°   W")
coord.run("40.446°   N,   79.982°   W   ")
coord.run("   40.446°   N,   79.982°   W   ")


import Foundation

let df = DateFormatter()
df.dateStyle = .medium

df.date(from: "Jan 29, 2018")
df.date(from: "Jan   29,   2018")
df.date(from: "   Jan   29,   2018")



try NSRegularExpression(pattern: " *")



Scanner().charactersToBeSkipped = .whitespaces



oneOrMoreSpaces.run("   Hello, world!")
oneOrMoreSpaces.run("Hello, world!")



"€42,£42,$42"


enum Currency { case eur, gbp, usd }
let currency = char.flatMap {
  $0 == "€" ? always(Currency.eur)
    : $0 == "£" ? always(.gbp)
    : $0 == "$" ? always(.usd)
    : .never
}


struct Money {
  let currency: Currency
  let value: Double
}
let money = zip(currency, double).map(Money.init)


money.run("€42,£42,$42")


zip(money, literal(","), money, literal(","), money)
  .run("€42,£42")


func zeroOrMore<A>(
  _ p: Parser<A>,
  separatedBy s: Parser<Void>
  ) -> Parser<[A]> {
  return Parser<[A]> { str in
    var rest = str
    var matches: [A] = []
    while let match = p.run(&str) {
      rest = str
      matches.append(match)
      if s.run(&str) == nil {
        return matches
      }
    }
    str = rest
    return matches
  }
}


zeroOrMore(money, separatedBy: literal(","))
  .run("€42,£42,$42,")
  .match
zeroOrMore(money, separatedBy: literal(","))
  .run("€42,£42,$42,")
  .rest


zeroOrMore(money, separatedBy: literal(""))
  .run("€42£42$42")
  .match

let commaOrNewline = char
  .flatMap { $0 == "," || $0 == "\n" ? always(()) : .never }

dump(
zeroOrMore(money, separatedBy: commaOrNewline)
  .run("""
€42,£42,$42
€42,£42,$42
€42,£42,$42,฿10
""")
  .match)

zeroOrMore(money, separatedBy: commaOrNewline)
  .run("""
€42,£42,$42
€42,£42,$42
€42,£42,$42,฿10
""")
  .rest

dump(
  zeroOrMore(money, separatedBy: commaOrNewline)
    .run("""
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
€42,£42,$42,€42,£42,$42,€42,£42,$42,€42,£42,$42
""")
    .match)

/*
 1. We quickly added a separatedBy argument to zeroOrMore, but it can be very useful to parse out an array of values without a separator. Give separatedBy a default parser for this behavior. Is this a parser we’ve already encountered?
*/

func zeroOrMore1<A>(
  _ p: Parser<A>,
  separatedBy s: Parser<Void> = always(())
  ) -> Parser<[A]> {
  return Parser<[A]> { str in
    var rest = str
    var matches: [A] = []
    while let match = p.run(&str) {
      rest = str
      matches.append(match)
      if s.run(&str) == nil {
        return matches
      }
    }
    str = rest
    return matches
  }
}

zeroOrMore1(money)
  .run("€42£42$42")
  .match


/*
2. Add an until parser argument to zeroOrMore (and oneOrMore) that parses a number of values until the given parser succeeds.
*/

func zeroOrMore2<A>(
  _ p: Parser<A>,
  separatedBy s: Parser<Void> = always(()),
  until u: Parser<Void>
  ) -> Parser<[A]> {
  return Parser<[A]> { str in
    var rest = str
    var matches: [A] = []
    while let match = p.run(&str) {
      if u.run(&str) != nil {
        str = rest
        return matches
      }

      rest = str
      matches.append(match)
      if s.run(&str) == nil {
        return matches
      }
    }
    str = rest
    return matches
  }
}

/*
3. Make this until parser argument optional by providing a default parser value. Is this a parser we’ve already encountered?
*/

// never

/*
4. Define a parser combinator, oneOf, that takes an array of Parser<A>s as input and produces a single parser of Parser<A>. What can/should this parser do?
*/

func oneOf<A>(_ arr: [Parser<A>]) -> Parser<A> {
  return Parser<A> { str in
    for parser in arr {
      if let value = parser.run(&str) {
        return value
      }
    }

    return nil
  }
}
