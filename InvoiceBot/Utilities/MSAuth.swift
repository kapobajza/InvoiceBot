import Combine
import Foundation
import MSAL

struct MSAuthAcquireTokenResult {
  var accessToken: String
}

typealias MSAuthAcquireTokenCompletionBlock = (MSAuthAcquireTokenResult?, Error?) -> Void

protocol MSAuthProtocol {
  func acquireTokenSilently() -> AnyPublisher<MSAuthAcquireTokenResult, Error>
  func acquireToken() -> AnyPublisher<MSAuthAcquireTokenResult, Error>
  func signOut() -> AnyPublisher<Void, Error>
}

class MSAuth: MSAuthProtocol {
  private let config: ConfigProtocol

  init(config: ConfigProtocol) {
    self.config = config
  }

  private func publicClientApplication() throws -> MSALPublicClientApplication {
    let msalAuthority = try MSALAADAuthority(url: config.authorityURL)
    let configuration = MSALPublicClientApplicationConfig(
      clientId: config.msalClientID,
      redirectUri: nil,
      authority: msalAuthority
    )
    return try MSALPublicClientApplication(configuration: configuration)
  }

  private func acquireTokenCompletion(
    result: MSALResult?,
    _ error: Error?,
    _ promise: @escaping (Result<MSAuthAcquireTokenResult, Error>) -> Void
  ) {
    if let result = result {
      promise(.success(MSAuthAcquireTokenResult(accessToken: result.accessToken)))
    } else {
      promise(
        .failure(
          error
            ?? NSError(
              domain: "MSAuth - acquireTokenCompletion",
              code: 0,
              userInfo: [NSLocalizedDescriptionKey: "An error occurred acquiring the token"]
            )
        )
      )
    }
  }

  func acquireToken() -> AnyPublisher<MSAuthAcquireTokenResult, Error> {
    return Future { promise in
      do {
        let pca = try self.publicClientApplication()
        let parameters = MSALInteractiveTokenParameters(scopes: self.config.msalScopes)

        pca.acquireToken(with: parameters) { result, err in
          self.acquireTokenCompletion(result: result, err, promise)
        }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }

  func acquireTokenSilently() -> AnyPublisher<MSAuthAcquireTokenResult, Error> {
    return Future { promise in
      do {
        let pca = try self.publicClientApplication()
        let application = try MSALPublicClientApplication(clientId: self.config.msalClientID)
        let account = try application.allAccounts().first

        if let account = account {
          let silentParameters = MSALSilentTokenParameters(
            scopes: self.config.msalScopes, account: account
          )
          pca.acquireTokenSilent(with: silentParameters) { result, err in
            self.acquireTokenCompletion(result: result, err, promise)
          }
        } else {
          promise(
            .failure(
              NSError(
                domain: "MSAuth - acquireTokenSilently",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No accounts available"]
              )
            )
          )
        }
      } catch {
        promise(.failure(error))
      }
    }
    .eraseToAnyPublisher()
  }

  func signOut() -> AnyPublisher<Void, Error> {
    return Future { promise in
      do {
        let pca = try self.publicClientApplication()
        let application = try MSALPublicClientApplication(clientId: self.config.msalClientID)
        let account = try application.allAccounts().first
        let parameters = MSALSignoutParameters()

        if let account = account {
          pca.signout(with: account, signoutParameters: parameters) { _, error in
            if let error = error {
              promise(.failure(error))
            } else {
              promise(.success(()))
            }
          }
        } else {
          promise(
            .failure(
              NSError(
                domain: "MSAuth - signOut",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "No accounts available"]
              )
            )
          )
        }
      } catch {
        promise(.failure(error))
      }
    }.eraseToAnyPublisher()
  }
}

class MSAuthMock: MSAuthProtocol {
  var result: MSAuthAcquireTokenResult?
  var error: Error?

  func acquireTokenSilently() -> AnyPublisher<MSAuthAcquireTokenResult, Error> {
    return Future { promise in
      if let result = self.result {
        return promise(.success(result))
      } else if let error = self.error {
        return promise(.failure(error))
      } else {
        return promise(
          .failure(NSError(domain: "MSAuthMock - acquireTokenSilently", code: 0, userInfo: nil)))
      }
    }.eraseToAnyPublisher()
  }

  func acquireToken() -> AnyPublisher<MSAuthAcquireTokenResult, Error> {
    return Future { promise in
      if let result = self.result {
        return promise(.success(result))
      } else if let error = self.error {
        return promise(.failure(error))
      } else {
        return promise(
          .failure(NSError(domain: "MSAuthMock - acquireToken", code: 0, userInfo: nil)))
      }
    }.eraseToAnyPublisher()
  }

  func signOut() -> AnyPublisher<Void, Error> {
    return Future { promise in
      if let error = self.error {
        return promise(.failure(error))
      } else {
        return promise(.success(()))
      }
    }.eraseToAnyPublisher()
  }
}
