/*:
 # The Many Faces of Map Exercises

 1. Implement a `map` function on dictionary values, i.e.

    ```
    map: ((V) -> W) -> ([K: V]) -> [K: W]
    ```

    Does it satisfy `map(id) == id`?

 */
func map<K, V, W> (_ transform: @escaping (V) -> W) -> ([K: V]) -> [K: W] {
  return { first in
    var result: [K: W] = [:]

    for pair in first {
      result[pair.key] = transform(pair.value)
    }

    return result
  }
}

[1: 1, 2: 2, 3: 3].mapValues(incr)

// { pair in dict { result[key] = id(value) } }
// { pair in dict { result[key] = value } }
// { reult = dict }
// { dict }
/*:
 2. Implement the following function:

    ```
    transformSet: ((A) -> B) -> (Set<A>) -> Set<B>
    ```

    We do not call this `map` because it turns out to not satisfy the properties of `map` that we saw in this episode. What is it about the `Set` type that makes it subtly different from `Array`, and how does that affect the genericity of the `map` function?
 */
// TODO
func transformSet<A: Hashable, B: Hashable>(_ f: @escaping (A) -> B) -> (Set<A>) -> Set<B> {
  return { xs in
    var copy: Set<B> = []
    xs.forEach { copy.insert(f($0)) }
    return copy
  }
}


/*:
 3. Recall that one of the most useful properties of `map` is the fact that it distributes over compositions, _i.e._ `map(f >>> g) == map(f) >>> map(g)` for any functions `f` and `g`. Using the `transformSet` function you defined in a previous example, find an example of functions `f` and `g` such that:

    ```
    transformSet(f >>> g) != transformSet(f) >>> transformSet(g)
    ```

    This is why we do not call this function `map`.
 */
let set: Set<Int> = [-2, -1, 0, 1, 2]

/*:
 4. There is another way of modeling sets that is different from `Set<A>` in the Swift standard library. It can also be defined as function `(A) -> Bool` that answers the question "is `a: A` contained in the set." Define a type `struct PredicateSet<A>` that wraps this function. Can you define the following?

     ```
     map: ((A) -> B) -> (PredicateSet<A>) -> PredicateSet<B>
     ```

     What goes wrong?
 */
struct PredicateSet<A> {
  let contains: (A) -> Bool
}

func map<A, B>(_ transform: @escaping (A) -> B) -> (PredicateSet<A>) -> PredicateSet<B> {
  return { xs in
    // functions below take the same value type as an argument and return different values. We can't connect them
    xs.contains // (A) -> Bool
    transform // (A) -> B

    fatalError()
  }
}
/*:
 5. Try flipping the direction of the arrow in the previous exercise. Can you define the following function?

    ```
    fakeMap: ((B) -> A) -> (PredicateSet<A>) -> PredicateSet<B>
    ```
 */
func fakeMap<A, B>(_ transform: @escaping (B) -> A) -> (PredicateSet<A>) -> PredicateSet<B> {
  return { xs in
//    xs.contains // (A) -> Bool
//    transform // (B) -> A
    return PredicateSet(contains: transform >>> xs.contains)
  }
}

let isEven = PredicateSet(contains: { $0 % 2 == 0 })
let odd = fakeMap({ $0 + 1 })(isEven)
odd.contains(2)
odd.contains(3)

/*:
 6. What kind of laws do you think `fakeMap` should satisfy?
 */
// TODO
/*:
 7. Sometimes we deal with types that have multiple type parameters, like `Either` and `Result`. For those types you can have multiple `map`s, one for each generic, and no one version is “more” correct than the other. Instead, you can define a `bimap` function that takes care of transforming both type parameters at once. Do this for `Result` and `Either`.
 */
enum Result<A, B> {
  case value(A)
  case error(B)

  func bimap<C, D>(_ f: (A) -> C, g: (B) -> D) -> Result<C, D> {
    switch self {
    case .value(let value):
      return .value(f(value))
    case .error(let error):
      return .error(g(error))
    }
  }
}

enum Either<A, B> {
  case left(A)
  case right(B)

  func bimap<C, D>(_ f: (A) -> C, g: (B) -> D) -> Either<C, D> {
    switch self {
    case .left(let value):
      return .left(f(value))
    case .right(let value):
      return .right(g(value))
    }
  }
}

// MARK: - 8. Write a few implementations of the following function:
//func r<A>(_ xs: [A]) -> A? {}

func r<A>(_ xs: [A]) -> A? {
  return xs.first
  return xs.last
  return .none

  if xs.count > 1 {
    return xs[0]
  } else {
    return .none
  }
}

// MARK: - 9. Continuing the previous exercise, can you generalize your implementations of r to a function [A] -> B? if you had a function f: (A) -> B?
//func s<A, B>(_ f: (A) -> B, _ xs: [A]) -> B? {}
// What features of arrays and optionals do you need to implement this?

func s<A, B>(_ f: (A) -> B, _ xs: [A]) -> B? {
  return r(xs).map(f)
}

// MARK: - 10. Derive a relationship between r, any function f: (A) -> B, and the map on arrays and optionals.

//[A] -> r -> A? -> map(f) -> B?
