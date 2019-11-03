
struct Pair<A, B> {
  let first: A
  let second: B
}

Pair<Void, Void>.init(first: (), second: ())

Pair<Bool, Void>.init(first: true, second: ())
Pair<Bool, Void>.init(first: false, second: ())

Pair<Bool, Bool>.init(first: true, second: true)
Pair<Bool, Bool>.init(first: true, second: false)
Pair<Bool, Bool>.init(first: false, second: true)
Pair<Bool, Bool>.init(first: false, second: false)

enum Three { case one, two, three }
Pair<Bool, Three>.init(first: true, second: .one)
Pair<Bool, Three>.init(first: false, second: .one)
Pair<Bool, Three>.init(first: true, second: .two)
Pair<Bool, Three>.init(first: false, second: .two)
Pair<Bool, Three>.init(first: true, second: .three)
Pair<Bool, Three>.init(first: false, second: .three)

//Pair<Bool, Never>.init(first: true, second: <#T##Never#>)

enum Either<A, B> {
  case left(A)
  case right(B)
}

Either<Void, Void>.left(())
Either<Void, Void>.right(())

Either<Bool, Void>.left(true)
Either<Bool, Void>.left(false)
Either<Bool, Void>.right(())

Either<Bool, Bool>.left(true)
Either<Bool, Bool>.left(false)
Either<Bool, Bool>.right(true)
Either<Bool, Bool>.right(false)

Either<Bool, Three>.left(true)
Either<Bool, Three>.left(false)
Either<Bool, Three>.right(.one)
Either<Bool, Three>.right(.two)
Either<Bool, Three>.right(.three)

Either<Bool, Never>.left(true)
Either<Bool, Never>.left(false)
//Either<Bool, Never>.right(???)


struct User {
  let id: Int
  let isAdmin: Bool
  let name: String
}

User.init

[1, 2, 3, 4].map(String.init)

["1", "2", "blob", "3"].compactMap(Int.init)

Either<Int, String>.left
Either<Int, String>.right

[1, 2, 3, 4].map(Either<Int, String>.left)

let value = Either<Int, String>.left(42)
switch value {
case let .left(left):
  print(left)
case let .right(right):
  print(right)
}

func compute(_ xs: [Int]) -> (product: Int, sum: Int, average: Double) {
  var product = 1
  var sum = 0
  xs.forEach { x in
    product *= x
    sum += x
  }
  return (product, sum, Double(sum) / Double(xs.count))
}

let result = compute([1, 2, 3, 4, 5])
result.product
result.sum

let (product, sum, average) = compute([1, 2, 3, 4, 5])
product
sum
average


let tuple: (id: Int, name: String) = (42, "Blob")

[1, 2, 3].map { $0 + 1 }

tuple.0
tuple.1
tuple.id
tuple.name

[1, 2, 3, 4, 5].reduce((product: 1, sum: 0)) { accum, x in
  (accum.product * x, accum.sum + x)
}

3 * 4
//3 + 4

//3 `addThreeToFour` 4

/*
 let _: (Int, String)

 let choice: (Int | String) = .0(42)
 let choice: (Int | String) = .1("Blob")

 let choice: (id: Int | param: String) = .id(42)
 let choice: (id: Int | param: String) = .param("Blob")

 switch choice {
 case let .0(id):
 print(id)
 case let .1(param):
 print(param)
 }

 switch choice {
 case let .id(id):
 print(id)
 case let .param(param):
 print(param)
 }

 //enum Optional<A> {
 //  case some(A)
 //  case none
 //}

 enum Loading<A> {
 case some(A)
 case loading
 }

 enum EmptyCase<A> {
 case some(A)
 case emptyState
 }

 //Loading<EmptyCase<[User]>>

 func render(data: (user: [User] | empty | loading | )) {
 switch data {

 }
 }
 */

// Homework:
/*
 1. A nice feature that Swift structs have is “properties.” You can access the fields inside the struct via dot syntax, for example view.frame.origin.x. Enums don’t have this feature, but try to explain what the equivalent feature would be.
 */

/*
 Automatic generation of computed properties for associated values, e.g.:
 enum First {
 case a(Baz)
 case b(Foo)

 var baz: Baz? {
 switch self {...}
 }

 var foo: Foo? {
 switch self {...}
 }
 }
 */

/*
 2. Swift enums are sometimes called “tagged unions” because each case is “tagged” with a name. For instance, Optional tags its wrapped value with the some case, and tags the absence of a value with none. This is in contrast to “union” types, which merely describe the idea of choosing between many types, e.g. an optional string can be expressed as string | void, and a number or a string can be expressed as number | string.

 What can an tagged union do that a union can’t do? How might string | void | void be evaluated as a union vs. how might it be represented as an enum?
 */

/*
 Tagged union provides more context. It's the same as with optional, loading and empty case.
 Consider string | void | void:
 - in union case we can't say the difference between 2nd and 3rd elements or we'll need to look into source code
 - in case of tagged union it can be represented as:
 enum {
 case loaded(String)
 case empty
 case loading
 }
 */

/*
 3. The Either type we use in this episode is the closest to an anonymous sum type that we get in Swift as it has no semantics, but it only supports two cases. What are some ways of supporting an “anonymous” sum of three cases? What about four? Or more? Is it possible to support three or more cases using just the Either type?
 */

/*
 Either {
 case left(Either<Bool, Bool>)
 case right(Either<Bool, Bool>)
 }

 or add more cases
 Either {
 one(A)
 two(B)
 three(C)
 etc...
 }
 */
