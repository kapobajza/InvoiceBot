import Combine
import XCTest

extension XCTestCase {
  func awaitPublisher<T>(_ publisher: AnyPublisher<T, Error>, timeout: TimeInterval = 5) -> T? {
    var result: Result<T, Error>?
    let expectation = self.expectation(description: "Awaiting publisher")

    let cancellable =
      publisher
      .print("awaitPublisher")
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            result = .failure(error)
          case .finished:
            break
          }

          expectation.fulfill()
        },
        receiveValue: { value in
          result = .success(value)
        }
      )

    waitForExpectations(timeout: timeout)
    cancellable.cancel()

    switch result {
    case .success(let value):
      return value

    case .failure, .none:
      return nil
    }
  }
}
