/*:
 # A Tale of Two Flat-Maps, Exercises

 1. Define `filtered` as a function from `[A?]` to `[A]`.
 */
func filtered<A>(_ array: [A?]) -> [A] {
  var result: [A] = []
  result.reserveCapacity(array.count)

  for value in array {
    switch value {
    case .some(let value): result.append(value)
    case .none: continue
    }
  }

  return result
}

let test1 = [1, nil, 3, nil, nil, 6]
filtered(test1)
/*:
 2. Define `partitioned` as a function from `[Either<A, B>]` to `(left: [A], right: [B])`. What does this function have in common with `filtered`?
 */
func partioned<A, B>(_ array: [Either<A, B>]) -> (lefts: [A], rights: [B]) {
  var result = (lefts: [A](), rights: [B]())

  for value in array {
    switch value {
    case .left(let value): result.lefts.append(value)
    case .right(let value): result.rights.append(value)
    }
  }

  return result
}

let test2: [Either<Int, Int>] = [.left(1), .left(2), .right(3), .left(4), .right(5), .left(6)]
partioned(test2)
/*:
 3. Define `partitionMap` on `Optional`.
 */

extension Optional {
  func partitionMap<A, B>(_ p: (Wrapped) -> Either<A, B>) -> Either<A, B>? {
    switch self {
    case .some(let value): return p(value)
    case .none: return nil
    }
  }
}

let test3 = Int("10").partitionMap { value -> Either<Int, String> in return .left(value) }
/*:
 4. Dictionary has `mapValues`, which takes a transform function from `(Value) -> B` to produce a new dictionary of type `[Key: B]`. Define `filterMapValues` on `Dictionary`.
 */
extension Dictionary {
  func filterMapValue<A>(_ transform: (Value) -> A?) -> [Key: A] {
    var result: [Key: A] = [:]

    for item in self {
      switch transform(item.value) {
      case .some(let value): result[item.key] = value
      case .none: continue
      }
    }

    return result
  }

  func filterMapValue<A>(_ transform: (Value) -> A?) -> [A] {
    var result: [A] = []

    for value in values {
      switch transform(value) {
      case .some(let value):
        result.append(value)

      case .none:
        continue
      }
    }

    return result
  }
}

let test4 = [1: 1, 2: 2, 3: 3, 4: 4, 5: 5]
let check41: [Int: Int] = test4.filterMapValue { $0 % 2 != 0 ? $0 : nil }
let check42: [Int] = test4.filterMapValue { $0 % 2 != 0 ? $0 : nil }
/*:
 5. Define `partitionMapValues` on `Dictionary`.
 */
extension Dictionary {
  func partitionMapValues<A, B>(_ p: (Value) -> Either<A, B>) -> (lefts: [A], rights: [B]) {
    var result = (lefts: [A](), rights: [B]())

    for value in values {
      switch p(value) {
      case .left(let value):
        result.lefts.append(value)

      case .right(let value):
        result.rights.append(value)
      }
    }

    return result
  }
}



// MARK: - #6. Rewrite filterMap and filter in terms of partitionMap

extension Sequence {
  func partionMap<A, B>(_ p: @escaping (Element) -> Either<A, B>) -> (lefts: [A], rights: [B]) {
    var result = (lefts: [A](), rights: [B]())

    for value in self {
      switch p(value) {
      case .left(let value):
        result.lefts.append(value)

      case .right(let value):
        result.rights.append(value)
      }
    }

    return result
  }
}

func partionMap<A, B, C>(_ p: @escaping (A) -> Either<B, C>) -> ([A]) -> (lefts: [B], rights: [C]) {
  return { $0.partionMap(p) }
}

func partitionFilter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> [A] {
  return { $0.partionMap { p($0) ? .left($0) : .right($0) }.lefts }
}

[1, 2, 3, 4, 5, 6, 7] |> partitionFilter { $0 > 5 }

func partitionFilterMap<A, B>(_ p: @escaping (A) -> B?) -> ([A]) -> [B] {
  return { array in
    return array.partionMap { value -> Either<B, B?> in
      switch p(value) {
      case .some(let value):
        return .left(value)

      case .none:
        return .right(nil)
      }
    }.lefts
  }
}


// MARK: - #6. Is it possible to define partitionMap of Either


// (Either<A, B>) -> Either<C, D>)
// ((A) -> Either<C, D>, B -> Either<E, F>) -> Either<Either<C, D>, Either<E, F>  ???
//
//extension Either {
//  func partitionMap<A, B>(_ p: (Wrapped) -> Either<A, B>) -> Either<A, B>? {
//    switch self {
//    case .some(let value): return p(value)
//    case .none: return nil
//    }
//  }
//}
