
/*
<header>
  <h1>Point-Free</h1>
  <p id="blurb">
    Functional programming in Swift. <a href="/about">Learn more</a>!
  </p>
  <img src="https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg" width="64" height="64">
</header>
*/

enum Node {
  indirect case el(String, [(String, String)], [Node])
  case text(String)
}

Node.el("header", [], [
  .el("h1", [], [.text("Point-Free")]),
  .el("p", [("id", "blurb")], [
    .text("Functional programming in Swift. "),
    .el("a", [("href", "/about")], [.text("Learn more")]),
    .text("!")
    ]),
  .el("img", [("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")], []),
  ])

extension Node: ExpressibleByStringLiteral {
  init(stringLiteral value: String) {
    self = .text(value)
  }
}

Node.el("header", [], [
  .el("h1", [], ["Point-Free"]),
  .el("p", [("id", "blurb")], [
    "Functional programming in Swift. ",
    .el("a", [("href", "/about")], ["Learn more"]),
    "!"
    ]),
  .el("img", [("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")], []),
  ])

func header(_ attrs: [(String, String)], _ children: [Node]) -> Node {
  return .el("header", attrs, children)
}
func h1(_ attrs: [(String, String)], _ children: [Node]) -> Node {
  return .el("h1", attrs, children)
}
func p(_ attrs: [(String, String)], _ children: [Node]) -> Node {
  return .el("p", attrs, children)
}
func a(_ attrs: [(String, String)], _ children: [Node]) -> Node {
  return .el("a", attrs, children)
}
func img(_ attrs: [(String, String)]) -> Node {
  return .el("img", attrs, [])
}

header([], [
  h1([], ["Point-Free"]),
  p([("id", "blurb")], [
    "Functional programming in Swift. ",
    a([("href", "/about")], ["Learn more"]),
    "!"
    ]),
  img([("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")]),
  ])

func header(_ children: [Node]) -> Node {
  return .el("header", [], children)
}
func h1(_ children: [Node]) -> Node {
  return .el("h1", [], children)
}

header([
  h1(["Point-Free"]),
  p([("id", "blurb")], [
    "Functional programming in Swift. ",
    a([("href", "/about")], ["Learn more"]),
    "!"
    ]),
  img([("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")]),
  ])

func id(_ value: String) -> (String, String) {
  return ("id", value)
}
func href(_ value: String) -> (String, String) {
  return ("href", value)
}
func src(_ value: String) -> (String, String) {
  return ("src", value)
}
func width(_ value: Int) -> (String, String) {
  return ("width", "\(value)")
}
func height(_ value: Int) -> (String, String) {
  return ("height", "\(value)")
}

/*
 <header>
   <h1>Point-Free</h1>
   <p id="blurb">
     Functional programming in Swift. <a href="/about">Learn more</a>!
   </p>
   <img src="https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg" width="64" height="64">
 </header>
 */

let node = header([
  h1(["Point-Free"]),
  p([id("blurb")], [
    "Functional programming in Swift. ",
    a([href("/about")], ["Learn more"]),
    "!"
    ]),
  img([src("https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), width(64), height(64)]),
  ])

func render(_ node: Node) -> String {
  switch node {
  case let .el(tag, attrs, children):
    let formattedAttrs = attrs
      .map { key, value in "\(key)=\"\(value)\"" }
      .joined(separator: " ")

    let formattedChildren = children.map(render).joined(separator: "")
    return "<\(tag) \(formattedAttrs)>\(formattedChildren)</\(tag)>"
  case let .text(string):
    return string
  }
}

print(render(node))

func reversed(_ node: Node) -> Node {
  switch node {
  case let .el("img", attrs, children):
    return .el("img", attrs + [("style", "transform: scaleX(-1)")], children)
  case let .el(tag, attrs, children):
    return .el(tag, attrs, children.reversed().map(reversed))
  case let .text(string):
    return .text(String(string.reversed()))
  }
}

print("===")
print(render(reversed(node)))


/*:
 1. Our render function currently prints an extra space when attributes aren’t present: "<header ></header>". Fix the render function so that render(header([])) == "<header></header>".
 */
let values: [Int] = []
values.map(String.init).joined(separator: " ")

func render1(_ node: Node) -> String {
  switch node {
  case let .el(tag, attrs, children):
    let formattedAttrs = attrs
      .map { key, value in "\(key)=\"\(value)\"" }
      .joined(separator: " ")
    let attributes = formattedAttrs.isEmpty ? "" : " \(formattedAttrs)"

    let formattedChildren = children.map(render1).joined(separator: "")
    return "<\(tag)\(attributes)>\(formattedChildren)</\(tag)>"
  case let .text(string):
    return string
  }
}

print("=== R1")
print(render1(node))


/*:
 2. HTML specifies a number of “void elements” (elements that have no closing tag). This includes the img element in our example. Update the render function to omit the closing tag on void elements.
 */
let voidElements = ["img"]

func render2(_ node: Node) -> String {
  switch node {
  case let .el(tag, attrs, children):
    let formattedAttrs = attrs
      .map { key, value in "\(key)=\"\(value)\"" }
      .joined(separator: " ")
    let attributes = formattedAttrs.isEmpty ? "" : " \(formattedAttrs)"

    let formattedChildren = children.map(render2).joined(separator: "")
    let closingTag = voidElements.contains(tag) ? "" : "</\(tag)>"

    return "<\(tag)\(attributes)>\(formattedChildren)\(closingTag)"
  case let .text(string):
    return string
  }
}

print("=== R2")
print(render2(node))

/*:
 3.Our render function is currently unsafe: text node content isn’t escaped, which means it could be susceptible to cross-site scripting attacks. Ensure that text nodes are properly escaped during rendering.
 */
func render3(_ node: Node) -> String {
  switch node {
  case let .el(tag, attrs, children):
    let formattedAttrs = attrs
      .map { key, value in "\(key)=\"\(value)\"" }
      .joined(separator: " ")
    let attributes = formattedAttrs.isEmpty ? "" : " \(formattedAttrs)"

    let formattedChildren = children.map(render3).joined(separator: "")
    let closingTag = voidElements.contains(tag) ? "" : "</\(tag)>"

    return "<\(tag)\(attributes)>\(formattedChildren)\(closingTag)"
  case let .text(string):
    return escape(string)
  }
}

func escape(_ text: String) -> String {
  return "EscapedText" // Do something here
}


print("=== R3")
print(render3(node))
/*:
 4. Ensure that attribute nodes are properly escaped during rendering.
 */

func render4(_ node: Node) -> String {
  switch node {
  case let .el(tag, attrs, children):
    let formattedAttrs = attrs
      .map { key, value in "\(key)=\"\(escapeAttr(value))\"" }
      .joined(separator: " ")
    let attributes = formattedAttrs.isEmpty ? "" : " \(formattedAttrs)"

    let formattedChildren = children.map(render4).joined(separator: "")
    let closingTag = voidElements.contains(tag) ? "" : "</\(tag)>"

    return "<\(tag)\(attributes)>\(formattedChildren)\(closingTag)"
  case let .text(string):
    return escape(string)
  }
}

func escapeAttr(_ text: String) -> String {
  return "EscapedAttribute" // Do something here
}


print("=== R4")
print(render4(node))

/*:
 5.Write a function redacted, which transforms a Node and its children, replacing all non-whitespace characters with a redacted character: █.
 */
import Foundation

func redacted(_ node: Node) -> Node {
  switch node {
  case let .el(tag, attrs, children):
    return .el(tag, attrs, children.map(redacted))
  case let .text(string):
    let result = string.map { char -> Character in
      if isNewLine(char) {
        return Character("█")
      } else {
        return char
      }
    }

    return .text(String(result))
  }
}

func isNewLine(_ character: Character) -> Bool {
  let newLineSet = CharacterSet.whitespaces
  print("c: \(character)")
  for scalar in character.unicodeScalars {
    if !newLineSet.contains(scalar) { print("true"); return true }
  }
  print("false")
  return false
}

print("=== redacted")
print(render(redacted(node)))


/*:
 6.Write a function removingStyles, which removes all style nodes and attributes.
 */
func removingStyles(_ node: Node) -> Node {
  switch node {
  case let .el(tag, attrs, children):
    fatalError()
  case let .text(string):
    fatalError()
  }
}

/*:
 7. Write a function removingScripts, which removes all script nodes and attributes with the on prefix (like onclick).
 */

func removingScripts(_ node: Node) -> Node? {
  switch node {
  case let .el(tag, attrs, children):
    if tag.hasPrefix("on") { return nil }

    let newAttrs = attrs.filter { !$0.0.hasPrefix("on") }
    let newChildren = children.map(removingScripts).compactMap { $0 }
    return .el(tag, newAttrs, newChildren)

  case let .text(string):
    return node
  }
}
