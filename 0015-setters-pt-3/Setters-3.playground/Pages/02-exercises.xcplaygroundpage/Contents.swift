import Foundation
import UIKit

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
  var birthdate: String?
}

let user = User(
  favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
  location: Location(name: "Brooklyn"),
  name: "Blob",
  birthdate: nil
)

func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root) -> Root {

    return { update in
      { root in
        var copy = root
        copy[keyPath: kp] = update(copy[keyPath: kp])
        return copy
      }
    }
}

typealias Setter<S, T, A, B> = (@escaping (A) -> B) -> (S) -> T

func over<S, T, A, B>(_ setter: Setter<S, T, A, B>, _ f: @escaping (A) -> B) -> (S) -> T {
  return setter(f)
}

func set<S, T, A, B>(_ setter: Setter<S, T, A, B>, _ value: B) -> (S) -> T {
  return setter { _ in value }
}

prefix func ^ <Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root) -> Root {

    return prop(kp)
}

typealias MutableSetter<S, A> = (@escaping (inout A) -> Void) -> (inout S) -> Void

func mver<S, A>(
  _ setter: MutableSetter<S, A>,
  _ set: @escaping (inout A) -> Void
  ) -> (inout S) -> Void {

  return setter(set)
}

func mut<S, A>(
  _ setter: MutableSetter<S, A>,
  _ value: A
  ) -> (inout S) -> Void {

  return setter { $0 = value }
}

//prefix func ^ <Root, Value>(_ kp: WritableKeyPath<Root, Value>)
//  -> (@escaping (inout Value) -> Void)
//  -> (inout Root) -> Void {
//
//    return { update in
//      return { root in
//        update(&root[keyPath: kp])
//      }
//    }
//}

func |> <A>(_ a: A, _ f: (inout A) -> Void) -> A {
  var a = a
  f(&a)
  return a
}

func mutEach<A>(_ f: @escaping (inout A) -> Void) -> (inout [A]) -> Void {
  return {
    for index in $0.indices {
      f(&$0[index])
    }
  }
}

/*:
 # Setters: Ergonomics & Performance Exercises

 1.) We previously saw that functions `(inout A) -> Void` and functions `(A) -> Void where A: AnyObject` can be composed the same way. Write `mver`, `mut`, and `^` in terms of `AnyObject`. Note that there is a specific subclass of `WritableKeyPath` for reference semantics.
 */

typealias ObjectSetter<S: AnyObject, A> = (@escaping (inout A) -> Void) -> (S) -> Void

func mver<S: AnyObject, A>(
  _ setter: ObjectSetter<S, A>,
  _ set: @escaping (inout A) -> Void
  ) -> (S) -> Void {
  return setter(set)
}

func mut<S: AnyObject, A>(
  _ setter: ObjectSetter<S, A>,
  _ value: A
  ) -> (S) -> Void {
  return setter { $0 = value }
}

prefix func ^ <Root: AnyObject, Value>(_ kp: ReferenceWritableKeyPath<Root, Value>)
  -> (@escaping (inout Value) -> Void)
  -> (Root) -> Void {
    return { update in
      return { root in
        update(&root[keyPath: kp])
      }
    }
}

func |> <A: AnyObject>(_ value: A, _ f: (A) -> Void) -> A {
  f(value)
  return value
}



/*:
 2.) Our [episode on UIKit styling](/episodes/ep3-uikit-styling-with-functions) was nothing more than setters in disguise! Explore building some of the styling functions we covered using both immutable and mutable setters, specifically how setters compose over sub-typing in Swift, and how setters compose between roots that are reference types, and values that are value types.
 */

let baseButtonStyle: (UIButton) -> UIButton =
  set(^\UIButton.contentEdgeInsets, UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    <> set(^\UIButton.tintColor, .orange)
    <> set(^\UIButton.backgroundColor, .white)

let roundedStyle: (UIView) -> UIView =
  set(^\UIView.layer.cornerRadius, 5)
    <> set(^\UIView.clipsToBounds, true)

let roundedButtonStyle = baseButtonStyle >>> roundedStyle

func <> <A: AnyObject>(_ f: @escaping (A) -> Void, _ g: @escaping (A) -> Void) -> (A) -> Void {
  return { a in
    f(a)
    g(a)
  }
}

//let baseButtonStyle1: (UIButton) -> Void =
//  set(^\UIButton.contentEdgeInsets, UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
//    <> set(^\UIButton.tintColor, .orange)
//    <> set(^\UIButton.backgroundColor, .white)
//
//let roundedStyle1: (UIView) -> Void =
//  set(^\UIView.layer.cornerRadius, 5)
//    <> set(^\UIView.clipsToBounds, true)
//
//let roundedButtonStyle1 = baseButtonStyle1 <> roundedStyle1

let button = UIButton()
let roundedButton = button |> roundedButtonStyle
roundedButton.layer.cornerRadius
roundedButton.backgroundColor
roundedButton.tintColor


/*:
 3.) We've explored `<>`/`concat` as single-type composition, but this doesn't mean we're limited to a single generic parameter! Write a version of `<>`/`concat` that allows for composition of value transformations of the same input and output type. This should allow for `prop(\\UIEdgeInsets.top) <> prop(\\.bottom)` as a way of assigning both `top` and `bottom` the same value at once.
 */

let top = ^\UIEdgeInsets.top
let bottom = ^\UIEdgeInsets.bottom

func <> <A, B, S>(
  _ f: @escaping (@escaping (A) -> B) -> (S) -> S,
  _ g: @escaping (@escaping (A) -> B) -> (S) -> S
  ) -> (@escaping (A) -> B) -> (S) -> S {

  return { transform in f(transform) <> g(transform) }
}

let tab = top <> bottom
let insets = UIEdgeInsets.zero |> set(tab, 10)
print("insets: \(insets)")


/*:
 4.) Define an operator-free version of setters using `with` and `concat` from our episode on [composition without operators](/episodes/ep11-composition-without-operators). Define an `update` function that combines the semantics of `with` and the variadic convenience of `concat` for ergonomics.
 */

let newUser = with(user, concat(
  set(prop(\User.name), "John123"),
  set(prop(\User.location.name), "Madrid"),
  set(prop(\User.birthdate), "1998-12-02")
  )
)

func update<A>(_ value: A, _ transformations: ((A) -> A)...) -> A {
  return transformations.reduce(value, with)
}

let newUser2 = update(user,
  set(prop(\User.name), "John123"),
  set(prop(\User.location.name), "Madrid"),
  set(prop(\User.birthdate), "1998-12-02")
)

/*:
 5.) In the Haskell Lens library, `over` and `set` are defined as infix operators `%~` and `.~`. Define these operators and explore what their precedence should be, updating some of our examples to use them. Do these operators tick the boxes?
 */

precedencegroup SetterApplication {
  associativity: left
  higherThan: SingleTypeComposition
}

infix operator %~: SetterApplication

func %~ <S, T, A, B>(_ setter: Setter<S, T, A, B>, _ set: @escaping (A) -> B) -> (S) -> T {
  return setter(set)
}

infix operator .~: SetterApplication

func .~ <S, T, A, B>(_ setter: Setter<S, T, A, B>,_ value: B) -> (S) -> T {
  return setter { _ in value }
}

let user55 = user
  |> ^\.name %~ { "Jr. " + $0 }
  <> ^\.name %~ { $0.uppercased() }
  <> ^\.location.name .~ "Lviv"

user55.name
user55.location.name


// Exists in swift - no
// prior art - yes
// solves global problem = yes
