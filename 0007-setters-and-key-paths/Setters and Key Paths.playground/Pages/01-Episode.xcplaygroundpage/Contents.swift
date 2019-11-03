import Foundation

struct Food {
  var name: String
}

struct Location {
  var name: String
}

struct User {
  var favoriteFoods: [Food]
  var location: Location
  var name: String
}

let user = User(
  favoriteFoods: [Food(name: "tacos"), Food(name: "tacos")],
  location: Location(name: "Brooklyn"),
  name: "John"
)

User(
  favoriteFoods: user.favoriteFoods,
  location: Location(name: "Chicago"),
  name: user.name
)

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
  return { pair in
    return (f(pair.0), pair.1)
  }
}

let check = prop(\User.favoriteFoods) <<< map <<< prop(\Food.name)

let guaranteeHeaders = (prop(\URLRequest.allHTTPHeaderFields)) { $0 ?? [:] }
let postJSON = (prop(\URLRequest.allHTTPHeaderFields) <<< map <<< prop(\.["Content-Type"])) { _ in "application/json; charset=utf-8" }


let healthier = (prop(\User.favoriteFoods) <<< map <<< prop(\.name)){ $0 + " & Salad" }
dump(
  (1, user) |> second(healthier)
)
