
struct User {
  let id: Int
  let email: String
}

let user = User(id: 1, email: "mail@gmail.com")
user.id
user.email

let getID = { (user: User) in user.id }

user[keyPath: \User.email]

func get<Root, Value>(_ keyPath: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in
    return root[keyPath: keyPath]
  }
}

get(\User.id) >>> String.init // (User) -> String

extension User {
  var isStaff: Bool {
    return email.hasSuffix("@uptech.team")
  }
}

user.isStaff
get(\User.isStaff)

let users = [
  User(id: 1, email: "blob@pointfree.co"),
  User(id: 2, email: "protocol.me.maybe@appleco.example"),
  User(id: 3, email: "bee@co.domain"),
  User(id: 4, email: "a.morphism@category.theory")
]

extension Sequence {
  func map<Value>(_ keyPath: KeyPath<Element, Value>) -> [Value] {
    return self.map { $0[keyPath: keyPath] }
  }
}

users.map(\.id)

users
  .map(get(\.id))

users
  .filter(get(\.isStaff))

users
  .map(get(\.email))
  .map(get(\.count))

users
  .map(get(\.email) >>> get(\.count))

users
  .map(get(\.email.count))

users
  .filter(get(\.isStaff) >>> (!))

users
  .filter((!) <<< get(\.isStaff))

users
  .sorted(by: { $0.id < $1.id })

////users.sorted(by: <#T##(User, User) throws -> Bool#>)

func their<Root, Value>(_ f: @escaping (Root) -> Value, _ g: @escaping (Value, Value) -> Bool) -> (Root, Root) -> Bool {

  return { lhs, rhs in
    return g(f(lhs), f(rhs))
  }
}

users
  .sorted(by: their(get(\.id), >))

users
  .max(by: their(get(\.id), <))?.id

func their<Root, Value: Comparable>(_ f: @escaping (Root) -> Value) -> (Root, Root) -> Bool {

  return their(f, <)
}

users
  .max(by: their(get(\.id)))?.id

[1, 2, 3]
  .reduce(0, +)

struct Episode {
  let title: String
  let viewCount: Int
}

let episodes = [
  Episode(title: "Functions", viewCount: 961),
  Episode(title: "Side Effects", viewCount: 841),
  Episode(title: "UIKit Styling with Functions", viewCount: 1089),
  Episode(title: "Algebraic Data Types", viewCount: 729),
]

episodes
  .reduce(0) { $0 + $1.viewCount }

//episodes.reduce(<#T##initialResult: Result##Result#>, <#T##nextPartialResult: (Result, Episode) throws -> Result##(Result, Episode) throws -> Result#>)

func combining<Root, Value>(
  _ f: @escaping (Root) -> Value,
  by g: @escaping (Value, Value) -> Value
  )
  -> (Value, Root)
  -> Value {

    return { (value, root) in
      return g(value, f(root))
    }
}

episodes.reduce(0, combining(get(\.viewCount), by: +))

prefix operator ^
prefix func ^ <Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
  return { $0[keyPath: kp] }
}

^\User.id
users.map(^\.email)
users.map(^\.email.count)
users.map(^\.email.count >>> String.init)
users.sorted(by: their(^\.id))
//: [See the next page](@next) for exercises!
