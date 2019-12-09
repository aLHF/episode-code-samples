import XCTest
@testable import FavoritePrimes

class FavoritePrimesTests: XCTestCase {
  func testDeleteFavoritePrimes() {
    var state = [2, 3, 5, 7]
    let effects = favoritePrimesReducer(state: &state, action: .deleteFavoritePrimes([2]))

    XCTAssertEqual(state, [2, 3, 7])
    XCTAssert(effects.isEmpty)
  }

  func testSaveButtonTapped() {
    var wasCalled = false
    let service = FavoritePrimesService(
      loadFavoritePrimes: { return nil },
      saveFavoritePrimes: { _ in wasCalled = true }
    )
    Current = Environment(favoritePrimesService: service)

    var state = [2, 3, 5, 7]
    let effects = favoritePrimesReducer(state: &state, action: .saveButtonTapped)

    let effectExpectation = expectation(description: "completion is called")
    _ = effects[0].sink(
      receiveCompletion: { _ in effectExpectation.fulfill() },
      receiveValue: { _ in XCTFail() }
    )

    wait(for: [effectExpectation], timeout: 1)

    XCTAssert(wasCalled)
    XCTAssertEqual(effects.count, 1)
    XCTAssertEqual(state, [2, 3, 5, 7])
  }

  func testLoadFavoritePrimesFlow() {
    var wasCalled = false
    let service = FavoritePrimesService(
      loadFavoritePrimes: { wasCalled = true; return nil },
      saveFavoritePrimes: { _ in }
    )
    Current = Environment(favoritePrimesService: service)

    var state = [2, 3, 5, 7]
    var effects = favoritePrimesReducer(state: &state, action: .loadButtonTapped)

    let effectExpectation = expectation(description: "completion is called")
    _ = effects[0].sink(
      receiveCompletion: { _ in effectExpectation.fulfill() },
      receiveValue: { _ in XCTAssertTrue(false) }
    )

    wait(for: [effectExpectation], timeout: 1)

    XCTAssertEqual(state, [2, 3, 5, 7])
    XCTAssertEqual(effects.count, 1)

    effects = favoritePrimesReducer(state: &state, action: .loadedFavoritePrimes([2, 31]))

    XCTAssert(wasCalled)
    XCTAssert(effects.isEmpty)
    XCTAssertEqual(state, [2, 31])
  }

}
