/*:
 # Contravariance Exercises

 1.) Determine the sign of all the type parameters in the function `(A) -> (B) -> C`. Note that this is a curried function. It may be helpful to fully parenthesize the expression before determining variance.
 */
// TODO
// (A) -> ((B) -> C)
//         |==|  |==|
//           -1   +1
// |==|   |=========|
//  -1         +1


// A = -1
// B = -1
// C = 1
/*:
 2.) Determine the sign of all the type parameters in the following function:

 `(A, B) -> (((C) -> (D) -> E) -> F) -> G`
 */
// (A, B) -> ((((C) -> (D) -> E) -> F) -> G)
//                     |==| |==|
//                      -1   +1
//             |==|  |=========|
//              -1        +1
//           |=================|   |==|
//                    -1            +1
//           |=======================|   |==|
//                        -1              +1
// |====|    |==============================|
//   -1                     +1



/*:
 3.) Recall that [a setter is just a function](https://www.pointfree.co/episodes/ep6-functional-setters#t813) `((A) -> B) -> (S) -> T`. Determine the variance of each type parameter, and define a `map` and `contramap` for each one. Further, for each `map` and `contramap` write a description of what those operations mean intuitively in terms of setters.
 */
// ((A) -> B) -> (S) -> T
//  |==|  |==|   |==|  |==|
//   -1    1      -1    1
// |========|   |========|
//     -1           +1

func props<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root) -> Root {
    return { update in
      { root in
        var copy = root
        copy[keyPath: kp] = update(copy[keyPath: kp])
        return copy
      }
    }
}

// A
func setterMap<A, B, S, T, C>(
  _ f: @escaping (A) -> C,
  setter: @escaping ((A) -> B) -> (S) -> T) -> (@escaping (C) -> B) -> (S) -> T {
  return { xs in
    let first = f >>> xs
    return setter(first)
  }
}

// B
func setterMap<A, B, S, T, C>(
  _ f: @escaping (C) -> B,
  setter: @escaping ((A) -> B) -> (S) -> T) -> (@escaping (A) -> C) -> (S) -> T {
  return { xs in
    let first = f <<< xs
    return setter(first)
  }
}

// S
func setterMap<A, B, S, T, C>(
  _ f: @escaping (C) -> S,
  setter: @escaping ((A) -> B) -> (S) -> T) -> (@escaping (A) -> B) -> (C) -> T {
  return { xs in
    let first = setter(xs)
    return first <<< f
  }
}

// T
func setterMap<A, B, S, T, C>(
  _ f: @escaping (T) -> C,
  setter: @escaping ((A) -> B) -> (S) -> T) -> (@escaping (A) -> B) -> (S) -> C {
  return { xs in
    let first = setter(xs)
    return first >>> f
  }
}
/*:
 4.) Define `union`, `intersect`, and `invert` on `PredicateSet`.
 */
struct PredicateSet<A> {
  let contains: (A) -> Bool

  func contramap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
    return PredicateSet<B>(contains: f >>> self.contains)
  }
}

func union<A>(_ lhs: PredicateSet<A>, _ rhs: PredicateSet<A>) -> PredicateSet<A> {
  return PredicateSet(contains: { lhs.contains($0) || rhs.contains($0) })
}

func intersect<A>(_ lhs: PredicateSet<A>, _ rhs: PredicateSet<A>) -> PredicateSet<A> {
  return PredicateSet(contains: { lhs.contains($0) && rhs.contains($0) })
}

func invert<A>(_ lhs: PredicateSet<A>) -> PredicateSet<A> {
  return PredicateSet(contains: { !lhs.contains($0) })
}
/*:
 This collection of exercises explores building up complex predicate sets and understanding their performance characteristics.

 5a.) Create a predicate set `isPowerOf2: PredicateSet<Int>` that determines if a value is a power of `2`, _i.e._ `2^n` for some `n: Int`.
 */
let isPowerOf2 = PredicateSet<Int>(contains: { return ($0 > 0) && ($0 & ($0 - 1) == 0) })
isPowerOf2.contains(2)
isPowerOf2.contains(3)
isPowerOf2.contains(6)
isPowerOf2.contains(1024)
/*:
 5b.) Use the above predicate set to derive a new one `isPowerOf2Minus1: PredicateSet<Int>` that tests if a number is of the form `2^n - 1` for `n: Int`.
 */

let isPowerOf2Minus1 = isPowerOf2.contramap { $0 + 1 }
isPowerOf2Minus1.contains(2)
isPowerOf2Minus1.contains(1)
isPowerOf2Minus1.contains(5)
isPowerOf2Minus1.contains(1023)
/*:
 5c.) Find an algorithm online for testing if an integer is prime, and turn it into a predicate `isPrime: PredicateSet<Int>`.
 */
let isPrime = PredicateSet<Int>(contains: { number in return (1...number).filter({number % $0 == 0}).count <= 2 })
isPrime.contains(1)
isPrime.contains(3)
isPrime.contains(18)
isPrime.contains(19)
isPrime.contains(61)
isPrime.contains(199)
isPrime.contains(200)
isPrime.contains(201)


/*:
 5d.) The intersection `isPrime.intersect(isPowerOf2Minus1)` consists of numbers known as [Mersenne primes](https://en.wikipedia.org/wiki/Mersenne_prime). Compute the first 10.
 */
//let mersenne = intersect(isPowerOf2Minus1, isPrime)
////mersenne.contains(10)
//var first10: [Int] = []
//
//for value in 1...Int.max {
//  guard first10.count < 10 else { break }
//  guard mersenne.contains(value) else { continue }
//  first10.append(value)
//}
//
//print(first10)


/*:
 5e.) Recall that `&&` and `||` are short-circuiting in Swift. How does that translate to `union` and `intersect`?
 */

/*:
 6.) What is the difference between `isPrime.intersect(isPowerOf2Minus1)` and `isPowerOf2Minus1.intersect(isPrime)`? Which one represents a more performant predicate set?
 */
// difference: order of contains' calls.
// performance - depends which algorithm is faster and potential number of values in each set
/*:
 7.) It turns out that dictionaries `[K: V]` do not have `map` on `K` for all the same reasons `Set` does not. There is an alternative way to define dictionaries in terms of functions. Do that and define `map` and `contramap` on that new structure.
 */
struct PredicateDictionary<K, V> {
  let value: (K) -> V

  func map<A>(_ t: @escaping (V) -> A) -> PredicateDictionary<K, A> {
    return PredicateDictionary<K, A>(value: self.value >>> t)
  }

  func contraMap<A>(_ t: @escaping (A) -> K) -> PredicateDictionary<A, V> {
    return PredicateDictionary<A, V>(value: self.value <<< t)
  }
}
/*:
 8.) Define `CharacterSet` as a type alias of `PredicateSet`, and construct some of the sets that are currently available in the [API](https://developer.apple.com/documentation/foundation/characterset#2850991).
 */

typealias CharacterSet = PredicateSet<String>

let newLinesAndWhitespaces =  CharacterSet(contains: { ["\n", " "].contains($0) })

newLinesAndWhitespaces.contains("\n")
newLinesAndWhitespaces.contains(" ")
newLinesAndWhitespaces.contains("a")
/*:
 Let's explore happens when a type parameter appears multiple times in a function signature.

 9a.) Is `A` in positive or negative position in the function `(B) -> (A, A)`? Define either `map` or `contramap` on `A`.
 */
// (B) -> (A, A)?
// |==|   |=====|
//  -1       +1

func map<A, B, C>(_ t: @escaping (A) -> C) -> (@escaping (B) -> (A, A)?) -> ((B) -> (C, C)?) {
  return { xs in
    return { b in
      switch xs(b) {
      case .some(let pair):
        return (t(pair.0), t(pair.1))
      case .none:
        return nil
      }
    }
  }
}
/*:
 9b.) Is `A` in positive or negative position in `(A, A) -> B`? Define either `map` or `contramap`.
 */
// (A, A) -> B?
// |====|   |==|
//   -1       1

func contramap<A, B, C>(_ t: @escaping (C) -> A) -> (@escaping ((A, A)) -> B?) -> ((C, C) -> B?) {
  return { xs -> ((C, C) -> B?) in
    return { (first, second) in
      let aPair = (t(first), t(second))
      return xs(aPair)
    }
  }
}


/*:
 9c.) Consider the type `struct Endo<A> { let apply: (A) -> A }`. This type is called `Endo` because functions whose input type is the same as the output type are called "endomorphisms". Notice that `A` is in both positive and negative position. Does that mean that _both_ `map` and `contramap` can be defined, or that neither can be defined?
 */
struct Endo<A> {
  let apply: (A) -> A

  func map<B>(_ f: @escaping (A) -> B) -> Endo<B> {
    fatalError()
  }
}
/*:
 9d.) Turns out, `Endo` has a different structure on it known as an "invariant structure", and it comes equipped with a different kind of function called `imap`. Can you figure out what it’s signature should be?
 */
extension Endo {
  func imap<B>(_ f: @escaping (A) -> B, g: @escaping (B) -> A) -> Endo<B> {
    let newApply = g >>> apply >>> f
    return Endo<B>(apply: newApply)
  }
}
/*:
 10.) Consider the type `struct Equate<A> { let equals: (A, A) -> Bool }`. This is just a struct wrapper around an equality check. You can think of it as a kind of "type erased" `Equatable` protocol. Write `contramap` for this type.
 */
struct Equate<A> {
  let equals: (A, A) -> Bool

  func contramap<B>(_ t: @escaping (B) -> A) -> Equate<B> {
    return Equate<B> { f, s in
      return self.equals(t(f), t(s))
    }
  }
}
/*:
 11.) Consider the value `intEquate = Equate<Int> { $0 == $1 }`. Continuing the "type erased" analogy, this is like a "witness" to the `Equatable` conformance of `Int`. Show how to use `contramap` defined above to transform `intEquate` into something that defines equality of strings based on their character count.
 */
let intEquate = Equate<Int> { $0 == $1 }
let stringEquate = intEquate.contramap { (b: String) in return b.count }
stringEquate.equals("first", "secon")
