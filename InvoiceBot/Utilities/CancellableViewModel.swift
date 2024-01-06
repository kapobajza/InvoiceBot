import Combine
import Foundation

public class CancellableViewModel: ObservableObject {
  var cancellables: Set<AnyCancellable> = []

  func setupObservation<T>(for observer: Fetchable<T>) {
    observer
      .$state
      .sink { [weak self] _ in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
  }

  func onDisappear() {
    cancellables.forEach { $0.cancel() }
    cancellables.removeAll()
  }

  deinit {
    onDisappear()
  }
}
