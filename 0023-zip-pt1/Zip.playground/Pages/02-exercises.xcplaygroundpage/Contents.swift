/*:
 # The Many Faces of Zip: Part 1

 ## Exercises

 1.) In this episode we came across closures of the form `{ ($0, $1.0, $1.1) }` a few times in order to unpack a tuple of the form `(A, (B, C))` to `(A, B, C)`. Create a few overloaded functions named `unpack` to automate this.

 */
func unpack<A, B, C>(_ a: A, _ bc: (B, C)) -> (A, B, C) {
  return (a, bc.0, bc.1)
}

func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
  var result: [(A, B)] = []
  (0..<min(xs.count, ys.count)).forEach { idx in
    result.append((xs[idx], ys[idx]))
  }
  return result
}

zip2([1, 2, 3], ["one", "two", "three"])

func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
  return zip2(xs, zip2(ys, zs)).map(unpack)
}

zip3([1, 2, 3], ["one", "two", "three"], [true, false, true])

func zip2<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
  guard let a = a, let b = b else { return nil }
  return (a, b)
}

func zip3<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? {
  return zip2(a, zip2(b, c)).map(unpack)
}

let one: Int? = 1
let two: Int? = 2
let three: Int? = 3
zip3(one, two, three)
/*:
 2.) Define `zip4`, `zip5`, `zip4(with:)` and `zip5(with:)` on arrays and optionals. Bonus: [learn](https://nshipster.com/swift-gyb/) how to use Apple's `gyb` tool to generate higher-arity overloads.
 */
func unpack<A, B, C, D>(_ a: A, bcd: (B, C, D)) -> (A, B, C, D) {
  return (a, bcd.0, bcd.1, bcd.2)
}

func unpack<A, B, C, D, E>(_ a: A, bcde: (B, C, D, E)) -> (A, B, C, D, E) {
  return (a, bcde.0, bcde.1, bcde.2, bcde.3)
}

func zip4<A, B, C, D>(_ xs: [A], _ bs: [B], _ cs: [C], _ ds: [D]) -> [(A, B, C, D)] {
  return zip2(xs, zip3(bs, cs, ds)).map(unpack)
}

zip4([1, 2], [1, 2], [1, 2, 3], [1, 2, 3, 4])

func zip4<A, B, C, D, E>(
  with f: @escaping (A, B, C, D) -> E
  ) -> ([A], [B], [C], [D]) -> [E] {
  return { zip4($0, $1, $2, $3).map(f) }
}

func zip5<A, B, C, D, E>(_ xs: [A], _ bs: [B], _ cs: [C], _ ds: [D], _ es: [E]) -> [(A, B, C, D, E)] {
  return zip2(xs, zip4(bs, cs, ds, es)).map(unpack)
}


func zip5<A, B, C, D, E, F>(
  with f: @escaping (A, B, C, D, E) -> F
  ) -> ([A], [B], [C], [D], [E]) -> [F] {
  return { zip5($0, $1, $2, $3, $4).map(f) }
}
/*:
 3.) Do you think `zip2` can be seen as a kind of associative infix operator? For example, is it true that `zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs)`? If it's not strictly true, can you define an equivalence between them?
 */
let int3 = [1, 2, 3]
let str3 = ["1", "2", "3"]
let dbl3 = [1.0, 2.0, 3.0]

print(zip2(int3, zip2(str3, dbl3)))
print(zip2(zip2(int3, str3), dbl3))

// zip(xs, zip(ys, zs)) == zip(zip(xs, ys), zs) is false. It's unequal
/*:
 4.) Define `unzip2` on arrays, which does the opposite of `zip2: ([(A, B)]) -> ([A], [B])`. Can you think of any applications of this function?
 */
func unzip2<A, B>(_ tuple: [(A, B)]) -> ([A], [B]) {
  return tuple.reduce(([A](), [B]())) { result, tuple in
    var result = result
    result.0.append(tuple.0)
    result.1.append(tuple.1)
    return result
  }

//  return (tuple.map { $0.0 }, tuple.map { $0.1 })
}

let int = [1, 2, 3]
let str = ["1", "2", "3"]
zip2(int, str)
unzip2(zip2(int, str))
/*:
 5.) It turns out, that unlike the `map` function, `zip2` is not uniquely defined. A single type can have multiple, completely different `zip2` functions. Can you find another `zip2` on arrays that is different from the one we defined? How does it differ from our `zip2` and how could it be useful?
 */
func combos2<A, B>(_ xs: [A], ys: [B]) -> [(A, B)] {
  return xs.flatMap { x in ys.map { y in (x, y) } }
}

print(" combos: \(combos2([1, 2, 3], ys: [1.0, 2.0]))")

/*:
 6.) Define `zip2` on the result type: `(Result<A, E>, Result<B, E>) -> Result<(A, B), E>`. Is there more than one possible implementation? Also define `zip3`, `zip2(with:)` and `zip3(with:)`.

 Is there anything that seems wrong or “off” about your implementation? If so, it
 will be improved in the next episode 😃.
 */

enum Result<Value, Error: Swift.Error> {
  case value(Value)
  case error(Error)
}

func zip2<A, B, E>(_ xs: Result<A, E>, ys: Result<B, E>) -> Result<(A, B), E> {
  switch (xs, ys) {
  case let (.value(a), .value(b)):
    return .value((a, b))
  case let (.value, .error(e)):
    return .error(e)
  case let (.error(e), .value):
    return .error(e)
  case let (.error(e1), .error(e2)): // two implementations
    return .error(e1)
    return .error(e2)
  }
}

func zip2<A, B, C>(
  with f: @escaping (A, B) -> C
  ) -> ([A], [B]) -> [C] {

  return { zip2($0, $1).map(f) }
}

func zip2<A, B, C, E>(
  with: @escaping (A, B) -> C
  ) -> (Result<A, E>, Result<B, E>) -> Result<C, E> {

  return {
    switch zip2($0, ys: $1) {
    case .value(let pair):
      return .value(with(pair.0, pair.1))
    case .error(let error):
      return .error(error)
    }
  }
}
/*:
 7.) In [previous](/episodes/ep14-contravariance) episodes we've considered the type that simply wraps a function, and let's define it as `struct Func<R, A> { let apply: (R) -> A }`. Show that this type supports a `zip2` function on the `A` type parameter. Also define `zip3`, `zip2(with:)` and `zip3(with:)`.
 */
struct Func<R, A> {
  let apply: (R) -> A
}

func zip2<A, B, R>(_ xs: Func<R, A>, _ ys: Func<R, B>) -> Func<R, (A, B)> {
  return .init { r in
    return (xs.apply(r), ys.apply(r))
  }
}

let first7 = Func<Int, String> { "\($0)" }
let second7 = Func<Int, Int> { $0 * $0 }
let third7 = zip2(first7, second7)


func zip2<A, B, C, R>(_
  with: @escaping (A, B) -> C
  ) -> (Func<R, A>, Func<R, B>) -> Func<R, C> {

  return { fa, fb in .init { r in with(fa.apply(r), fb.apply(r)) } }
}

func zip3<A, B, C, R>(_ xs: Func<R, A>, _ ys: Func<R, B>, _ zs: Func<R, C>) -> Func<R, (A, B, C)> {
  return .init { r in
    return (xs.apply(r), ys.apply(r), zs.apply(r))
  }

//  return .init { r in
//    let abc = zip2(zip2(xs, ys), zs).apply(r)
//    return (abc.0.0, abc.0.1, abc.1)
//  }
}

func zip3<A, B, C, D, R>(_
  with: @escaping (A, B, C) -> D
  ) -> (Func<R, A>, Func<R, B>, Func<R, C>) -> Func<R, D> {

  return { fa, fb, fc in .init { r in with(fa.apply(r), fb.apply(r), fc.apply(r)) } }
}
/*:
 8.) The nested type `[A]? = Optional<Array<A>>` is composed of two containers, each of which has their own `zip2` function. Can you define `zip2` on this nested container that somehow involves each of the `zip2`'s on the container types?
 */
func zip4<A, B>(_ xs: [A]?, ys: [B]?) -> [(A, B)]? {
//  guard let pair = zip2(xs, ys) else { return nil }
//  return zip2(pair.0, pair.1)
  return zip2(xs, ys).map(zip2)
}
