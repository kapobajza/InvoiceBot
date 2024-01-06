import Combine
import Foundation
import MSAL
import SwiftUI

class LoginViewModel: CancellableViewModel {
    @Published var acquireTokenSilentlyFetchable = Fetchable<Bool>(key: FetchableCacheKey("silent-token"), options: FetchableOptions(cacheTime: 0))
    @Published var acquireTokenFetchable = Fetchable<String>(key: FetchableCacheKey("token"), options: FetchableOptions(cacheTime: 0))
    @Published var signoutFetcher = Fetchable<Void>(key: FetchableCacheKey("sign-out"), options: FetchableOptions(cacheTime: 0))
    @Published var isLoggedIn = false

    private let msGraphHttpClient: HttpClientProtocol
    private let msAuth: MSAuthProtocol
    private let storage: StorageProtocol

    init(
        msGraphHttpClient: HttpClientProtocol,
        msAuth: MSAuthProtocol,
        storage: StorageProtocol
    ) {
        self.msGraphHttpClient = msGraphHttpClient
        self.msAuth = msAuth
        self.storage = storage
        super.init()

        setupObservation(for: acquireTokenSilentlyFetchable)
        setupObservation(for: acquireTokenFetchable)
        setupObservation(for: signoutFetcher)

        Publishers
            .CombineLatest(
                acquireTokenSilentlyFetchable.$state,
                acquireTokenFetchable.$state
            )
            .map { silentTokenFetcher, tokenFetcher in
                silentTokenFetcher.result == true || tokenFetcher.result != nil
            }
            .assign(to: \.isLoggedIn, on: self)
            .store(in: &cancellables)
    }

    func signInWithMicrosoft() {
        acquireTokenFetchable.fetchData {
            self.msAuth
                .acquireToken()
                .map { result in
                    result.accessToken
                }
                .handleEvents(receiveOutput: { accessToken in
                    self.storage.save(key: .accessToken, value: accessToken)
                    self.isLoggedIn = true
                })
                .eraseToAnyPublisher()
        }.store(in: &cancellables)
    }

    func fetchTokenPublisher() -> AnyPublisher<Bool, Error> {
        return
            msAuth
                .acquireTokenSilently()
                .receive(on: DispatchQueue.main)
                .print("acquireTokenSilently")
                .handleEvents(receiveOutput: { result in
                    if !result.accessToken.isEmpty {
                        self.storage.save(key: .accessToken, value: result.accessToken)
                        self.isLoggedIn = true
                    }
                })
                .map { result in
                    !result.accessToken.isEmpty
                }
                .eraseToAnyPublisher()
    }

    func initSession() {
        acquireTokenSilentlyFetchable.fetchData {
            self.fetchTokenPublisher()
        }
        .store(in: &cancellables)
    }

    func signOut() {
        signoutFetcher.fetchData {
            self.msAuth
                .signOut()
                .receive(on: DispatchQueue.main)
                .handleEvents(receiveOutput: { _ in
                    self.storage.remove(key: .accessToken)
                    self.acquireTokenFetchable.state.result = nil
                    self.acquireTokenSilentlyFetchable.state.result = nil
                })
                .eraseToAnyPublisher()
        }.store(in: &cancellables)
    }
}
