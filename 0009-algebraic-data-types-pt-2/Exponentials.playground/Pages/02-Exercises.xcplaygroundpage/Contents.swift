/*:
 # Algebraic Data Types: Exponents, Exercises

 1. Explore the equivalence of `1^a = a`.
 */

// Void <- A = A
// A -> Void = A

//func first<A>(_ f: (A) -> Void) -> A {
//  // ???
//}
/*:
 2. Explore the properties of `0^a`. Consider the cases where `a = 0` and `a != 0` separately.
 */

// a = 0. 0^0 = 1
// Never -> Never = Void

// if a != 0. 0^A = 0
// Never -> Never = Never

/*:
 3. How do you think generics fit into algebraic data types? We've seen a bit of this with thinking of `Optional<A>` as `A + 1 = A + Void`.
 */
// TODO
/*:
 4. Show that the set type over a type `A` can be represented as `2^A`. What does union and intersection look like in this formulation?
 */
// Union
// Pair(2^A, 2^A)
// 2^A + 2^A

// Intersection
// 2^A * 2^A =

func union<A>(lhs: @escaping (A) -> Bool, rhs: @escaping (A) -> Bool) -> (A) -> Bool {
  return { a in
    return lhs(a) || rhs(a)
  }
}

func intersection<A>(lhs: @escaping (A) -> Bool, rhs: @escaping (A) -> Bool) -> (A) -> Bool {
  return { a in
    return lhs(a) && rhs(a)
  }
}


/*:
 5. Show that the dictionary type with keys in `K`  and values in `V` can be represented by `V^K`. What does union of dictionaries look like in this formulation?
 */
// K -> V?
/*:
 6. Implement the following equivalence:
 */
func to<A, B, C>(_ f: @escaping (Either<B, C>) -> A) -> ((B) -> A, (C) -> A) {
  let BtoA: (B) -> A = { b in return f(Either.left(b)) }
  let CtoA: (C) -> A = { c in return f(Either.right(c)) }

  return (BtoA, CtoA)
}

func from<A, B, C>(_ f: ((B) -> A, (C) -> A)) -> (Either<B, C>) -> A {
  return { either in
    switch either {
    case .left(let b): return f.0(b)
    case .right(let c): return f.1(c)
    }
  }
}
/*:
 7. Implement the following equivalence:
 */
func to<A, B, C>(_ f: @escaping (C) -> (A, B)) -> ((C) -> A, (C) -> B) {
  let CtoA: (C) -> A = { c in return f(c).0 }
  let CtoB: (C) -> B = { c in return f(c).1 }
  return (CtoA, CtoB)
}

func from<A, B, C>(_ f: ((C) -> A, (C) -> B)) -> (C) -> (A, B) {
  return { c in
    return (f.0(c), f.1(c))
  }
}
