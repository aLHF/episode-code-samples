import ComposableArchitecture
import SwiftUI

public typealias PrimeModalState = (count: Int, favoritePrimes: [Int], isPrime: Bool?)

public enum PrimeModalAction {
  case saveFavoritePrimeTapped
  case removeFavoritePrimeTapped
  case onAppear
  case setIsPrime(Bool)
}

public func primeModalReducer(state: inout PrimeModalState, action: PrimeModalAction) -> [Effect<PrimeModalAction>] {
  switch action {
  case .removeFavoritePrimeTapped:
    state.favoritePrimes.removeAll(where: { $0 == state.count })
    return []

  case .saveFavoritePrimeTapped:
    state.favoritePrimes.append(state.count)
    return []

  case .onAppear:
    return [
      isPrime(state.count)
        .receive(on: .main)
        .map { PrimeModalAction.setIsPrime($0) }
    ]

  case .setIsPrime(let isPrime):
    state.isPrime = isPrime
    return []
  }
}

public struct IsPrimeModalView: View {
  @ObservedObject var store: Store<PrimeModalState, PrimeModalAction>

  public init(store: Store<PrimeModalState, PrimeModalAction>) {
    self.store = store
  }

  public var body: some View {
    createView()
      .onAppear { self.store.send(.onAppear) }
  }

  private func createView() -> AnyView {
    guard let isPrime = store.value.isPrime else {
      return AnyView(Text("Calculating 👨🏻‍💻"))
    }

    let vstack = VStack {
      if isPrime {
        Text("\(self.store.value.count) is prime 🎉")
        if self.store.value.favoritePrimes.contains(self.store.value.count) {
          Button("Remove from favorite primes") {
            self.store.send(.removeFavoritePrimeTapped)
          }
        } else {
          Button("Save to favorite primes") {
            self.store.send(.saveFavoritePrimeTapped)
          }
        }
      } else {
        Text("\(self.store.value.count) is not prime :(")
      }
    }

    return AnyView(vstack)
  }
}

private func isPrime(_ p: Int) -> Effect<Bool> {
  return Effect<Bool> { callback in
    if p <= 1 { callback(false); return }
    if p <= 3 { callback(true); return }

    for i in 2...Int(sqrtf(Float(p))) {
      if p % i == 0 { callback(false); return }
    }

    callback(true)
  }
}
