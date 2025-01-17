
struct LCRNG: RandomNumberGenerator {
  var seed: UInt64

  init(seed: UInt64) {
    self.seed = seed
  }

  mutating func next() -> UInt64 {
    seed = 2862933555777941757 &* seed &+ 3037000493
    return seed
  }
}

struct AnyRandomNumberGenerator: RandomNumberGenerator {
  var rng: RandomNumberGenerator
  mutating func next() -> UInt64 {
    return rng.next()
  }
}

struct Gen<A> {
  let run: (inout AnyRandomNumberGenerator) -> A

  func run<RNG: RandomNumberGenerator>(using rng: inout RNG) -> A {
    var arng = AnyRandomNumberGenerator(rng: rng)
    let result = self.run(&arng)
    rng = arng.rng as! RNG
    return result
  }
}

extension Gen {
  func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
    return Gen<B> { rng in f(self.run(&rng)) }
  }

  func flatMap<B>(_ f: @escaping (A) -> Gen<B>) -> Gen<B> {
    return Gen<B> { rng in
      f(self.run(&rng)).run(&rng)
    }
  }
}

func zip<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
  return Gen<(A, B)> { rng in
    (ga.run(&rng), gb.run(&rng))
  }
}

func zip<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
  return { zip($0, $1).map(f) }
}

func zip4<A, B, C, D, Z>(
  with f: @escaping (A, B, C, D) -> Z
  ) -> (Gen<A>, Gen<B>, Gen<C>, Gen<D>) -> Gen<Z> {

  return { a, b, c, d in
    Gen<Z> { rng in
      f(a.run(&rng), b.run(&rng), c.run(&rng), d.run(&rng)) }
  }
}

extension Gen where A: BinaryFloatingPoint, A.RawSignificand: FixedWidthInteger {
  static func float(in range: ClosedRange<A>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen where A: FixedWidthInteger {
  static func int(in range: ClosedRange<A>) -> Gen {
    return Gen { rng in .random(in: range, using: &rng) }
  }
}

extension Gen where A == Bool {
  static let bool = Gen { rng in .random(using: &rng) }
}

extension Gen {
  static func element(of xs: [A]) -> Gen<A?> {
    return Gen<A?> { rng in xs.randomElement(using: &rng) }
  }

  func array(of count: Gen<Int>) -> Gen<[A]> {
    return count.flatMap { count in
      Gen<[A]> { rng -> [A] in
        var array: [A] = []
        for _ in 1...count {
          array.append(self.run(&rng))
        }
        return array
      }
    }
  }

  static func always(_ a: A) -> Gen<A> {
    return Gen { _ in a }
  }
}

import UIKit

let canvas = CGRect(x: 0, y: 0, width: 600, height: 600)
let mainArea = canvas.insetBy(dx: 130, dy: 100)
let numLines = 80
let numSegments = 80

func f(_ x: CGFloat) -> CGFloat {
  if x <= 0 { return 0 }
  return exp(-1 / x) // e^(-1 / x)
}

func g(_ x: CGFloat) -> CGFloat {
  return f(x) / (f(x) + f(1 - x))
}

func h(_ x: CGFloat) -> CGFloat {
  return g(x * x)
}

func bump(
  amplitude: CGFloat,
  center: CGFloat,
  plateauSize: CGFloat,
  curveSize: CGFloat
  ) -> (CGFloat, CGFloat) -> Gen<CGFloat> {
  return { min, max in
    Gen<CGFloat> { rng in
      let plateauSize = plateauSize / 2
      let curveSize = curveSize / 2
      let size = plateauSize + curveSize
      let x = Gen<CGFloat>.float(in: min...max).run(using: &rng) - center
      return amplitude * (1 - g((x * x - plateauSize * plateauSize) / (size * size - plateauSize * plateauSize)))
    }
  }
}

let curve = zip4(with: bump(amplitude:center:plateauSize:curveSize:))(
  Gen<CGFloat>.float(in: -20...(-1)),
  Gen<CGFloat>.float(in: -60...60)
    .map { $0 + canvas.width / 2 },
  Gen<CGFloat>.float(in: 0...60),
  Gen<CGFloat>.float(in: 10...60)
)

func path(from min: CGFloat, to max: CGFloat, baseline: CGFloat) -> Gen<CGPath> {
  let dx = mainArea.width / CGFloat(numSegments)
  return Gen<CGPath> { rng in
    let bump = curve.run(using: &rng)

    let path = CGMutablePath()
    path.move(to: CGPoint(x: min, y: baseline))
    stride(from: min, to: max, by: dx)
      .forEach { x in
        let y = bump(min, max).run(using: &rng)
        path.addLine(to: CGPoint(x: x, y: baseline + y))
    }
    return path
  }
}

func collect<A>(_ gens: [Gen<A>]) -> Gen<[A]> {
  return Gen<[A]> { rng in
    gens.map { gen in gen.run(using: &rng) }
  }
}

let paths: Gen<[CGPath]> = collect(
  stride(from: mainArea.minY, to: mainArea.maxY, by: mainArea.height / CGFloat(numLines))
    .map { y in path(from: mainArea.minX, to: mainArea.maxX, baseline: y) }
)

let image: Gen<UIImage> = paths.map { paths in
  return UIGraphicsImageRenderer(bounds: canvas).image { ctx in
    let ctx = ctx.cgContext

    ctx.setFillColor(UIColor.black.cgColor)
    ctx.fill(canvas)

    ctx.setLineWidth(1.2)
    ctx.setStrokeColor(UIColor.white.cgColor)

    paths.forEach { path in
      ctx.addPath(path)
      ctx.drawPath(using: .fillStroke)
    }
  }
}

//graph(<#T##f: (CGFloat) -> CGFloat##(CGFloat) -> CGFloat#>)

var lcrng = LCRNG(seed: 1)

import PlaygroundSupport


//PlaygroundPage.current.liveView = UIImageView(image:  graph({ bump(amplitude: 0.5, center: 0.25, plateauSize: 0.25, curveSize: 2, $0) }))

PlaygroundPage.current.liveView = UIImageView(image: image.run(using: &lcrng))




// Homework

/*:
 1. Create a generator Gen<UIColor> of colors. Can this be expressed in terms of multiple Gen<CGFloat> generators?
 */

let colorGenerator = zip4(with: UIColor.init(red:green:blue:alpha:))(
  Gen<CGFloat>.float(in: 0...1),
  Gen<CGFloat>.float(in: 0...1),
  Gen<CGFloat>.float(in: 0...1),
  Gen<CGFloat>.float(in: 0...1)
)

/*:
 2. Create a generator Gen<CGPath> of random lines on a canvas. Can this be expressed in terms of multiple Gen<CGPoint> generators?
 */


func linePath(start: CGPoint, end: CGPoint) -> CGPath {
  let path = CGMutablePath()
  path.move(to: start)
  path.addLine(to: end)
  return path
}

let pointGenerator = zip(with: CGPoint.init(x:y:))(
  Gen<CGFloat>.float(in: canvas.minX...canvas.maxX),
  Gen<CGFloat>.float(in: canvas.minY...canvas.maxY)
)

let linePathGenerator = zip(with: linePath(start:end:))(
  pointGenerator,
  pointGenerator
)

/*:
 3. Create a generator Gen<UIImage> that draws a random number of randomly positioned straight lines on a canvas with random colors. Try to compose this generator out of lots of smaller generators.
 */

let imageGenerator3 = Gen<UIImage> { rng in
  let paths = Array(repeating: 0, count: 50).map { _ in linePathGenerator.run(&rng) }
  return UIGraphicsImageRenderer(bounds: canvas).image { ctx in
    let ctx = ctx.cgContext
    ctx.setFillColor(UIColor.black.cgColor)
    ctx.fill(canvas)

    ctx.setLineWidth(1.2)

    paths.forEach { path in
      ctx.setStrokeColor(colorGenerator.run(&rng).cgColor)
      ctx.addPath(path)
      ctx.drawPath(using: .fillStroke)
    }
  }
}

//var anyGenerator = AnyRandomNumberGenerator(rng: SystemRandomNumberGenerator())
//let image3 = imageGenerator3.run(using: &anyGenerator)
//PlaygroundPage.current.liveView = UIImageView(image: image3)

/*:
4. Change the bump function we created in this episode so that it adds a bit of random noise to the curve. To do this you will want to change the signature so that it returns a function (CGFloat) -> Gen<CGFloat> instead of just a simple function (CGFloat) -> CGFloat. This will allow you to introduce random perturbations into the y-coordinate of the graph.
 */

