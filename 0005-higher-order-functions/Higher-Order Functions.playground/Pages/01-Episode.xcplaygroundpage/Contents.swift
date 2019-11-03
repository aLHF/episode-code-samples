
func greet(at date: Date, name: String) -> String {
  let seconds = Int(date.timeIntervalSince1970) % 60
  return "Hello \(name)! It's \(seconds) seconds past the minute."
}

func greet(at date: Date) -> (String) -> String {
  return { name in
    let seconds = Int(date.timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(seconds) seconds past the minute."
  }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a,b) } }
}

greet(at:name:)
curry(greet(at:name:))

curry(String.init(data:encoding:))

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}


func flip<A, B>(_ f: @escaping (A) -> () -> B) -> () -> (A) -> B {
  return { { a in f(a)() } }
}

flip(curry(String.init(data:encoding:)))

String.uppercased(with:)

// (Self) -> (Argumennts) -> ReturnType

String.uppercased(with:)("qwerty")(Locale.current)

flip(String.uppercased(with:))

let uppercasedWithEn = flip(String.uppercased(with:))(Locale.init(identifier: "en"))

"qwerty" |> uppercasedWithEn

String.uppercased
flip(String.uppercased)
flip(String.uppercased)()

"qwerty" |> flip(String.uppercased)()

func zurry<A>(_ f: () -> A) -> A {
  return f()
}

zurry(flip(String.uppercased))
"qwerty" |> zurry(flip(String.uppercased))

[1, 2, 3]
  .map(incr)
  .map(square)

func map<A, B>(_ f: @escaping (A) -> B) -> ([A] ) -> [B] {
  return { arr in arr.map(f) }
}

map(incr)
map(square)
[1, 2, 3] |> map(incr >>> square >>> String.init)

func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { $0.filter(p) }
}

Array(1...10)
  |> filter { $0 <= 5 }
  >>> map(incr >>> incr >>> square >>> square >>> String.init)
//: [See the next page](@next) for exercises!
