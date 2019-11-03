
[1, 2, 3]
  .map { $0 + 1 }
[1, 2, 3]
  .map(incr)

func map<A, B>(_ transform: @escaping (A) -> B) -> ([A]) -> [B] {
  return { xs in
    var result = [B]()
    result.reserveCapacity(xs.count)
    xs.forEach { result.append(transform($0)) }
    return result
  }
}

[1, 2, 3] |> map(incr)
[1, 2, 3] |> map(incr) |> map(square)
[1, 2, 3] |> map(incr >>> square)

Int?.some(2).map(incr)
Int?.none.map(incr)

func map<A, B>(_ transform: @escaping (A) -> B) -> (A?) -> B? {
  return { value in
    switch value {
    case .some(let value):
      return .some(transform(value))

    case .none:
      return .none
    }
  }
}

Int?.none |> map(incr)
Int?.some(2) |> map(incr)
Int?.some(2) |> map(incr >>> square)

[1, 2, 3]
  .map { $0 }

Int?.some(2)
  .map { $0 }

func identity<A>(_ a: A) -> A {
  return a
}

[1, 2, 3]
  .map(identity)

Int?.some(2)
  .map(identity)

[1, 2, nil, nil, 5, nil, 7].compactMap(identity)

// map(identity) = identity
[1, 2, 3].map(identity) == identity([1, 2, 3])
Int?.some(2).map(identity) == identity(Int?.some(2))

// f >>> id = f
// id >>> f = f

func lift<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { xs in
//    return []
//    return (xs + xs).map(f)
//    return (xs + xs + xs).map(f)
//    return xs.reversed().map(f)
//    return Array(xs.prefix(1)).map(f)
//    return Array(xs.prefix(2)).map(f)
//    return Array(xs.suffix(1)).map(f)
//    return Array(xs.suffix(2)).map(f)

    return (xs.map(f) + xs.map(f))
    return (xs.map(f) + xs.map(f) + xs.map(f))
    return xs.map(f).reversed()
    return Array(xs.map(f).prefix(1))
    return Array(xs.map(f).prefix(2))
    return Array(xs.map(f).suffix(1))
    return Array(xs.map(f).suffix(2))
  }
}

// if f,g are functions
// lift(f) >>> map(g) == map(f) >>> lift(g)

let xs = [1, 2, 3, 4]
let f = incr
let g = { (x: Int) in String(x) }

let lhs = lift(f) >>> map(g)
let rhs = map(f) >>> lift(g)
lhs(xs)
rhs(xs)
lhs(xs) == rhs(xs)

// Suppose lift(identity) = identity
// If f = identity, g is any function
// lift(identity) >> map(g) == map(identity) >>> lift(g)
// identity >>> map(g) == identity >>> lift(g)
// map(g) == lift(g)

func r<A>(_ xs: [A]) -> A? {
  fatalError()
}

enum Result<A, E> {
  case success(A)
  case failure(E)
}

func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
  return { result in
    switch result {
    case .success(let a):
      return .success(f(a))
    case .failure(let e):
      return .failure(e)
    }
  }
}

Result<Int, String>.success(42)
  |> map(incr)
Result<Int, String>.failure("Error")
  |> map(incr)

struct F1<A> {
  let value: A
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F1<A>) -> F1<B> {
  return { f1 in
    return F1(value: f(f1.value))
  }
}

// map(identity) = identity

//return { f1 in
//  F1(value: id(f1.value))
//}

//return { f1 in
//  F1(value: f1.value)
//}

//return { f1 in
//  f1
//}

// return { $0 }

struct F2<A, B> {
  let apply: (A) -> B
}


func map<A, B, C>(_ f: @escaping (B) -> C) -> (F2<A, B>) -> F2<A, C> {
  return { f2 in
//    return F2 { a in
//      f(f2.apply(a))
//    }
    return F2(apply: f2.apply >>> f)
  }
}

// map(id) == id

//{ f2 in
//  return F2(apply: f2.apply >>> id)
//}

//{ f2 in
//  return F2(apply: f2.apply)
//}

//{ f2 in
//  return f2
//}

//{ $0 }


struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}


//URLSession.shared.dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>) -> Void

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
  return { f3 in
    F3 { callback in
//      f3.run // ((A) -> Void) -> Void
//      callback // (B) -> Void
//      f // (A) -> B
//      f >>> callback // (A) -> Void
      f3.run(f >>> callback)
    }
  }
}

// map(id) == id

//return { f3 in
//  F3 { callback in
//    f3.run(id >>> callback)
//  }
//}

//return { f3 in
//  F3 { callback in
//    f3.run(callback)
//  }
//}

//return { f3 in
//  F3(run: f3.run)
//}

//return { f3 in
//  f3
//}

//return { $0 }


// func map   <A, B>(_ f: (A) -> B) -> (F1   <A>) -> F1   <B>
// func map<R, A, B>(_ f: (A) -> B) -> (F2<R, A>) -> F2<R, B>
// func map   <A, B>(_ f: (A) -> B) -> (F3   <A>) -> F3   <B>
//: [See the next page](@next) for exercises!
