/*:
 # Higher-Order Functions Exercises

 1. Write `curry` for functions that take 3 arguments.
 */
func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
  return { a in { b in { c in f(a, b, c) } } }
}

func sum3(_ a: Int, b: Int, c: Int) -> Int {
  return a + b + c
}

sum3
curry(sum3)
/*:
 2. Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using `curry`, `zurry`, `flip`, or by hand.
 */
// TODO
/*:
 3. Explore the associativity of function arrow `->`. Is it fully associative, _i.e._ is `((A) -> B) -> C` equivalent to `(A) -> ((B) -> C)`, or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?
 */
// TODO
/*:
 4. Write a function, `uncurry`, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
 */
func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in { b in f(a, b) } }
}

func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
  return { a, b in f(a)(b) }
}

func sum2(_ a: Int, b: Int) -> Int { return a + b }
sum2
curry(sum2)
uncurry(curry(sum2))
/*:
 5. Write `reduce` as a curried, free function. What is the configuration _vs._ the data?
 */
func reduce<A, B>(_ acc: B, _ t: @escaping (B, A) -> B) -> ([A]) -> B {
  return { arr in arr.reduce(acc, t) }
}

[1, 2, 3] |> reduce(0, +)
/*:
 6. In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type `struct PseudoEither<A, B>` of a pair of optionals, and prevent the creation of invalid values by providing initializers.

    This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.
 */
struct PseudoEither<A, B>: CustomStringConvertible {
  let left: A?
  let right: B?

  init(left: A) {
    self.left = left
    self.right = nil
  }

  init(right: B) {
    self.left = nil
    self.right = right
  }

  var description: String {
    if let left = left {
      return "Left: \(left)"
    } else if let right = right {
      return "Right: \(right)"
    } else {
      return "Error"
    }
  }
}

let pseudo1: PseudoEither<Int, String> = .init(left: 5)
let pseudo2: PseudoEither<Int, String> = .init(right: "5")
/*:
 7. Explore how the free `map` function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array `[[A]]`, then `map` could mean either the transformation on the inner array or the outer array. Can you make sense of doing `map >>> map`?
 */
// TODO

func map<A, B>(_ t: @escaping (A) -> B) -> ([A]) -> [B] {
  return { arr in arr.map(t) }
}

dump([[1, 2, 3], [4, 5, 6]] |> (map >>> map) { $0 })
