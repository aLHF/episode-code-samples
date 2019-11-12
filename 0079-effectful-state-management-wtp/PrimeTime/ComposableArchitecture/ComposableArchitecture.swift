import Combine
import SwiftUI


struct Parallel<A> {
  let run: (@escaping (A) -> Void) -> Void
}

//DispatchQueue.main.async(execute: <#T##() -> Void#>) -> Void
//UIView.animate(withDuration: <#T##TimeInterval#>, animations: <#T##() -> Void#>) -> Void
//URLSession.shared.dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>) -> Void

//public typealias Effect<Action> = (@escaping (Action) -> Void) -> Void

private var unfairLock = os_unfair_lock()
private var isCancelled: [AnyHashable: DispatchWorkItem] = [:]

public struct Effect<A> {
  public let run: (@escaping (A) -> Void) -> Void

  public init(run: @escaping (@escaping (A) -> Void) -> Void) {
    self.run = run
  }

  public func map<B>(_ f: @escaping (A) -> B) -> Effect<B> {
    return Effect<B> { callback in self.run { a in callback(f(a)) } }
  }

  public func run(on queue: DispatchQueue) -> Effect {
    return Effect { callback in queue.async { self.run { a in callback(a) } } }
  }

  public func cancellable(id: AnyHashable) -> Effect {
    return Effect { callback in
      let item = self.dispatchItem(callback: callback)
      os_unfair_lock_lock(&unfairLock)
      isCancelled[id] = item
      os_unfair_lock_unlock(&unfairLock)
      item.perform()
    }
  }

  public static func cancel(id: AnyHashable) -> Effect {
    return Effect { _ in
      os_unfair_lock_lock(&unfairLock)
      isCancelled[id]?.cancel()
      os_unfair_lock_unlock(&unfairLock)
    }
  }

  private func dispatchItem(callback: @escaping (A) -> Void) -> DispatchWorkItem {
    return DispatchWorkItem { self.run { a in callback(a) } }
  }

  public func debounce<ID: Hashable>(for duration: TimeInterval, id: ID) -> Effect {
    return Effect { callback in
      let item = self.dispatchItem(callback: callback)

      os_unfair_lock_lock(&unfairLock)
      isCancelled[id]?.cancel()
      isCancelled[id] = item
      os_unfair_lock_unlock(&unfairLock)
      DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
    }
  }
}

extension Effect where A == Never {
  func fireAndForget<B>() -> Effect<B> {
    return Effect<B> { _ in self.run { _ in } }
  }
}

public typealias Reducer<Value, Action> = (inout Value, Action) -> [Effect<Action>]

//Button.init("Save", action: <#T##() -> Void#>)

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
    effects.forEach { effect in
      effect.run(self.send)
    }
//    DispatchQueue.global().async {
//      effects.forEach { effect in
//        if let action = effect() {
//          DispatchQueue.main.async {
//            self.send(action)
//          }
//        }
//      }
//    }
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
}

public func combine<Value, Action>(
  _ reducers: Reducer<Value, Action>...
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducers.flatMap { $0(&value, action) }
    return effects
//    return { () -> Action? in
//      var finalAction: Action?
//      for effect in effects {
//        let action = effect()
//        if let action = action {
//          finalAction = action
//        }
//      }
//      return finalAction
//    }
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

    return localEffects.map { localEffect in
      Effect { callback in
//        guard let localAction = localEffect() else { return nil }
        localEffect.run { localAction in
          var globalAction = globalAction
          globalAction[keyPath: action] = localAction
          callback(globalAction)
        }
      }
    }

//    return effect
  }
}

struct AnalyticsClient {
  let track: (String) -> Effect<Never>
}

extension AnalyticsClient {
  static let live: AnalyticsClient = AnalyticsClient(track: { event in Effect { _ in print(event) } })
}


public func logging<Value, Action>(
  _ reducer: @escaping Reducer<Value, Action>
) -> Reducer<Value, Action> {
  return { value, action in
    let effects = reducer(&value, action)
    return [AnalyticsClient.live.track("-----\nAction: \(action)\n-----").fireAndForget()] + effects
  }
}
