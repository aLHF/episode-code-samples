/*:
 # Composition without Operators

 1. Write concat for functions (inout A) -> Void.
 */

//func concat<A>(_ f: @escaping (A) -> Void, _ g: @escaping (A) -> Void, _ fs: ((A) -> Void)...)  -> (A) -> Void {
//  return { a in
//    f(a)
//    g(a)
//    fs.forEach { f in f(a) }
//  }
//}

func concat<A>(_ f: @escaping (inout A) -> Void, _ g: @escaping (inout A) -> Void, _ fs: ((inout A) -> Void)...) -> (inout A) -> Void {
  return { a in
    f(&a)
    g(&a)
    fs.forEach { $0(&a) }
  }
}

struct User {
  var name: String
  var age: Int
}

var test = User(name: "John", age: 32)
let transform: (inout User) -> Void = concat({ user in
  user.name = "Anna"
}, { user in
  user.age = 16
})

transform(&test)

test.name
test.age
/*:
 2. Write concat for functions (A) -> A.
 */
func concat<A>(_ f: @escaping (A) -> A, _ g: @escaping (A) -> A, _ fs: ((A) -> A)...) -> (A) -> A {
  return { a in return fs.reduce(g(f(a))) { $1($0) } }
}

concat(incr, incr, incr, incr, incr, incr, square)(5)
/*:
 3. Write compose for backward composition. Recreate some of the examples from our functional setters episodes (part 1 and part 2) using compose and pipe.
 */
func compose<A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
  return { f(g($0)) }
}

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
  return { (f($0.0), $0.1) }
}

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
  return { ($0.0, f($0.1)) }
}

let tuple = ((1, "Point"), (2, "Free"))

dump(tuple |> (compose(first, first)) { $0 + 10 })

let tuple2 = (1, [1, 2, 3, 4, 5])

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { $0.map(f) }
}

dump(tuple2 |> (compose(second, map)) { $0 * $0 })
