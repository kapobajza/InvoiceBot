import Combine
import XCTest

@testable import InvoiceBot

final class GenericDataFetcherTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchDataSuccess() throws {
        let dataFetcher = Fetchable<String>(key: FetchableCacheKey(key: "test"))

        let successPublisher = Just("Success")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let cancellable = dataFetcher.fetchData {
            successPublisher
        }

        let result = awaitPublisher(successPublisher)

        XCTAssertNotNil(result)
        XCTAssertTrue(!result!.isEmpty)

        cancellable.cancel()
    }

    func testFetchDataFailure() {
        let dataFetcher = Fetchable<String>(key: FetchableCacheKey(key: "test"))

        let failurePublisher = Fail<String, Error>(
            error: NSError(domain: "Test", code: 0, userInfo: nil)
        )
        .eraseToAnyPublisher()

        let cancellable = dataFetcher.fetchData {
            failurePublisher
        }

        let result = awaitPublisher(failurePublisher)

        XCTAssertNil(result)

        cancellable.cancel()
    }
}
