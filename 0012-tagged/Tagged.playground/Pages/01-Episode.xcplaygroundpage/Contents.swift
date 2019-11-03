import Foundation

let usersJson = """
[
{
"id": 1,
"name": "Brandon",
"email": "brandon@pointfree.co",
"subscriptionId": 1
},
{
"id": 2,
"name": "Stephen",
"email": "stephen@pointfree.co",
"subscriptionId": null
},
{
"id": 3,
"name": "Blob",
"email": "blob@pointfree.co",
"subscriptionId": 1
}
]
"""

let subscriptionsJson = """
[
  {
    "id": 1,
    "ownerId": 1
  }
]
"""

struct Tagged<Tag, RawValue> {
  let rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {
  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.init(rawValue: try container.decode(RawValue.self))
  }
}

extension Tagged: Equatable where RawValue: Equatable {
  static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
    return lhs.rawValue == rhs.rawValue
  }
}

enum EmailTag {}
typealias Email = Tagged<EmailTag, String>
// newtype Email = String

struct User: Decodable {
  typealias ID = Tagged<User, Int>

  let id: ID
  let name: String
  let email: Email
  let subscriptionId: Subscription.ID?
}

struct Subscription: Decodable {
  typealias ID = Tagged<Subscription, Int>

  let id: ID
  let ownerId: User.ID
}

let decoder = JSONDecoder()
let users = try! decoder.decode([User].self, from: Data(usersJson.utf8))
let subscriptions = try! decoder.decode([Subscription].self, from: Data(subscriptionsJson.utf8))

func sendEmai(email: Email) {
  //
}

let user = users[0]
sendEmai(email: user.email)
//sendEmai(email: user.name)

// RawRepresentable

enum Status: Int {
  case ok = 200
  case notFound = 404
}

Status.ok.rawValue
Status.init(rawValue: 200)
Status.init(rawValue: 201)

subscriptions
  .first(where: { $0.id == user.subscriptionId })
//subscriptions
//  .first(where: { $0.id == user.id })

User(
  id: .init(rawValue: 1),
  name: "Jack",
  email: .init(rawValue: "jack85@gmai.com"),
  subscriptionId: .init(rawValue: 2)
)

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
  typealias IntegerLiteralType = RawValue.IntegerLiteralType

  init(integerLiteral value: RawValue.IntegerLiteralType) {
    self.init(rawValue: RawValue(integerLiteral: value))
  }
}

User(
  id: 1,
  name: "Jack",
  email: .init(rawValue: "jack85@gmai.com"),
  subscriptionId: 2
)

//extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
//
//  init(integerLiteral value: RawValue.IntegerLiteralType) {
//    self.init(rawValue: RawValue(integerLiteral: value))
//  }
//
//  typealias IntegerLiteralType = RawValue.IntegerLiteralType
//
//
//}
//
//User(
//  id: 1,
//  name: "Blob",
//  email: .init(rawValue: "blob@pointfree.co"),
//  subscriptionId: .init(rawValue: 2)
//)
//: [See the next page](@next) for exercises!
