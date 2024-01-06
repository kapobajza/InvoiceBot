import Combine
import XCTest

@testable import InvoiceBot

final class LoginViewModelTests: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testIsLoggedTrueWhenTokenIsValid() throws {
    let msGraphHttpClient = HttpClientMock()
    let msAuth = MSAuthMock()

    msAuth.result = MSAuthAcquireTokenResult(accessToken: "test_access_token")

    let storage = StorageMock()

    let viewModel = LoginViewModel(
      msGraphHttpClient: msGraphHttpClient,
      msAuth: msAuth,
      storage: storage
    )

    let publisher = viewModel.fetchTokenPublisher()

    viewModel.initSession()

    let _ = self.awaitPublisher(
      publisher
    )

    XCTAssertTrue(viewModel.isLoggedIn)
  }

  func testIsLoggedFalseWhenTokenIsNil() throws {
    let msGraphHttpClient = HttpClientMock()
    let msAuth = MSAuthMock()

    msAuth.result = nil

    let storage = StorageMock()

    let viewModel = LoginViewModel(
      msGraphHttpClient: msGraphHttpClient,
      msAuth: msAuth,
      storage: storage
    )

    let publisher = viewModel.fetchTokenPublisher()

    viewModel.initSession()

    let _ = self.awaitPublisher(
      publisher
    )

    XCTAssertFalse(viewModel.isLoggedIn)
    XCTAssertNotNil(viewModel.acquireTokenSilentlyFetchable.state.error!)
  }
}
