
import SwiftUI

struct ContentView: View {
  @ObservedObject var state: AppState
  
  var body: some View {
    NavigationView {
      List {
        NavigationLink(destination: CounterView(state: self.state)) {
          Text("Counter demo")
        }
        NavigationLink(destination: EmptyView()) {
          Text("Favorite primes")
        }
      }
      .navigationBarTitle("State management")
    }
  }
}

private func ordinal(_ n: Int) -> String {
  let formatter = NumberFormatter()
  formatter.numberStyle = .ordinal
  return formatter.string(for: n) ?? ""
}

//BindableObject

import Combine

class AppState: ObservableObject {
  @Published var count = 0
}



struct IsPrimeModalView: View {
  @ObservedObject var state: AppState
  
  var body: some View {
    Text("I don't know if \(self.state.count) is a prime.")
  }
}

import PlaygroundSupport

PlaygroundPage.current.liveView = UIHostingController(
  rootView: ContentView(state: AppState())
  //  rootView: CounterView()
)
