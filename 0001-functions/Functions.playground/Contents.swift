func toString(_ int: Int) -> String {
  return "\(int)"
}

func incr(_ x: Int) -> Int {
  return x + 1
}

incr(5)
toString(5)

extension Int {
  func incr() -> Int {
    return self + 1
  }

  func toString() -> String {
    return "\(self)"
  }
}

5.incr().incr()
5.incr().toString()

precedencegroup ForwardApplication {
  associativity: left
}

infix operator |>: ForwardApplication

func |> <A, B>(a: A, f: (A) -> B) -> B {
  return f(a)
}

2 |> incr |> toString

precedencegroup ForwardComposition {
  higherThan: ForwardApplication
  associativity: right
}

infix operator >>>: ForwardComposition

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { a in
    return g(f(a))
  }
}

2 |> incr >>> incr >>> toString

[1, 2, 3, 4, 5] // Traverse array 3 times
  .map(incr)
  .map(incr)
  .map(toString)

[1, 2, 3, 4, 5] // Traverse once
  .map(incr >>> incr >>> String.init)
