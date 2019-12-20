import XCTest
@testable import FavoritePrimes

class FavoritePrimesTests: XCTestCase {
  override class func setUp() {
    super.setUp()
    Current = .mock
  }

  func testDeleteFavoritePrimes() {
    var state = [2, 3, 5, 7]
    let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))

    XCTAssertEqual(state, [2, 3, 7])
    XCTAssert(effects.isEmpty)
  }

  func testSaveButtonTapped() {
    var state = [2, 3, 5, 7]
    let expectedData = try! JSONEncoder().encode(state)

    var didSave = false
    Current.fileClient.save = { _, data in
      if data != expectedData { XCTFail() }
      return .fireAndForget {
        didSave = true
      }
    }

    let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)

    XCTAssertEqual(state, [2, 3, 5, 7])
    XCTAssertEqual(effects.count, 1)

    _ = effects[0].sink { _ in XCTFail() }

    XCTAssert(didSave)
  }

  func testLoadFavoritePrimesFlow() {
    Current.fileClient.load = { _ in .sync { try! JSONEncoder().encode([2, 31]) } }

    var state = [2, 3, 5, 7]
    var hasReceivedValue = false
    var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)

    XCTAssertEqual(state, [2, 3, 5, 7])
    XCTAssertEqual(effects.count, 1)

    var nextAction: FavoritePrimesAction!
    let receivedCompletion = self.expectation(description: "receivedCompletion")
    _ = effects[0].sink(
      receiveCompletion: { _ in
        receivedCompletion.fulfill()
    },
      receiveValue: { action in
        if hasReceivedValue { XCTFail() }
        XCTAssertEqual(action, .loadedFavoritePrimes([2, 31]))
        nextAction = action
        hasReceivedValue = true
    })
    self.wait(for: [receivedCompletion], timeout: 0)

    effects = favoritePrimesReducer(state: &state, action: nextAction)

    XCTAssertEqual(state, [2, 31])
    XCTAssert(effects.isEmpty)
  }

}
