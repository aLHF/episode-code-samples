import Combine
import SwiftUI

public struct Effect<Action> {
  let run: (@escaping (Action) -> Void) -> Void

  public init(run: @escaping (@escaping (Action) -> Void) -> Void) {
    self.run = run
  }

  public func map<NewAction>(_ transform: @escaping (Action) -> NewAction) -> Effect<NewAction> {
    return Effect<NewAction> { callback in self.run { action in callback(transform(action)) } }
  }

  public func flatMap<NewAction>(_ transform: @escaping (Action) -> Effect<NewAction> ) -> Effect<NewAction> {
    return Effect<NewAction> { callback in self.run { action in transform(action).run { callback($0) } } }
  }

  public func receive(on queue: DispatchQueue) -> Effect<Action> {
    return Effect<Action> { callback in self.run { value in queue.async { callback(value) } } }
  }

  static func zip<A, B>(_ ea: Effect<A>, _ eb: Effect<B>) -> Effect<(A, B)> {
    return Effect<(A, B)> { callback in
      var a: A?
      var b: B?

      ea.run { valueA in a = valueA; if let b = b { callback((valueA, b)) } }
      eb.run { valueB in b = valueB; if let a = a { callback((a, valueB)) } }
    }
  }
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

public final class Store<Value, Action>: ObservableObject {
  private let reducer: Reducer<Value, Action>
  @Published public private(set) var value: Value
  private var cancellable: Cancellable?

  public init(initialValue: Value, reducer: @escaping Reducer<Value, Action>) {
    self.reducer = reducer
    self.value = initialValue
  }

  public func send(_ action: Action) {
    let effects = self.reducer(&self.value, action)
    effects.forEach { effect in effect.run(self.send) }
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
        return []
    }
    )
    localStore.cancellable = self.$value.sink { [weak localStore] newValue in
      localStore?.value = toLocalValue(newValue)
    }
    return localStore
  }

  public func presentation<PresentedValue>(
    _ kp: KeyPath<Value, PresentedValue?>,
    dismissAction: Action
  ) -> Binding<Store<PresentedValue, Action>?> {
    return Binding<Store<PresentedValue, Action>?>(
      get: { () -> Store<PresentedValue, Action>? in
        guard let presentedValue = self.value[keyPath: kp] else { return nil }
        return Store<PresentedValue, Action>(initialValue: presentedValue, reducer: { _, _ in [] })
    },
      set: { _ in self.send(dismissAction) })
  }
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.flatMap { $0(&value, action) }
    return effects
  }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction>(
  _ reducer: @escaping Reducer<LocalValue, LocalAction>,
  value: WritableKeyPath<GlobalValue, LocalValue>,
  action: WritableKeyPath<GlobalAction, LocalAction?>
) -> Reducer<GlobalValue, GlobalAction> {
  return { globalValue, globalAction in
    guard let localAction = globalAction[keyPath: action] else { return [] }
    let localEffects = reducer(&globalValue[keyPath: value], localAction)
    return localEffects.map { localEffect -> Effect<GlobalAction> in
      return Effect<GlobalAction> { callback in
        localEffect.run { localAction in
          var globalAction = globalAction
          globalAction[keyPath: action] = localAction
          callback(globalAction)
        }
      }
    }
  }
}

public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    let newValue = value
    return [Effect { _ in
      print("Action: \(action)")
      print("Value:")
      dump(newValue)
      print("---")
      }] + effects
  }
}
