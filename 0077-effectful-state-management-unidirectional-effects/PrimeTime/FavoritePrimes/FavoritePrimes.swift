import ComposableArchitecture
import SwiftUI

extension DateFormatter {
  static let saveTime: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return dateFormatter
  }()
}

public enum FavoritePrimesAction {
  case deleteFavoritePrimes(IndexSet)
  case loadButtonTapped
  case loadedFavoritePrimes([Int])
  case saveButtonTapped
  case readSaveDate
  case setSaveDate(String)
}

public func favoritePrimesReducer(state: inout ([Int], String?), action: FavoritePrimesAction) -> [Effect<FavoritePrimesAction>] {
  switch action {
  case let .deleteFavoritePrimes(indexSet):
    for index in indexSet {
      state.0.remove(at: index)
    }
    return []

  case let .loadedFavoritePrimes(favoritePrimes):
    state.0 = favoritePrimes
    return []

  case .saveButtonTapped:
    return [saveEffect(favoritePrimes: state)]

  case .readSaveDate:
    return [readSaveDateEffect]

  case .setSaveDate(let date):
    state.1 = date
    return []

  case .loadButtonTapped:
    return [loadEffect, readSaveDateEffect]
  }
}

private let readSaveDateEffect: Effect<FavoritePrimesAction> = {
  guard let date = UserDefaults.standard.string(forKey: "save-date") else { return nil }
  return .setSaveDate(date)
}

private func saveEffect(favoritePrimes: ([Int], String?)) -> Effect<FavoritePrimesAction> {
  return {
    let data = try! JSONEncoder().encode(favoritePrimes.0)
    let documentsPath = NSSearchPathForDirectoriesInDomains(
      .documentDirectory, .userDomainMask, true
      )[0]
    let documentsUrl = URL(fileURLWithPath: documentsPath)
    let favoritePrimesUrl = documentsUrl
      .appendingPathComponent("favorite-primes.json")
    try! data.write(to: favoritePrimesUrl)

    let saveDate = DateFormatter.saveTime.string(from: Date())
    UserDefaults.standard.set(saveDate, forKey: "save-date")

    return .setSaveDate(saveDate)
  }
}

private let loadEffect: Effect<FavoritePrimesAction> = {
  let documentsPath = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    )[0]
  let documentsUrl = URL(fileURLWithPath: documentsPath)
  let favoritePrimesUrl = documentsUrl
    .appendingPathComponent("favorite-primes.json")
  guard
    let data = try? Data(contentsOf: favoritePrimesUrl),
    let favoritePrimes = try? JSONDecoder().decode([Int].self, from: data)
    else { return nil }
  return .loadedFavoritePrimes(favoritePrimes)
}

public struct FavoritePrimesView: View {
  @ObservedObject var store: Store<([Int], String?), FavoritePrimesAction>

  public init(store: Store<([Int], String?), FavoritePrimesAction>) {
    self.store = store

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      store.send(.readSaveDate)
    }
  }

  public var body: some View {
    VStack {
      Text("\(self.store.value.1 ?? "Haven't been saved")")
      List {
        ForEach(self.store.value.0, id: \.self) { prime in
          Text("\(prime)")
        }
        .onDelete { indexSet in
          self.store.send(.deleteFavoritePrimes(indexSet))
        }
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
        .disabled(self.store.value.1 == nil)
      }
    )
  }
}

