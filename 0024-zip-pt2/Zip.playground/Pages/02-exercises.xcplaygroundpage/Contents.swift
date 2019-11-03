/*:
 # The Many Faces of Zip: Part 2

 ## Exercises

 1.) Can you make the `zip2` function on our `F3` type thread safe?
 */
import Dispatch

struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}

func zip2<A, B>(_ fa: F3<A>, _ fb: F3<B>) -> F3<(A, B)> {
  return F3 { callback in
    var a: A?
    var b: B?
    let dispatchGroup = DispatchGroup()

    dispatchGroup.enter()
    fa.run {
      a = $0
      dispatchGroup.leave()
    }

    dispatchGroup.enter()
    fb.run {
      b = $0
      dispatchGroup.leave()
    }

    dispatchGroup.notify(queue: .main) { callback((a!, b!)) }
  }
}

/*:
 2.) Generalize the `F3` type to a type that allows returning values other than `Void`: `struct F4<A, R> { let run: (@escaping (A) -> R) -> R }`. Define `zip2` and `zip2(with:)` on the `A` type parameter.
 */
struct F4<A, R> {
  let run: (@escaping (A) -> R) -> R
}

func zip2<A, B, R>(_ fa: F4<A, R>, _ fb: F4<B, R>) -> F4<(A, B), R> {
  return F4<(A, B), R> { callback in
    fa.run { a in
      fb.run { b in
        callback((a, b))
      }
    }
  }
}

func zip2<A, B, C, R>(
  with f: @escaping (A, B) -> C
  ) -> (F4<A, R>, F4<B, R>) -> F4<C, R> {

  return { fa, fb in
    F4<C, R> { callback in zip2(fa, fb).run { ab in callback(f(ab.0, ab.1)) } }
  }
}

/*:
 3.) Find a function in the Swift standard library that resembles the function above. How could you use `zip2` on it?
 */
func zip2<A, B, R>(
  _ fa: @escaping ((A) throws -> R) throws -> R,
  _ fb: @escaping ((B) throws -> R) throws -> R
  ) -> (@escaping (A, B) throws -> R) throws -> R {

  return { callback in
    try fa { a in
      try fb { b in
        try callback(a, b)
      }
    }
  }
}

let first = [1]
let second = [2]
try (zip2(first.withUnsafeBytes, second.withUnsafeBytes)) { x, y -> Int in
  return 0
}
/*:
 4.) This exercise explore what happens when you nest two types that each support a `zip` operation.

 - Consider the type `[A]? = Optional<Array<A>>`. The outer layer `Optional`  has `zip2` defined, but also the inner layer `Array`  has a `zip2`. Can we define a `zip2` on `[A]?` that makes use of both of these zip structures? Write the signature of such a function and implement it.
 */
func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
  guard let a = a, let b = b else { return nil }
  return (a, b)
}

func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  (0..<min(xs.count, ys.count)).forEach { idx in
    result.append((xs[idx], ys[idx]))
  }
  return result
}

func zipOpt<A, B>(_ a: [A]?, _ b: [B]?) -> [(A, B)]? {
  return zip2(a, b).map(zip2)
}
/*:
 - Using the `zip2` defined above write an example usage of it involving two `[A]?` values.
 */
let a1: [Int]? = [1 , 2]
let a2: [Int]? = [1 , 2]
zipOpt(a1, a2)
/*:
 - Consider the type `[Validated<A, E>]`. We again have have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both `zip` structures? Write the signature of such a function and implement it.
 */
enum Validated<A, E> {
  case valid(A)
  case invalid([E])
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Validated<A, E>) -> Validated<B, E> {
  return { validated in
    switch validated {
    case let .valid(a):
      return .valid(f(a))
    case let .invalid(e):
      return .invalid(e)
    }
  }
}

func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
  switch (a, b) {
  case let (.valid(a), .valid(b)):
    return .valid((a, b))
  case let (.valid, .invalid(e)):
    return .invalid(e)
  case let (.invalid(e), .valid):
    return .invalid(e)
  case let (.invalid(e1), .invalid(e2)):
    return . invalid(e1 + e2)
  }
}

func zip2VA<A, B, E>(_ a: [Validated<A, E>], _ b: [Validated<B, E>]) -> [Validated<(A, B), E>] {
  return zip2(a, b).map(zip2)
}


/*:
 - Using the `zip2` defined above write an example usage of it involving two `[Validated<A, E>]` values.
 */
// TODO
/*:
 - Consider the type `Func<R, A?>`. Again we have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of such a function and implement it.
 */
struct Func<R, A> {
  let apply: (R) -> A
}

func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
  return Func<R, (A, B)> { r in
    (r2a.apply(r), r2b.apply(r))
  }
}

func map<A, B, R>(_ f: @escaping (A) -> B) -> (Func<R, A>) -> Func<R, B> {
  return { r2a in
    return Func { r in
      f(r2a.apply(r))
    }
  }
}

func zipFO<A, B, R>(_ r2a: Func<R, A?>, _ r2b: Func<R, B?>) -> Func<R, (A, B)?> {
  return zip2(r2a, r2b) |> map(zip2)
}

/*:
 - Consider the type `Func<R, [A]>`. Again we have a nesting of types, each of which have their own `zip2` operation. Can you define a `zip2` on this type that makes use of both structures? Write the signature of such a function and implement it.
 */
func zipFA<A, B, R>(_ r2a: Func<R, [A]>, _ r2b: Func<R, [B]>) -> Func<R, [(A, B)]> {
  return zip2(r2a, r2b) |> map(zip2)
}
/*:
 - Do you see anything common in the implementation of all of your functions?
 */
// All of them has the same shape: "zip2(a, b) |> map(zip2)
/*:
 5.) In this series of episodes on `zip` we have described zipping types as a kind of way to swap the order of containers, e.g. we can transform a tuple of arrays to an array of tuples `([A], [B]) -> [(A, B)]`. There’s a more general concept that aims to flip contains of any type. Implement the following to the best of your ability, and describe in words what they represent:

 - `sequence: ([A?]) -> [A]?`
 - `sequence: ([Result<A, E>]) -> Result<[A], E>`
 - `sequence: ([Validated<A, E>]) -> Validated<[A], E>`
 - `sequence: ([F3<A>]) -> F3<[A]`
 - `sequence: (Result<A?, E>) -> Result<A, E>?`
 - `sequence: (Validated<A?, E>) -> Validated<A, E>?`
 - `sequence: ([[A]]) -> [[A]]`.

 Note that you can still flip the order of these containers even though they are both the same container type. What does this represent? Evaluate the function on a few sample nested arrays.

 Note that all of these functions also represent the flipping of containers, e.g. an array of optionals transforms into an optional array, an array of results transforms into a result of an array, or a validated optional transforms into an optional validation, etc.
 */
// TODO

func f1<A>(_ a: [A?]) -> [A]? {
  let filtered = a.compactMap { $0 }

  if filtered.count > 0 {
    return filtered
  } else {
    return nil
  }
}

enum Result<Value, Error: Swift.Error> {
  case value(Value)
  case error(Error)
}

func f2<V, E>(_ a: [Result<V, E>]) -> Result<[V], E> {
  var result: [V] = []

  for r in a {
    switch r {
    case let .value(value):
      result.append(value)
    case let .error(error):
      return .error(error)
    }
  }

  return .value(result)
}


func f4<A>(_ val: [F3<A>]) -> F3<[A]> {
  return F3<[A]> { callback in
    let arr = val.reduce([A]()) { result, f in
      var copy = result
      f.run { copy.append($0) }
      return copy
    }

    callback(arr)
  }
}


func f7<A>(_ array: ([[A]])) -> [[A]] {
  return array
}
