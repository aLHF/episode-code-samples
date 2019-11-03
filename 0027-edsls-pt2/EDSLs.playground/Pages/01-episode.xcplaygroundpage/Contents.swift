
//x * (4 + 5)
//(x * 4) + 5

let x = 5 * 3
x + 2

enum Expr: Equatable {
  case int(Int)
  indirect case add(Expr, Expr)
  indirect case mul(Expr, Expr)
  case `var`(String)
  indirect case bind([String: Expr], in: Expr)
}

extension Expr: ExpressibleByIntegerLiteral {
  init(integerLiteral value: Int) {
    self = .int(value)
  }
}

func eval(_ expr: Expr, with env: [String: Int]) -> Int {
  switch expr {
  case let .int(value):
    return value
  case let .add(lhs, rhs):
    return eval(lhs, with: env) + eval(rhs, with: env)
  case let .mul(lhs, rhs):
    return eval(lhs, with: env) * eval(rhs, with: env)
  case let .var(id):
    guard let value = env[id] else { fatalError("Couldn't find \(id) in \(env)") }
    return value

  case let .bind(bindings, scopedExpr):
    var bindingsEnv: [String: Int] = [:]
    bindings.forEach { bindingsEnv[$0.key] = eval($0.value, with: env) }
    let newEnv = env.merging(bindingsEnv, uniquingKeysWith: { $1 })
    return eval(scopedExpr, with: newEnv)
  }
}

func print(_ expr: Expr) -> String {
  switch expr {
  case let .int(value):
    return "\(value)"
  case let .add(lhs, rhs):
    return "(\(print(lhs)) + \(print(rhs)))"
  case let .mul(lhs, rhs):
    return "(\(print(lhs)) * \(print(rhs)))"
  case let .var(id):
    return id
  case let .bind(bindings, scopedExpr):
    let boundExprs = bindings.map { "let \($0.key) = \(print($0.value))" }.joined(separator: ", ")

    return "(\(boundExprs) in \(print(scopedExpr))"
    // let x = 1 in x + 2
  }
}

func simplify(_ expr: Expr) -> Expr {
  switch expr {
  case .int:
    return expr
  case let .add(.mul(a, b), .mul(c, d)) where a == c:
    return .mul(a, .add(b, d))
  case .add:
    return expr
  case .mul:
    return expr
  case .var:
    return expr
  case .bind:
    return expr
  }
}

extension Expr: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self = .var(value)
  }
}

//let expr = Expr.add(.mul(.var("x"), 4), .mul(.var("y"), 6))
let expr = Expr.add(.mul("x", "y"), .mul("x", 6))

eval(expr, with: ["x": 2, "y": 3])
print(expr)
print(simplify(expr))


let expr1 = Expr.mul(3, .bind(["z": .add("x", 2), "y": .mul("e", 4)], in: .mul("z", "y")))

print(expr1)
eval(expr1, with: ["x": 2, "e": 1])

/*:
 1. Implement an inliner function inline: (Expr) -> Expr that removes all let-bindings and inlines the body of the binding directly into the subexpression.
 */

func inline(_ expr: Expr) -> Expr {
  switch expr {
  case let .bind(bindings, scoped):
    var result = scoped

    for bound in bindings {
      result = swap(id: bound.key, in: scoped, for: bound.value)
    }

    return result
  case let .add(lhs, rhs):
    return .add(inline(lhs), inline(rhs))
  case let .mul(lhs, rhs):
    return .mul(inline(lhs), inline(rhs))
  case .int, .var:
    return expr
  }
}

func swap(id: String, in scoped: Expr, for bound: Expr) -> Expr {
  switch scoped {
  case let .var(name) where name == id:
    return bound
  case .int, .var:
    return scoped
  case let .add(lhs, rhs):
    return .add(swap(id: id, in: lhs, for: bound), swap(id: id, in: rhs, for: bound))
  case let .mul(lhs, rhs):
    return .mul(swap(id: id, in: lhs, for: bound), swap(id: id, in: rhs, for: bound))
  case let .bind(bindings, scoped):
    var result = scoped

    for bound in bindings {
      result = swap(id: bound.key, in: scoped, for: bound.value)
    }

    return result
  }
}


print(inline(expr1))
let expr2 = Expr.mul(3, .bind(["z": .add("x", 2)], in: .mul("z", .bind(["y": .add("p", 2)], in: .mul("y", "z")))))
print(inline(expr2))

/*:
 2. Implement a function freeVars: (Expr) -> String that collects all of the variables used in an expression.
 */
func freeVars(_ expr: Expr) -> String {
  var set: Set<Character> = []

  switch expr {
  case .int:
    return ""
  case let .var(name):
    return name
  case let .add(lhs, rhs), let .mul(lhs, rhs):
    freeVars(lhs).forEach { set.insert($0) }
    freeVars(rhs).forEach { set.insert($0) }
    return String(set)
  case let .bind(bindings, scoped):
    freeVars(scoped).forEach { set.insert($0) }
    bindings.map { freeVars($0.value) }.flatMap { $0 }.forEach { set.insert($0) }
    return String(set)
  }
}

let expr3 = Expr.mul(3, .bind(["z": .add("x", 2)], in: .mul("z", .bind(["y": .add("p", 2)], in: .mul("y", "d")))))

print(freeVars(expr3))
let expr4 = Expr.mul("x", "x")
print(freeVars(expr4))

/*:
 3. Define an infix operator .= to mimic let-bindings. At the call site its usage might look something like: ("x" .= 3)("x" * 2 + 3), where we are using the infix operators * and + defined in the exercises of the last episode.
 */
//func * (lhs: Expr, rhs: Expr) -> Expr {
//  return .mul(lhs, rhs)
//}
//
//func + (lhs: Expr, rhs: Expr) -> Expr {
//  return .add(lhs, rhs)
//}
//
//infix operator .=
//func .= (lhs: Expr, rhs: Expr) -> Expr {
//  guard case let .var(name) = lhs else { fatalError("lhs should be a var.") }
//
//  return .bind(name, to: rhs, in: <#T##Expr#>)
//}
//
//.int(2) .= .int(2)

/*:
 4. Update bind to take a dictionary of bindings rather than a single binding.
 */
// Done

/*:
 5. In this exercise we are going to implement a function D: (String) -> (Expr) -> Expr that computes the derivative of any expression you give it. This may sound scary, but we’ll take it one step at a time!
 */
func derivative(_ variable: String) -> (Expr) -> Expr {
  return {
    switch $0 {
    case let .add(lhs, rhs):
      return .add(derivative(variable)(lhs), derivative(variable)(rhs))
    case let .mul(lhs, rhs):
      return .add(.mul(derivative(variable)(lhs), rhs), .mul(derivative(variable)(rhs), lhs))
    case let .bind(bindings, scoped):
      return bindings.map { $0 }.reduce(.int(0)) { result, binding in
        return .add(
          result,
          .mul(
            derivative(binding.key)(binding.value),
            .bind([binding.key: binding.value], in: derivative(variable)(scoped))
          )
        )
      }
    case .int:
      return .int(0)
    case let .var(name):
      if name == variable {
        return .int(1)
      } else {
        return .int(0)
      }
    }
  }
}
