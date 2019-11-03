/*:
 # DSLs vs. Templating Languages

 ## Exercises

 1.) In this episode we expressed a lot of HTML “views” as just plain functions from some data type into the Node type. In past episodes we saw that functions `(A) -> B` have both a `map` and `contramap` defined, the former corresponding to post-composition and the latter pre-composition. What does `map` and `contramap` represent in the context of an HTML view `(A) -> Node`?
 */
// (A) -> Node

// map: Some kind of transformations over nodes
func mapHTML(_ transform: @escaping (Node) -> Node) -> ([Node]) -> [Node] {
  return { $0.map(transform) }
}

// contramap: how to create a node from different input
func contramapHTML<A, B>(_ transform: @escaping (B) -> A) -> (@escaping (A) -> Node) -> ((B) -> Node) {
  return { aToNode in
    return { b in
      return aToNode(transform(b))
    }
  }
}
/*:
 2.) When building a website you often realize that you want to be able to reuse an outer “shell” of a view, and plug smaller views into it. For example, the header, nav and footer would consist of the “shell”, and then the content of your homepage, about page, contact page, etc. make up the inside. This is a kind of “view composition”, and most templating languages provide something like it (Rails calls it layouts, Stencil calls it inheritance).

 Formulate what this form of view composition looks like when you think of views as just functions of the form `(A) -> Node`.
 */
// It can be carried. e.g. a function that takes a header and then return a function which expects a body etc
func shell<A>(_ header: @escaping (A) -> Node, body: @escaping (A) -> Node, footer: @escaping (A) -> Node) -> (A) -> Node {
  return { a in
    // Compose it in a meaningful way and return a node
    fatalError()
  }
}
/*:
 3.) In previous episodes on this series we have discussed the `<>` (diamond) operator. We have remarked that this operator comes up anytime we have a nice way of combining two values of the same type together into a third value of the same type, i.e. functions of the form `(A, A) -> A`.

 Given two views of the form `v, w: (A) -> [Node]`, it is possible to combine them into one view. Define the diamond operator that performs this operation: `<>: ((A) -> [Node], (A) -> [Node]) -> (A) -> [Node]`.
 */
func diamond<A>(_ lhs: @escaping (A) -> [Node], rhs: @escaping (A) -> [Node]) -> (A) -> [Node] {
  return { a in lhs(a) + rhs(a) } // implementation depends on the details what these nodes represents. Maybe we need to take tags into account and throw errors if 2 arrays of nodes cant be joined
}
/*:
 4.) Right now any node is allowed to be embedded inside any other node, even though certain HTML semantics forbid that. For example, the list item tag `<li>` is only allowed to be embedded in unordered lists `<ul>` and ordered lists `<ol>`. We can’t enforce this property through the `Node` type, but we can do it through the functions we define for constructing tags. The technique uses something known as phantom types, and it’s similar to what we did in our Tagged episode. Here is a series of exercises to show how it works:

 4a.) First define a new `ChildOf` type. It’s a struct that simply wraps a `Node` value, but most importantly it has a generic `<T>`. We will use this generic to control when certain nodes are allowed to be embedded inside other nodes.
 */
struct ChildOf<T> {
  let node: Node
}
/*:
 4b.) Define two new types, `Ol` and `Ul`, that will act as the phantom types for `ChildOf`. Since we do not care about the contents of these types, they can just be simple empty enums.
 */
enum Ol {}
enum Ul {}
/*:
 4c.) Define a new protocol, `ContainsLi`, and make both `Ol` and `Ul` conform to it. Again, we don’t care about the contents of this protocol, it is only a means to tag `Ol` and `Ul` as having the property that they are allowed to contain `<li>` elements.
 */
protocol ContainsLi {}
extension Ol: ContainsLi {}
extension Ul: ContainsLi {}
/*:
 4d.) Finally, define three new tag functions `ol`, `ul` and `li` that allow you to nest `<li>`s inside `<ol>`s and `<ul>`s but prohibit you from putting `li`s in any other tags. You will need to use the types `ChildOf<Ol>`, `ChildOf<Ul>` and `ContainsLi` to accomplish this.
 */
func li4(_ children: [Node]) -> ChildOf<ContainsLi> {
  return ChildOf(node: .el("li", [], children))
}

func ul4(_ children: ChildOf<Ol>) -> Node {
  return .el("ul", [], [children.node])
}

func ol4(_ children: ChildOf<ContainsLi>) -> Node {
  return .el("ol", [], [children.node])
}

let liNode = li4([.text(" ")])
let ulNode = ul4(liNode)
let olNode = ol4(liNode)
