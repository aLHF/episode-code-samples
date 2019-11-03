import SwiftSyntax
import Foundation

let url = Bundle.main.url(forResource: "Enums", withExtension: "swift")!

let tree = try SyntaxTreeParser.parse(url)

// extension Validated {
//   var valid: Valid? {
//     guard case let .valid(value) = self else { return nil }
//     return value
//   }
//   var invalid: [Invalid?] {
//     guard case let .valid(value) = self else { return nil }
//     return value
//   }
// }

class Visitor: SyntaxVisitor {
  override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    print("extension \(node.identifier.withoutTrivia()) {")
    return .visitChildren
  }

  override func visitPost(_ node: Syntax) {
    if node is EnumDeclSyntax {
      print("}")
    }
  }

  override func visit(_ node: EnumCaseElementSyntax) -> SyntaxVisitorContinueKind {
    let type: String = {
      if node.associatedValue!.parameterList.count > 1 {
        return "(\(node.associatedValue!.parameterList))"
      } else {
        return "\(node.associatedValue!.parameterList)"
      }
    }()
    
    print("  var \(node.identifier): \(type)? {")
    print("    guard case let .\(node.identifier)(value) = self else { return nil }")
    print("    return value")
    print("  }")
    return .skipChildren
  }
}

let visitor = Visitor()
tree.walk(visitor)

enum Validated<Valid, Invalid> {
  case valid(Valid, String)
  case invalid([Invalid], String)
}

extension Validated {
  var valid: (Valid, String)? {
    guard case let .valid(value) = self else { return nil }
    return value
  }
}
