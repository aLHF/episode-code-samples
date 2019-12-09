import ComposableArchitecture
import SwiftUI

// MARK: - Environment
struct Environment {
  var favoritePrimesService = FavoritePrimesService()
}

var Current = Environment()

extension Environment {
  static let mock = Environment(favoritePrimesService: .mock)
}

// MARK: - FavoritePrimesService
struct FavoritePrimesService {
  var loadFavoritePrimes = loadFavoritePrimesFunc
  var saveFavoritePrimes = saveFavoritePrimesFunc
}

private func loadFavoritePrimesFunc() -> [Int]? {
  let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
  guard
    let data = try? Data(contentsOf: favoritePrimesUrl),
    let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return nil }

  return favoritePrimes
}

private func saveFavoritePrimesFunc(_ favoritePrimes: [Int]) {
  let data = try! JSONEncoder().encode(favoritePrimes)
  let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl.appendingPathComponent("favorite-primes.json")
  try! data.write(to: favoritePrimesUrl)
}

extension FavoritePrimesService {
  static let mock = FavoritePrimesService(
    loadFavoritePrimes: { return [67, 829, 5701, 12263, 13759] },
    saveFavoritePrimes: { favoritePrimes in print(favoritePrimes) }
  )
}
// ===

public enum FavoritePrimesAction: Equatable {
  case deleteFavoritePrimes(IndexSet)
  case loadButtonTapped
  case loadedFavoritePrimes([Int])
  case saveButtonTapped
}

public func favoritePrimesReducer(state: inout [Int], action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.remove(at: index)
    }
    return [
    ]

  case let .loadedFavoritePrimes(favoritePrimes):
    state = favoritePrimes
    return []

  case .saveButtonTapped:
    return [
      saveEffect(favoritePrimes: state)
    ]

  case .loadButtonTapped:
    return [
      loadEffect
        .compactMap { $0 }
        .eraseToEffect()
    ]
  }
}

private func saveEffect(favoritePrimes: [Int]) -> Effect<FavoritePrimesAction> {
  return .fireAndForget { Current.favoritePrimesService.saveFavoritePrimes(favoritePrimes) }
}

private let loadEffect = Effect<FavoritePrimesAction?>.sync {
  guard let favoritePrimes = Current.favoritePrimesService.loadFavoritePrimes() else { return nil }
  return .loadedFavoritePrimes(favoritePrimes)
}

public struct FavoritePrimesView: View {
  @ObservedObject var store: Store<[Int], FavoritePrimesAction>

  public init(store: Store<[Int], FavoritePrimesAction>) {
    self.store = store
  }

  public var body: some View {
    List {
      ForEach(self.store.value, id: \.self) { prime in
        Text("\(prime)")
      }
      .onDelete { indexSet in
        self.store.send(.deleteFavoritePrimes(indexSet))
      }
    }
    .navigationBarTitle("Favorite primes")
    .navigationBarItems(
      trailing: HStack {
        Button("Save") {
          self.store.send(.saveButtonTapped)
        }
        Button("Load") {
          self.store.send(.loadButtonTapped)
        }
      }
    )
  }
}
