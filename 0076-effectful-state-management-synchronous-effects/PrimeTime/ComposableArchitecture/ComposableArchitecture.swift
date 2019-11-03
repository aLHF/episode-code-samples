import Combine
import SwiftUI

public typealias Effect<Value> = (inout Value) -> Void

public typealias Reducer<Value, Action> = (inout Value, Action) -> Effect<Value>

//Button.init("Save", action: <#() -> Void#>)

public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action>
  @Published public private(set) var value: Value
  private var cancellable: Cancellable?

  public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
    self.reducer = reducer
    self.value = initialValue
  }

  public func send(_ action: Action) {
    let effect = self.reducer(&self.value, action)
    effect(&value)
  }

  public func view<LocalValue, LocalAction>(
    value toLocalValue: @escaping (Value) -> LocalValue,
    action toGlobalAction: @escaping (LocalAction) -> Action
  ) -> Store<LocalValue, LocalAction> {
    let localStore = Store<LocalValue, LocalAction>(
      initialValue: toLocalValue(self.value),
      reducer: { localValue, localAction in
        self.send(toGlobalAction(localAction))
        localValue = toLocalValue(self.value)
        return { _ in }
    }
    )
    localStore.cancellable = self.$value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.map { $0(&value, action) }
    return { someValue in
      for effect in effects {
        effect(&someValue)
      }
    }
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return { _ in } }
    let effect = reducer(&globalValue[keyPath: value], localAction)
    return { globalVal in
      var localVal = globalVal[keyPath: value]
      effect(&localVal)
      globalVal[keyPath: value] = localVal
    }
  }
}

public func pure<State, Action>(
  _ reducer: @escaping (inout State, Action) -> Void
) -> Reducer<State, Action> {
  return { state, action in
    reducer(&state, action)
    return { _ in }
  }
}

//public func logging<Value, Action>(
//  _ reducer: @escaping Reducer<Value, Action>
//) -> Reducer<Value, Action> {
//  return { value, action in
//    let effect = reducer(&value, action)
//    #warning("newValue is a var and is passed to an escaping closure. It can be mutated unexpectedly")
//    var newValue = value
//    return { _ in
//      print("Action: \(action)")
//      print("Value:")
//      dump(newValue)
//      print("---")
//      effect(&newValue)
//    }
//  }
//}
