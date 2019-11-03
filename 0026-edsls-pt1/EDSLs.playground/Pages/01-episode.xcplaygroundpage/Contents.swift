

/*
 SELECT id, name
 FROM users
 WHERE email = 'blob@pointfree.co'
 */


/*
<html>
  <body>
    <p>Hello World!</p>
  </body>
</html>
*/


/*
platform :ios, '8.0'
use_frameworks!

target 'MyApp' do
  pod 'NonEmpty', '~> 0.2'
  pod 'Overture', '~> 0.1'
end
*/

/*
github "pointfreeco/NonEmpty" ~> 0.2
github "pointfreeco/Overture" ~> 0.1
*/

//x * (4 + 5)
//(x * 4) + 5

enum Expr: Equatable {
  case int(Int)
  indirect case add(Expr, Expr)
  indirect case mul(Expr, Expr)
  case `var`(String)
}

Expr.int(3)
Expr.add(.int(3), .int(4))
Expr.add(.add(.int(3), .int(4)), .int(5))
Expr.add(.add(.int(3), .int(4)), .add(.int(5), .int(6)))

Expr.add(
  .add(
    .int(3),
    .int(4)
  ),
  .add(
    .int(5),
    .int(6)
  )
)

extension Expr: ExpressibleByIntegerLiteral {
  init(integerLiteral value: Int) {
    self = .int(value)
  }
}

Expr.add(.add(3, 4), .add(5, 6))

func eval(_ expr: Expr, with values: [String: Int]) -> Int {
  switch expr {
  case let .int(value):
    return value
  case let .add(lhs, rhs):
    return eval(lhs, with: values) + eval(rhs, with: values)
  case let .mul(lhs, rhs):
    return eval(lhs, with: values) * eval(rhs, with: values)
  case let .var(name):
    return values[name]!
  }
}

eval(.add(.add(3, 4), .add(5, 6)), with: ["x": 0])

eval(.mul(.add(3, 4), .add(5, 6)), with: ["x": 0])

eval(.mul(.add(.var("x"), 4), .add(5, 6)), with: ["x": 0])

func print(_ expr: Expr) -> String {
  switch expr {
  case let .int(value):
    return "\(value)"
  case let .add(lhs, rhs):
    return "(\(print(lhs)) + \(print(rhs)))"
  case let .mul(lhs, rhs):
    return "(\(print(lhs)) * \(print(rhs)))"
  case let .var(name):
    return name
  }
}

print(.add(.add(3, 4), .add(5, 6)))

print(.mul(.add(3, 4), .add(5, 6)))
// 3 + (4 * 5) + 6

print(.mul(.add(3, .var("x")), .add(5, 6)))

print(.mul(.add(3, .var("x")), .add(5, .var("x"))))

func swap(_ expr: Expr) -> Expr {
  switch expr {
  case .int:
    return expr
  case let .add(lhs, rhs):
    return .mul(swap(lhs), swap(rhs))
  case let .mul(lhs, rhs):
    return .add(swap(lhs), swap(rhs))
  case .var:
    return expr
  }
}

print(swap(.mul(.add(3, 4), .add(5, 6))))

print(Expr.add(.mul(2, 3), .mul(2, 4)))
print(Expr.mul(2, .add(3, 4)))

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
  }
}

print(simplify(Expr.add(.mul(2, 3), .mul(2, 4))))

print(simplify(Expr.add(.mul(.var("x"), 3), .mul(.var("x"), 4))))

/*:
 1. Simplify
*/
/*
Factorize the c out of this expression: a * c + b * c.
Reduce 1 * a and a * 1 to just a.
Reduce 0 * a and a * 0 to just 0.
Reduce 0 + a and a + 0 to just a.
 */

func simplifyPlus(_ expr: Expr) -> Expr {
  switch expr {
  case let .add(.mul(a, b), .mul(c, d)) where a == c:
    print("a == c")
    return .mul(simplifyPlus(a), .add(simplifyPlus(b), simplifyPlus(d)))
  case let .add(.int(a), rhs) where a == 0:
    print("0 + a")
    return simplifyPlus(rhs)
  case let .add(lhs , .int(b)) where b == 0:
    print("a + 0")
    return simplifyPlus(lhs)
  case let .mul(.int(a), _) where a == 0:
    print("0 * a")
    return .int(0)
  case let .mul(_ , .int(b)) where b == 0:
    print("a * 0")
    return .int(0)
  case let .mul(.int(a), rhs) where a == 1:
    print("1 * a")
    return simplifyPlus(rhs)
  case let .mul(lhs , .int(b)) where b == 1:
    print("a * 1")
    return simplifyPlus(lhs)
  case let .add(lhs, rhs):
    print("add")
    let result = Expr.add(simplifyPlus(lhs), simplifyPlus(rhs))

    if result == expr {
      return result
    } else {
      return simplifyPlus(result)
    }
  case let .mul(lhs, rhs):
    print("mul")
    let result = Expr.mul(simplifyPlus(lhs), simplifyPlus(rhs))

    if result == expr {
      return result
    } else {
      return simplifyPlus(result)
    }
  case .var, .int:
    return expr
  }
}

print(simplify(Expr.add(.mul(2, 0), .mul(.add(0, 2), 4))))
print(simplifyPlus((.mul(2, 0) + .mul(.add(0, 2), 4))))

/*:
 2. Enhance Expr to allow for any number of variables. The eval implementation will need to change to allow passing values in for all of the variables introduced.
 */
// done above (added associated value to the .var case)
/*:
 3. Implement infix operators * and + to work on Expr to get rid of the .add and .mul annotations.
 */

func * (lhs: Expr, rhs: Expr) -> Expr {
  return .mul(lhs, rhs)
}

func + (lhs: Expr, rhs: Expr) -> Expr {
  return .add(lhs, rhs)
}

print(.mul(2, 0) + .mul(3, 4))

/*:
 4. Implement a function varCount: (Expr) -> Int that counts the number of .var’s used in an expression.
 */
func varCount(_ expr: Expr) -> Int {
  switch expr {
  case let .add(lhs, rhs):
    return varCount(lhs) + varCount(rhs)
  case let .mul(lhs, rhs):
    return varCount(lhs) + varCount(rhs)
  case .int:
    return 0
  case .var:
    return 1
  }
}

varCount(.mul(.add(.var("x"), 4), .add(.var("y"), .add(.var("x"), .var("z")))))
