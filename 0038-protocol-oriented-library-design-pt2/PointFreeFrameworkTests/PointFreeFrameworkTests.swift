import XCTest
@testable import PointFreeFramework

class PointFreeFrameworkTests: SnapshotTestCase {
  func testEpisodesView() {
    let episodesVC = EpisodeListViewController(episodes: episodes)

//    assertSnapshot(matching: episodesVC)
    assertSnapshot(matching: episodesVC, witness: .image)
  }

  func testGreeting() {
//    record = true
    let greeting = """
Welcome to Point-Free!
-----------------------------------------
A Swift video series exploring functional
programming and more.
"""

    assertSnapshot(matching: greeting)
  }
}

protocol Snapshottable {
  associatedtype Snapshot: Diffable
  static var pathExtension: String { get }
  var snapshot: Snapshot { get }
}

protocol Diffable {
  static func diff(old: Self, new: Self) -> (String, [XCTAttachment])?
  static func from(data: Data) -> Self
  var data: Data { get }
}

extension String: Diffable {
  static func diff(old: String, new: String) -> (String, [XCTAttachment])? {
    guard let difference = Diff.lines(old, new) else { return nil }
    return ("Diff: …\n\(difference)", [XCTAttachment(string: difference)])
  }

  static func from(data: Data) -> String {
    return String(decoding: data, as: UTF8.self)
  }

  var data: Data {
    return Data(self.utf8)
  }
}

extension String: Snapshottable {
  static let pathExtension = "txt"

  var snapshot: String {
    return self
  }
}

extension UIImage: Diffable {
  var data: Data {
    return self.pngData()!
  }

  static func from(data: Data) -> Self {
    return self.init(data: data, scale: UIScreen.main.scale)!
  }

  static func diff(old: UIImage, new: UIImage) -> (String, [XCTAttachment])? {
    guard let difference = Diff.images(old, new) else { return nil }
    return (
      "Expected old@\(old.size) to match new@\(new.size)",
      [old, new, difference].map(XCTAttachment.init(image:))
    )
  }
}

extension UIImage: Snapshottable {
  var snapshot: UIImage {
    return self
  }
}

extension Snapshottable where Snapshot == UIImage {
  static var pathExtension: String {
    return "png"
  }
}

extension CALayer: Snapshottable {
  var snapshot: UIImage {
    return UIGraphicsImageRenderer(size: self.bounds.size)
      .image { ctx in self.render(in: ctx.cgContext) }
  }
}

extension Snapshottable where Snapshot == String {
  static var pathExtension: String { return "txt" }
}

extension UIView: Snapshottable {
//  var snapshot: UIImage {
//    return self.layer.snapshot
//  }

  var snapshot: String {
    self.setNeedsLayout()
    self.layoutIfNeeded()
    return (self.perform(Selector(("recursiveDescription")))?.takeUnretainedValue() as! String)
      .replacingOccurrences(of: ":?\\s*0x[\\da-f]+(\\s*)", with: "$1", options: .regularExpression)
  }
}

extension UIViewController: Snapshottable {
//  var snapshot: UIImage {
//    return self.view.snapshot
//  }

  var snapshot: String {
    return self.view.snapshot
  }
}

// #1
struct Diffing<A> {
  let diff: (A, A) -> (String, [XCTAttachment])?
  let from: (Data) -> A
  let data: (A) -> Data
}

// #2
struct Snapshotting<A, Snapshot> {
  let diffing: Diffing<Snapshot>
  let pathExtension: String
  let to: (A) -> Snapshot
}

// #3
extension Diffing where A == String {
  static let string = Diffing(
    diff: { (old, new) -> (String, [XCTAttachment])? in
      guard let difference = Diff.lines(old, new) else { return nil }
      return ("Diff: …\n\(difference)", [XCTAttachment(string: difference)])
  },
    from: { data -> String in String(decoding: data, as: UTF8.self) },
    data: { string -> Data in Data(string.utf8)}
  )
}

extension Diffing where A == UIImage {
  static let image = Diffing<UIImage>(
    diff: { old, new in
      guard let difference = Diff.images(old, new) else { return nil }
      return (
        "Expected old@\(old.size) to match new@\(new.size)",
        [old, new, difference].map(XCTAttachment.init(image:))
      )
  },
    from: { data in UIImage(data: data, scale: UIScreen.main.scale)! },
    data: { image in image.pngData()! }
  )
}

// #4
extension Snapshotting where A == String, Snapshot == String {
  static let string = Snapshotting(diffing: .string, pathExtension: "txt", to: { $0 })
}

extension Snapshotting where A == UIImage, Snapshot == UIImage {
  static let image = Snapshotting(diffing: .image, pathExtension: "png", to: { $0 })
}

extension Snapshotting where A == CALayer, Snapshot == UIImage {
  static let image = Snapshotting(
    diffing: .image,
    pathExtension: "png",
    to: { layer in return UIGraphicsImageRenderer(size: layer.bounds.size).image { ctx in layer.render(in: ctx.cgContext) }
  })
}

extension Snapshotting where A == UIView, Snapshot == UIImage {
  static let image = Snapshotting(
    diffing: .image,
    pathExtension: "png",
    to: { view in Snapshotting<CALayer, UIImage>.image.to(view.layer) }
  )
}

extension Snapshotting where A == UIView, Snapshot == String {
  static let string = Snapshotting(
    diffing: .string,
    pathExtension: "txt",
    to: { view in
      view.setNeedsLayout()
      view.layoutIfNeeded()
      return (view.perform(Selector(("recursiveDescription")))?.takeUnretainedValue() as! String)
        .replacingOccurrences(of: ":?\\s*0x[\\da-f]+(\\s*)", with: "$1", options: .regularExpression)
  })
}

extension Snapshotting where A == UIViewController, Snapshot == UIImage {
  static let image = Snapshotting(
    diffing: .image,
    pathExtension: "png",
    to: { controller in Snapshotting<CALayer, UIImage>.image.to(controller.view.layer) }
  )
}

extension Snapshotting where A == UIViewController, Snapshot == String {
  static let string = Snapshotting(
    diffing: .string,
    pathExtension: "txt",
    to: { controller in
      controller.view.setNeedsLayout()
      controller.view.layoutIfNeeded()
      return (controller.view.perform(Selector(("recursiveDescription")))?.takeUnretainedValue() as! String)
        .replacingOccurrences(of: ":?\\s*0x[\\da-f]+(\\s*)", with: "$1", options: .regularExpression)
  })
}

class SnapshotTestCase: XCTestCase {
  var record = false

  func assertSnapshot<S: Snapshottable>(
    matching value: S,
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line) {

    let snapshot = value.snapshot
    let referenceUrl = snapshotUrl(file: file, function: function)
      .appendingPathExtension(S.pathExtension)

    if !self.record, let referenceData = try? Data(contentsOf: referenceUrl) {
      let reference = S.Snapshot.from(data: referenceData)
      guard let (failure, attachments) = S.Snapshot.diff(old: reference, new: snapshot) else { return }
      XCTFail(failure, file: file, line: line)
      XCTContext.runActivity(named: "Attached failure diff") { activity in
        attachments.forEach(activity.add)
      }
    } else {
      try! snapshot.data.write(to: referenceUrl)
      XCTFail("Recorded: …\n\"\(referenceUrl.path)\"", file: file, line: line)
    }
  }

  // #5
  func assertSnapshot<A, Snapshot>(
    matching value: A,
    witness: Snapshotting<A, Snapshot>,
    file: StaticString = #file,
    function: String = #function,
    line: UInt = #line) {

    let snapshot = witness.to(value)
    let referenceUrl = snapshotUrl(file: file, function: function)
      .appendingPathExtension(witness.pathExtension)

    if !self.record, let referenceData = try? Data(contentsOf: referenceUrl) {
      let reference = witness.diffing.from(referenceData)

      guard let (failure, attachments) = witness.diffing.diff(reference, snapshot) else { return }
      XCTFail(failure, file: file, line: line)
      XCTContext.runActivity(named: "Attached failure diff") { activity in
        attachments.forEach(activity.add)
      }
    } else {

      try! witness.diffing.data(snapshot).write(to: referenceUrl)
      XCTFail("Recorded: …\n\"\(referenceUrl.path)\"", file: file, line: line)
    }
  }
}
