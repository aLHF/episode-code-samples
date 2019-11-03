/*:
 # Algebraic Data Types: Generics and Recursion

 1.) Define addition and multiplication on `NaturalNumber`:

 * `func +(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber`
 * `func *(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber`

 */
import Foundation

enum NaturalNumber: Equatable {
  case zero
  indirect case successor(NaturalNumber)
}

func integer(from number: NaturalNumber) -> Int {
  guard case .successor = number else { return 0 }

  var result = 0
  var current = number

  while case let .successor(predecessor) = current {
    current = predecessor
    result += 1
  }

  return result
}

func add(to number: NaturalNumber, integer: Int) -> NaturalNumber {
  var current = number

  for _ in 1...integer {
    current = .successor(current)
  }

  return current
}

func +(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
  switch (lhs, rhs) {
  case (.zero, .zero):
    return .zero
  case (.zero, _):
    return rhs
  case (_, .zero):
    return lhs
  case (.successor, .successor):
    return add(to: lhs, integer: integer(from: rhs))
  }
}

let number1 = NaturalNumber.successor(.successor(.successor(.successor(.zero))))
let number2 = NaturalNumber.successor(.successor(.successor(.zero)))
integer(from: number1)
integer(from: number2)
integer(from: number1 + number2)

func *(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
  switch (lhs, rhs) {
  case (.zero, _):
    return .zero
  case (_, .zero):
    return .zero
  case (.successor, .successor):
    let leftInteger = integer(from: lhs)
    let rightInteger = integer(from: rhs)

    return add(to: lhs, integer: leftInteger * rightInteger - leftInteger)
  }
}

integer(from: number1 * number2)
/*:
 2.) Implement the `exp` function on `NaturalNumber` that takes a number to a power:

 `exp(_ base: NaturalNumber, _ power: NaturalNumber) -> NaturalNumber`
 */
// TODO

func exp(_ base: NaturalNumber, _ power: NaturalNumber) -> NaturalNumber {
  switch (base, power) {
  case (.zero, _):
    return .zero
  case (_, .zero):
    return .successor(.zero)
  case (.successor, .successor):
    let leftInteger = integer(from: base)
    let rightInteger = integer(from: power)
    let raised = Int(pow(Float(leftInteger), Float(rightInteger)))

    return add(to: base, integer: raised - leftInteger)
  }
}

integer(from: exp(number1, number2))
/*:
 3.) Conform `NaturalNumber` to the `Comparable` protocol.
 */
extension NaturalNumber: Comparable {
  static func < (lhs: NaturalNumber, rhs: NaturalNumber) -> Bool {
    return integer(from: lhs) < integer(from: rhs)
  }
}

number1 < number2
number2 < number1
/*:
 4.) Implement `min` and `max` functions for `NaturalNumber`.
 */
extension NaturalNumber {
  static var min: NaturalNumber {  return .zero }
  static var max: NaturalNumber { fatalError() } // ????
}


func min(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
  let leftInt = integer(from: lhs)
  let rightInt = integer(from: rhs)

  switch (leftInt, rightInt) {
  case let (x, y) where x < y: return lhs
  case let (x, y) where y < x: return rhs
  default: return lhs
  }
}

integer(from: min(number1, number2))

func max(_ lhs: NaturalNumber, _ rhs: NaturalNumber) -> NaturalNumber {
  let leftInt = integer(from: lhs)
  let rightInt = integer(from: rhs)

  switch (leftInt, rightInt) {
  case let (x, y) where x > y: return lhs
  case let (x, y) where y > x: return rhs
  default: return lhs
  }
}

integer(from: max(number1, number2))
/*:
 5.) How could you implement *all* integers (both positive and negative) as an algebraic data type? Define all of the above functions and conformances on that type.
 */
enum Integer: Equatable {
  case zero
  indirect case predecessor(Integer)
  indirect case successor(Integer)
}

func integer(from number: Integer) -> Int {
  guard number != .zero else { return 0 }

  var result = 0
  var current = number

  while current != .zero {
    switch current {
    case let .predecessor(successor):
      result -= 1
      current = successor
    case let .successor(predecessor):
      result += 1
      current = predecessor
    case .zero:
      continue
    }
  }

  return result
}

let integer = Integer.predecessor(.predecessor(.predecessor(.predecessor(.predecessor(.predecessor(.zero))))))
integer(from: integer)

func add(to number: Integer, integer: Int) -> Integer {
  guard integer != 0 else { return number }

  var current = number

  for _ in 1...abs(integer) {
    if integer > 0 {
      current = .successor(current)
    } else {
      current = .predecessor(current)
    }
  }

  return current
}

func subsctract(to number: Integer, integer: Int) -> Integer {
  return add(to: number, integer: -integer)
}

integer(from: add(to: integer, integer: 5))
integer(from: add(to: integer, integer: 15))
integer(from: subsctract(to: integer, integer: -6))

func +(_ lhs: Integer, _ rhs: Integer) -> Integer {
  switch (lhs, rhs) {
  case (.zero, .zero):
    return .zero
  case (.zero, _):
    return rhs
  case (_, .zero):
    return lhs
  default:
    let leftInteger = integer(from: lhs)
    let rightInteger = integer(from: rhs)

    return add(to: lhs, integer: (leftInteger + rightInteger) - leftInteger)
  }
}

integer(from: add(to: Integer.zero, integer: 15) + add(to: .zero, integer: -1))


func *(_ lhs: Integer, _ rhs: Integer) -> Integer {
  switch (lhs, rhs) {
  case (.zero, _):
    return .zero
  case (_, .zero):
    return .zero
  default:
    let leftInteger = integer(from: lhs)
    let rightInteger = integer(from: rhs)

    return add(to: lhs, integer: leftInteger * rightInteger - leftInteger)
  }
}

integer(from: add(to: Integer.zero, integer: -2) * add(to: .zero, integer: 0))

// Exp should cover cases when power is negative. Also 0 to negative power seems to be infinite

extension Integer: Comparable {
  static func < (lhs: Integer, rhs: Integer) -> Bool {
    return integer(from: lhs) < integer(from: rhs)
  }
}

add(to: Integer.zero, integer: -1) < add(to: Integer.zero, integer: -1)

func min(_ lhs: Integer, _ rhs: Integer) -> Integer {
  let leftInt = integer(from: lhs)
  let rightInt = integer(from: rhs)

  switch (leftInt, rightInt) {
  case let (x, y) where x < y: return lhs
  case let (x, y) where y < x: return rhs
  default: return lhs
  }
}

func max(_ lhs: Integer, _ rhs: Integer) -> Integer {
  let leftInt = integer(from: lhs)
  let rightInt = integer(from: rhs)

  switch (leftInt, rightInt) {
  case let (x, y) where x > y: return lhs
  case let (x, y) where y > x: return rhs
  default: return lhs
  }
}

integer(from: max(add(to: Integer.zero, integer: -1), add(to: Integer.zero, integer: 1)))
integer(from: min(add(to: Integer.zero, integer: 10), add(to: Integer.zero, integer: 100)))
/*:
 6.) What familiar type is `List<Void>` equivalent to? Write `to` and `from` functions between those types showing how to travel back-and-forth between them.
 */
enum List<A> {
  case empty
  indirect case cons(A, List<A>)
}

func to(_ list: List<Void>) -> NaturalNumber {
  var current = list
  var result = NaturalNumber.zero

  while case let .cons(next) = current {
    current = next.1
    result = .successor(result)
  }

  return result
}

func from(_ number: NaturalNumber) -> List<Void> {
  guard number != .zero else { return .empty }

  var result: List<Void> = .empty
  for _ in 1...integer(from: number) {
    result = .cons((), result)
  }

  return result
}

let number6 = NaturalNumber.successor(.successor(.successor(.successor(.zero))))
integer(from: to(from(to(from(number6)))))
from(to(from(to(from(number6)))))
/*:
 7.) Conform `List` and `NonEmptyList` to the `ExpressibleByArrayLiteral` protocol.
 */
extension List: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: A...) {
    var result: List<A> = .empty
    for element in elements {
      result = .cons(element, result)
    }

    self = result
  }
}

let list: List<Int> = [1, 2, 3, 4, 5]
//switch list {
//case .empty: print("e")
//case .cons(let value, _): print(value)
//}

enum NonEmptyList<A> {
  case singleton(A)
  indirect case cons(A, NonEmptyList<A>)
}

extension NonEmptyList: ExpressibleByArrayLiteral {
  init(arrayLiteral elements: A...) {
    guard elements.count > 0 else { fatalError() }

    var result: NonEmptyList<A> = .singleton(elements.first!)
    for element in elements {
      result = .cons(element, result)
    }

    self = result
  }
}

let nonEmptyList: NonEmptyList<Int> = [1, 2, 3, 4, 5]
//switch nonEmptyList {
//case .singleton(let value): print(value)
//case .cons(let value, _): print(value)
//}
/*:
 8.) Conform `List` to the `Collection` protocol.
 */
extension List: Collection {
  var startIndex: Int {
    return 1
  }

  var endIndex: Int {
    return self.depth() + 1
  }

  func index(after i: Int) -> Int {
    return i + 1
  }

  subscript(index: Int) -> A {
    let offset = endIndex - index - 1

    if offset == 0 {
      return self.value()
    } else {
      var result = self

      for _ in 1...offset {
        switch result {
        case .empty:
          fatalError()
        case .cons(_, let list):
          result = list
        }
      }

      return result.value()
    }
  }

  private func depth() -> Int {
    var result = 0
    var current = self

    while case .cons(_, let next) = current {
      result += 1
      current = next
    }

    return result
  }

  private func value() -> A {
    switch self {
    case .empty:
      fatalError()
    case .cons(let value, _):
      return value
    }
  }
}

for value in list {
  print(value)
}
/*:
 9.) Conform each implementation of `NonEmptyList` to the `Collection` protocol.
 */
struct NonEmptyList1<A> {
  let head: A
  let tail: List<A>
}

extension NonEmptyList1: Collection {
  var startIndex: Int {
    return 1
  }

  var endIndex: Int {
    return tail.endIndex + 1
  }

  func index(after i: Int) -> Int {
    return i + 1
  }

  subscript(index: Int) -> A {
    if index == tail.endIndex {
      return head
    }

    return tail[index]
  }
}

let test9: NonEmptyList1 = NonEmptyList1(head: 15, tail: [11, 12, 13, 14])
for x in test9 {
  print("test9: \(x)")
}
/*:
 10.) Consider the type `enum List<A, B> { cae empty; case cons(A, B) }`. It's kinda like list without recursion, where the recursive part has just been replaced with another generic. Now consider the strange type:

    enum Fix<A> {
      case fix(ListF<A, Fix<A>>)
    }

 Construct a few values of this type. What other type does `Fix` seem to resemble?
 */
// TODO
enum NonRecursiveList<A, B> {
  case empty
  case cons(A, B)
}

enum Fix<A> {
  indirect case fix(NonRecursiveList<A, Fix<A>>)
}

let empty10 = Fix<Int>.fix(.empty)
Fix<Int>.fix(.cons(1, empty10))
Fix<Int>.fix(.cons(1, .fix(.empty)))
Fix<Int>.fix(.cons(1, .fix(.cons(15, .fix(.empty)))))

/*:
 11.) Construct an explicit mapping between the `List<A>` and `Fix<A>` types by implementing:

 * `func to<A>(_ list: List<A>) -> Fix<A>`
 * `func from<A>(_ fix: Fix<A>) -> List<A>`

 The type `Fix` is known as the "fixed-point" of `List`. It is more generic than just dealing with lists, but unfortunately Swift does not have the type feature (higher-kinded types) to allow us to express this.
 */
// TODO

func to<A>(_ list: List<A>) -> Fix<A> {
  var result: Fix<A> = .fix(.empty)
  var current = list

  while case let .cons(value, next) = current {
    current = next
    result = .fix(.cons(value, result))
  }

  return result
}

func from<A>(_ fix: Fix<A>) -> List<A> {
  var result: List<A> = .empty
  var current = fix

  while case let .fix(list) = current, case let .cons(value, next) = list {
    current = next
    result = .cons(value, result)
  }

  return result
}

dump(list)
dump(to(list))
dump(from(to(list)))

print("===")
for x in from(to(list)) {
  print(x)
}
