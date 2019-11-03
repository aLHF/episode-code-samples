
enum List<A> {
  case empty
  indirect case cons(A, List<A>)
}

struct NonEmptyListProduct<A> {
  let head: A
  let tail: List<A>
}

enum NonEmptyListSum<A> {
  case singleton(A)
  indirect case cons(A, NonEmptyListSum<A>)
}

[1, 2, 3]
NonEmptyListProduct(head: 1, tail: .cons(2, .cons(3, .empty)))
NonEmptyListSum.cons(1, .cons(2, .singleton(3)))

struct NonEmptyArray<A> {
  var head: A
  var tail: [A]
}

extension NonEmptyArray: CustomStringConvertible {
  var description: String {
    return "\(head)\(tail)"
  }
}

NonEmptyArray(head: 1, tail: [2, 3])

extension NonEmptyArray {
  //  init(_ head: A, _ tail: [A] = []) {
  //    self.head = head
  //    self.tail = tail
  //  }
  init(_ head: A, _ tail: A...) {
    self.head = head
    self.tail = tail
  }
}

//NonEmptyArray(1, [2, 3])
//NonEmptyArray(1, [])
NonEmptyArray(1)
NonEmptyArray(1, 2, 3)
//NonEmptyArray()

extension NonEmptyArray: Collection {
  var startIndex: Int {
    return 0
  }

  var endIndex: Int {
    return self.tail.endIndex + 1
  }

  subscript(position: Int) -> A {
    return position == 0 ? self.head : self.tail[position - 1]
  }

  func index(after i: Int) -> Int {
    return i + 1
  }
}

let xs = NonEmptyArray(1, 2, 3)
xs.forEach { print($0) }
xs.count
xs.first


extension NonEmptyArray {
  var first: A {
    return self.head
  }
}

extension NonEmptyArray: BidirectionalCollection {
  func index(before i: Int) -> Int {
    return i - 1
  }
}

xs.last

extension NonEmptyArray {
  var last: A {
    return self.tail.last ?? self.head
  }
}

xs.last + 1

struct NonEmpty<C: Collection> {
  var head: C.Element
  var tail: C

  init(_ head: C.Element, _ tail: C) {
    self.head = head
    self.tail = tail
  }
}

extension NonEmpty: CustomStringConvertible {
  var description: String {
    return "\(self.head)\(self.tail)"
  }
}

NonEmpty<[Int]>(1, [2, 3])
NonEmpty<[Int]>(1, [])
NonEmpty<Set<Int>>(1, [2, 3])
NonEmpty<[Int: String]>((1, "Blob"), [2: "Blob Junior", 3: "Blob Senior"])

NonEmpty<String>("B", "lob")

extension NonEmpty where C: RangeReplaceableCollection {
  init(_ head: C.Element, _ tail: C.Element...) {
    self.head = head
    self.tail = C(tail)
  }
}

NonEmpty<[Int]>(1, 2, 3)
//NonEmpty<Set<Int>>(1, 2, 3)

extension NonEmpty: Collection {
  enum Index: Comparable {
    case head
    case tail(C.Index)

    static func < (lhs: Index, rhs: Index) -> Bool {
      switch (lhs, rhs) {
      case (.head, .tail):
        return true
      case (.tail, .head):
        return false
      case (.head, .head):
        return false
      case let (.tail(l), .tail(r)):
        return l < r
      }
    }
  }

  var startIndex: Index {
    return .head
  }

  var endIndex: Index {
    return .tail(self.tail.endIndex)
  }

  subscript(position: Index) -> C.Element {
    switch position {
    case .head:
      return self.head
    case let .tail(index):
      return self.tail[index]
    }
  }

  func index(after i: Index) -> Index {
    switch i {
    case .head:
      return .tail(self.tail.startIndex)
    case let .tail(index):
      return .tail(self.tail.index(after: index))
    }
  }
}

let ys = NonEmpty<[Int]>(1, 2, 3)
ys.forEach { print($0) }
ys.count
ys.first

extension NonEmpty {
  var first: C.Element {
    return self.head
  }
}

ys.first + 1

extension NonEmpty: BidirectionalCollection where C: BidirectionalCollection {
  func index(before i: Index) -> Index {
    switch i {
    case .head:
      return .tail(self.tail.index(before: self.tail.startIndex))
    case let .tail(index):
      return index == self.tail.startIndex ? .head : .tail(self.tail.index(before: index))
    }
  }
}

extension NonEmpty where C: BidirectionalCollection {
  var last: C.Element {
    return self.tail.last ?? self.head
  }
}

ys.last + 1

ys[.head]
ys[.tail(0)]
ys[.tail(1)]

extension NonEmpty where C.Index == Int {
  subscript(position: Int) -> C.Element {
    return self[position == 0 ? .head : .tail(position - 1)]
  }
}

ys[0]
ys[1]
ys[2]

var zs = NonEmpty<[Int]>(1, 2, 3)
//zs[0] = 42

extension NonEmpty: MutableCollection where C: MutableCollection {
  subscript(position: Index) -> C.Element {
    get {
      switch position {
      case .head:
        return self.head
      case let .tail(index):
        return self.tail[index]
      }
    }
    set(newValue) {
      switch position {
      case .head:
        self.head = newValue
      case let .tail(index):
        self.tail[index] = newValue
      }
    }
  }
}

zs[.head] = 42
zs

extension NonEmpty where C: MutableCollection, C.Index == Int {
  subscript(position: Int) -> C.Element {
    get {
      return self[position == 0 ? .head : .tail(position - 1)]
    }
    set {
      self[position == 0 ? .head : .tail(position - 1)] = newValue
    }
  }
}

zs[0] = 42
zs[1] = 1000
zs[2] = 19
zs

let set = Set([1, 1, 2, 3])
set.count

extension NonEmpty where C: SetAlgebra {
  init(_ head: C.Element, _ tail: C) {
    var tail = tail
    tail.remove(head)
    self.head = head
    self.tail = tail
  }
  init(_ head: C.Element, _ tail: C.Element...) {
    var tail = C(tail)
    tail.remove(head)
    self.head = head
    self.tail = tail
  }
}

let nonEmptySet = NonEmpty<Set<Int>>(1, 1, 2, 3)
nonEmptySet.count

Set([1, 2, 3])

typealias NonEmptySet<A> = NonEmpty<Set<A>> where A: Hashable
typealias _NonEmptyArray<A> = NonEmpty<[A]>

NonEmptySet(1, 1, 2, 3)
_NonEmptyArray(1, 1, 2, 3)

extension NonEmpty where C: RangeReplaceableCollection {
  mutating func append(_ newElement: C.Element) {
    self.tail.append(newElement)
  }
}

extension Sequence {
  func groupBy<A>(_ f: (Element) -> A) -> [A: NonEmpty<[Element]>] {
    var result: [A: NonEmpty<[Element]>] = [:]
    for element in self {
      let key = f(element)
      if result[key] == nil {
        result[key] = NonEmpty(element)
      } else {
        result[key]?.append(element)
      }
    }
    return result
  }
}

Array(1...10)
  .groupBy { $0 % 3 }
  .debugDescription

"Mississippi"
  .groupBy { $0 }

[1, 2, 3].randomElement()

NonEmpty<[Int]>(1, 2, 3)

extension NonEmpty {
  func safeRandomElement() -> C.Element {
    return self.randomElement() ?? self.head
  }
}

NonEmpty<[Int]>(1, 2, 3).safeRandomElement() + 1

// { email name }
// {}


enum UserField: String {
  case id
  case name
  case email
}

func query(_ fields: NonEmptySet<UserField>) -> String {
  return (["{\n"] + fields.map { "  \($0.rawValue)\n" } + ["}\n"])
    .joined()
}

print(query(.init(.email, .name)))

enum Result<Value, Error> {
  case success(Value)
  case failure(Error)
}

enum Validated<Value, Error> {
  case valid(Value)
  case invalid(NonEmpty<[Error]>)
}

//let validatedPassword = Validated<String, String>.valid("blobisawesome")

let validatedPassword = Validated<String, String>.invalid(.init("Too short", "Didn't contain any numbers"))

//let validatedPassword = Validated<String, String>.invalid([])


// MARK: - Homework

// #1. Why shouldn’t NonEmpty conditionally conform to SetAlgebra when its underlying collection type also conforms to SetAlgebra?

/*
 - It has an empty initializer
 - It has methods which can return an empty collection (e.g. intersection, symmetricDifference etc)
 - It has methods for removel of elements which can lead to the empty collection
 */

// #2.
extension NonEmpty where C: SetAlgebra {
  func contains(_ member: C.Element) -> Bool {
    var set = self.tail
    set.insert(self.head)
    return set.contains(member)
  }
}

// #3.
extension NonEmpty where C: SetAlgebra {
  func union(_ other: NonEmpty) -> NonEmpty {
    var lhs = self.tail
    lhs.insert(self.head)
    var rhs = other.tail
    rhs.insert(other.head)

    var set = lhs.union(rhs)

    guard let head = set.first else { fatalError("not possible") }

    set.remove(head)
    return NonEmpty(head, set)
  }
}

NonEmptySet(1, 2, 3).union(NonEmptySet(3, 2, 1)).count == 3

// #4.
protocol DictionaryProtocol: Collection where Element == (key: Key, value: Value) {
  associatedtype Key: Hashable
  associatedtype Value

  var keys: Dictionary<Key, Value>.Keys { get }

  mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
  mutating func merge(_ other: [Key: Value], uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows

  subscript(key: Key) -> Value? { get }
}

extension Dictionary: DictionaryProtocol {}

extension NonEmpty where C: DictionaryProtocol {
  subscript(key: C.Key) -> C.Value? {
    return self.head.key == key ? self.head.value : self.tail[key]
  }
}

NonEmpty<[Int: Int]>((1, 1), [2: 2, 3: 3])[3]

// #5.
extension NonEmpty where C: DictionaryProtocol {
  init(_ head: C.Element, _ tail: C) {
    guard !tail.keys.contains(head.key) else {
      fatalError("Tail contains the same key as the head.")
    }

    self.head = head
    self.tail = tail
  }
}

// #6.
extension NonEmpty where C: DictionaryProtocol {
  mutating func update(_ value: C.Value, forKey key: C.Key) -> C.Value? {
    if head.key == key {
      let oldValue = head.value
      self.head.value = value
      return oldValue
    } else {
      return self.tail.updateValue(value, forKey: key)
    }
  }
}

var emptyDictionaty6 = NonEmpty<[Int: Int]>((1, 1), [2: 2, 3: 3])
emptyDictionaty6.tail[1] = 5
emptyDictionaty6

// #7.
extension NonEmpty where C: DictionaryProtocol {
  mutating func merge(_ other: [C.Key: C.Value], uniquingKeysWith combine: (C.Value, C.Value) throws -> C.Value) rethrows {
    var other = other

    if let newValue = other.removeValue(forKey: self.head.key) {
      self.head.value = try combine(self.head.value, newValue)
    }

    try self.tail.merge(other, uniquingKeysWith: combine)
  }

  func merging(_ other: [C.Key: C.Value], uniquingKeysWith combine: (C.Value, C.Value) throws -> C.Value) rethrows -> NonEmpty {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }
}

// #8.
extension NonEmpty {
  func joined<Separator: Sequence, T: RangeReplaceableCollection>(separator: Separator) -> NonEmpty<T> where Element == NonEmpty<T>, Separator.Element == T.Element {
    let head = self.head.head
    let tail = self.head.tail + T(separator) + T(self.tail.joined(separator: separator))

    return NonEmpty<T>(head, tail)
  }
}

// #9.Ø

// #10.
// Both wrapped collection and it's element type should be equatable
extension NonEmpty: Equatable where C: Equatable, C.Element: Equatable {
  static func == (lhs: NonEmpty, rhs: NonEmpty) -> Bool {
    return lhs.head == rhs.head && lhs.tail == rhs.tail
  }
}

// #11.
extension NonEmpty {
  static func zip<A, B>(_ a: NonEmpty<[A]>, _ b: NonEmpty<[B]>) -> NonEmpty<[(A, B)]> {
    let head = (a.head, b.head)
    let tail = Array(Swift.zip(a.tail, b.tail))
    return NonEmpty<[(A, B)]>(head, tail)
  }
}

func zip<A, B>(_ a: NonEmpty<[A]>, _ b: NonEmpty<[B]>) -> NonEmpty<[(A, B)]> {
  let head = (a.head, b.head)
  let tail = Array(zip(a.tail, b.tail))
  return NonEmpty<[(A, B)]>(head, tail)
}


