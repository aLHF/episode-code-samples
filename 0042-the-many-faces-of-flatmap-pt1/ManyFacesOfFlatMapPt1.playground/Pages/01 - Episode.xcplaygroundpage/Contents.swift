import Foundation

func combos<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
//  var result: [(A, B)] = []
//  xs.forEach { x in
//    ys.forEach { y in
//      result.append((x, y))
//    }
//  }
//  return result

  return xs.flatMap { x in
    ys.map { y in
      (x, y)
    }
  }

//  return Array(zip(xs, ys))
}

combos([1, 2, 3], ["a", "b"])
// [(1, "a"), (1, "b"), (2, "a"), (2, "b"), (3, "a"), (3, "b")]


let scores = """
1,2,3,4
5,6
7,8,9
"""

var allScores: [Int] = []
scores.split(separator: "\n").forEach { line in
  line.split(separator: "," ).forEach { value in
    allScores.append(Int(value) ?? 0)
  }
}
allScores

scores.split(separator: "\n").map { line in
  line.split(separator: "," ).map { value in
    Int(value) ?? 0
  }
}

scores.split(separator: "\n").flatMap { line in
  line.split(separator: "," ).map { value in
    Int(value) ?? 0
  }
}


//extension Optional {
//  public func flatMap<U>(_ transform: (Wrapped) throws -> U?) rethrows -> U?
//}


let strings = ["42", "Blob", "functions"]

strings.first
type(of: strings.first)

strings.first.map(Int.init)
type(of: strings.first.map(Int.init))

strings.first.flatMap(Int.init)
type(of: strings.first.flatMap(Int.init))

// ((A) -> B) -> (A?) -> B?
// Int.init: (String) -> Int?
// A = String
// B = Int?
// ((String) -> Int?) -> (String?) -> Int??


if let x = strings.first.map(Int.init), let y = x {
  type(of: y)
}

if case let .some(.some(x)) = strings.first.map(Int.init) {
  type(of: x)
}
if case let x?? = strings.first.map(Int.init) {
  type(of: x)
}

switch strings.first.map(Int.init) {
case let .some(.some(value)):
  print(value)
case .some(.none):
  print(".some(.none)")
case .none:
  print(".none")
}


enum Result<A, E> {
  case success(A)
  case failure(E)

  func map<B>(_ f: @escaping (A) -> B) -> Result<B, E> {
    switch self {
    case let .success(a):
      return .success(f(a))
    case let .failure(e):
      return .failure(e)
    }
  }

  func flatMap<B>(_ f: @escaping (A) -> Result<B, E>) -> Result<B, E> {
    switch self {
    case .success(let value):
      return f(value)

    case .failure(let error):
      return .failure(error)
    }
  }
}

Result<Double, String>.success(42.0)
  .map { $0 + 1 }

func compute(_ a: Double, _ b: Double) -> Result<Double, String> {
  guard a >= 0 else { return .failure("First argument must be non-negative.") }
  guard b != 0 else { return .failure("Second argument must be non-zero.") }
  return .success(sqrt(a) / b)
}

compute(-1, 1729)
compute(42, 0)
print(type(of:
  compute(42, 1729)
    .map { compute($0, $0) }
  ))


switch compute(42, 1729).map({ compute($0, $0) }) {
case let .success(.success(value)):
  print(value)
case let .success(.failure(error)):
  print(error)
case let .failure(error):
  print(error)
}


import NonEmpty

enum Validated<A, E> {
  case valid(A)
  case invalid(NonEmptyArray<E>)

  func map<B>(_ f: @escaping (A) -> B) -> Validated<B, E> {
    switch self {
    case let .valid(a):
      return .valid(f(a))
    case let .invalid(e):
      return .invalid(e)
    }
  }

  func flatMap<B>(_ f: @escaping (A) -> Validated<B, E>) -> Validated<B, E> {
    switch self {
    case .valid(let a):
      return f(a)

    case .invalid(let e):
      return .invalid(e)
    }
  }
}

struct Func<A, B> {
  let run: (A) -> B

  func map<C>(_ f: @escaping (B) -> C) -> Func<A, C> {
//    return Func<A, C> { a in
//      f(self.run(a))
//    }
    return Func<A, C>(run: self.run >>> f)
  }
}

// >>>


let randomNumber = Func<Void, Int> {
  let number = try! String(contentsOf: URL(string: "https://www.random.org/integers/?num=1&min=1&max=235866&col=1&base=10&format=plain&rnd=new")!)
    .trimmingCharacters(in: .newlines)
  return Int(number)!
}

randomNumber.map { $0 + 1 }
randomNumber
  .map { $0 + 1 }
  .run(())


let words = Func<Void, [String]> {
  (try! String(contentsOf: URL(fileURLWithPath: "/usr/share/dict/words")))
    .split(separator: "\n")
    .map(String.init)
}
//
//words
//words
//  .run(())
//
//randomNumber.map { number in
//  words.map { words in
//    words[number]
//  }
//}
//
//randomNumber.map { number in
//  words.map { words in
//    words[number]
//  }
//}.run(()).run(())


struct Parallel<A> {
  let run: (@escaping (A) -> Void) -> Void

  func map<B>(_ f: @escaping (A) -> B) -> Parallel<B> {
    return Parallel<B> { callback in
      self.run { a in callback(f(a)) }
    }
  }
}


func delay(by duration: TimeInterval, line: UInt = #line) -> Parallel<Void> {
  return Parallel { callback in
    print("Delaying line \(line) by \(duration)")
    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
      callback(())
      print("Executed line \(line)")
    }
  }
}

//
//delay(by: 1).run { print("Executed after 1 second") }
//delay(by: 2).run { print("Executed after 2 seconds") }
//
//let aDelayedInt = delay(by: 3).map { 42 }
//aDelayedInt.run { value in print("We got \(value)") }
//
//aDelayedInt.map { value in
//  delay(by: 1).map { value + 1729 }
//}
//
//aDelayedInt.map { value in
//  delay(by: 1).map { value + 1729 }
//  }.run { innerParallel in
//    innerParallel.run { value in
//      print("We got \(value)")
//    }
//}


// extension Sequence {
//   public func flatMap<SegmentOfResult>(
//     _ transform: (Self.Element) throws -> SegmentOfResult
//   ) rethrows -> [SegmentOfResult.Element]
//   where SegmentOfResult : Sequence {
//   }
// }


/*:
 1. In this episode we saw that the combos function on arrays can be implemented in terms of flatMap and map. The zip function on arrays as the same signature as combos. Can zip be implemented in terms of flatMap and map?
 */
func zip1<A, B>(_ a: [A], _ b: [B]) -> [(A, B)] {
//  return a.flatMap {  }

  fatalError()
}

// Impossible

/*:
 2. Define a flatMap method on the Result<A, E> type. Its signature looks like:

 (Result<A, E>, (A) -> Result<B, E>) -> Result<B, E>
 It only changes the A generic while leaving the E fixed.
 */
func flatMapResult<A, B, E>(_ a: Result<A, E>, _ b: (A) -> Result<B, E>) -> Result<B, E> {
  switch a {
  case .success(let value):
    return b(value)

  case .failure(let error):
    return .failure(error)
  }
}

let result1: Result<Int, Error> = Result.success(2)
let result2 = flatMapResult(result1) { (value) -> Result<String, Error> in
  return Result.success(String(value))
}

/*:
 3. Can the zip function we defined on Result<A, E> in episode #24 be implemented in terms of the flatMap you implemented above? If so do it, otherwise explain what goes wrong.
 */
//func zip2<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
//  switch (a, b) {
//  case let (.success(a), .success(b)):
//    return .success((a, b))
//  case let (.success, .failure(e)):
//    return .failure(e)
//  case let (.failure(e), .success):
//    return .failure(e)
//  case let (.failure(e1), .failure(e2)):
//    ???
//  }
//}

func zip2<A, B, E>(_ a: Result<A, E>, _ b: Result<B, E>) -> Result<(A, B), E> {
  return a.flatMap { a in b.map { b in return Result<(A, B), E>.success((a, b)) } }
}

/*:
 4. Define a flatMap method on the Validated<A, E> type. Its signature looks like:

 (Validated<A, E>, (A) -> Validated<B, E>) -> Validated<B, E>
 It only changes the A generic while leaving the E fixed. How similar is it to the flatMap you defined on Result?
 */
func flatMap<A, B, E>(_ a: Validated<A, E>, _ b: (A) -> Validated<B, E>) -> Validated<B, E> {
  switch a {
  case .valid(let a):
    return b(a)

  case .invalid(let e):
    return .invalid(e)
  }
}

/*:
 5. Can the zip function we defined on Validated<A, E> in episode #24 be defined in terms of the flatMap above? If so do it, otherwise explain what goes wrong.
 */
//func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
//  switch (a, b) {
//  case let (.valid(a), .valid(b)):
//    return .valid((a, b))
//  case let (.valid, .invalid(e)):
//    return .invalid(e)
//  case let (.invalid(e), .valid):
//    return .invalid(e)
//  case let (.invalid(e1), .invalid(e2)):
//    //    return .failure(e1)
//    return . invalid(e2)
//  }
//}

func zip2<A, B, E>(_ a: Validated<A, E>, _ b: Validated<B, E>) -> Validated<(A, B), E> {
  return a.flatMap { a in b.flatMap { b in Validated.valid((a, b)) } }
}

/*:
 6. Define a flatMap method on the Func<A, B> type. Its signature looks like:

 (Func<A, B>, (B) -> Func<A, C>) -> Func<A, C>
 It only changes the B generic while leaving the A fixed.
 */
func flatMap<A, B, C>(_ a: Func<A, B>, _ b: @escaping (B) -> Func<A, C>) -> Func<A, C> {
  return Func<A, C> { inner in
    let bValue = a.run(inner)
    let funcAC = b(bValue)
    return funcAC.run(inner)
  }
}

/*:
 7. Can the zip function we defined on Func<A, B> in episode #24 be implemented in terms of the flatMap you implemented above? If so do it, otherwise explain what goes wrong.
 */

//func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
//  return Func<R, (A, B)> { r in
//    (r2a.apply(r), r2b.apply(r))
//  }
//}

func zip2<A, B, R>(_ r2a: Func<R, A>, _ r2b: Func<R, B>) -> Func<R, (A, B)> {
  return flatMap(r2a, { a -> Func<A, C> in
    return r2b.map { b in (a, b) }
  })
}


/*:
 8. Define a flatMap method on the Parallel<A> type. Its signature looks like:

 (Parallel<A>, (A) -> Parallel<B>) -> Parallel<B>
 */
func flatMap<A,B>(_ a: Parallel<A>, _ b: @escaping (A) -> Parallel<B>) -> Parallel<B> {
  return Parallel<B> { callback in
    a.run { a in
      let parB = b(a)
      parB.run { b in callback(b) }
    }
  }
}
