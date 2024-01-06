import Combine
import Foundation

enum FetchableStatus {
    case loading
    case idle
    case fetching
    case success
    case error
}

struct FetchableResult<T> {
    var result: T?
    var status: FetchableStatus = .idle
    var error: Error?

    var isLoading: Bool {
        status == .loading
    }

    var isIdle: Bool {
        status == .idle
    }

    var isFetching: Bool {
        status == .fetching
    }
}

struct FetchableOptions {
    var staleTime = 10.0
    var cacheTime = 5 * 60.0
}

class Fetchable<T> {
    @Published var state: FetchableResult<T> = FetchableResult()
    var cache: FetchableCache = .shared

    private var cancellables: Set<AnyCancellable> = []
    private let cacheKey: Int
    private let options: FetchableOptions

    init(key: FetchableCacheKey, options: FetchableOptions = FetchableOptions()) {
        cacheKey = key.getHashedKey()
        self.options = options
    }

    func fetchData(_ fetchClosure: @escaping () -> AnyPublisher<T, Error>) -> AnyCancellable {
        if let cacheItem: FetchableCacheItem<T> = cache.get(key: cacheKey) {
            let timeSinceUpdate = Date().timeIntervalSince1970 - cacheItem.dataUpdatedAt

            if timeSinceUpdate < options.cacheTime {
                state = cacheItem.state

                if timeSinceUpdate < options.staleTime {
                    return AnyCancellable {}
                }

                state.status = .fetching
            } else {
                state.status = .loading
            }
        } else {
            state.status = .loading
        }

        return fetchClosure()
            .receive(on: DispatchQueue.main)
            .print("Fetchable")
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else {
                        return
                    }

                    switch completion {
                    case .failure(let error):
                        self.state.status = .error
                        self.state.error = error
                    case .finished:
                        self.state.status = self.state.result == nil ? .idle : .success
                    }

                    cache.set(
                        key: self.cacheKey,
                        value: FetchableCacheItem(
                            dataUpdatedAt: Date().timeIntervalSince1970,
                            state: self.state
                        )
                    )
                },
                receiveValue: { [weak self] value in
                    self?.state.result = value
                    self?.state.status = .success
                }
            )
    }

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
