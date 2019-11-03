let pair = (1, "Swift")

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

// For Reference
func apply<A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    g(f(a))
  }
}
// For Reference
pair
  |> first(incr >>> String.init)
  |> second(zurry(flip(String.uppercased)))

let nested = ((1, true), "Swift")

nested
  |> first { pair in pair |> second(!) }

nested
  |> (second >>> first) { _ in "value" }

precedencegroup BackwardsComposition {
  associativity: left
}

infix operator <<<: BackwardsComposition
func <<< <A, B, C>(_ f: @escaping (B) -> C, g: @escaping (A) -> B) -> (A) -> C {
  return { a in
    print("=== f: \(type(of: f))")
    print("=== g: \(type(of: g))")
    print("=== a: \(type(of: a))")
    print("<<< >>>")
    return f(g(a))
  }
}

nested
  |> (first <<< second) { _ in "value" }


func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { array in
    array.map(f)
  }
}

dump(
[(1, ["a", "b"]), (2, ["c", "d"])]
  |> (map <<< second <<< map) { $0 + "!" }
)
