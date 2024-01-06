

enum FetchableCacheEnum {
    case string(String)
    case int(Int)

    var value: String {
        switch self {
        case .string(let str):
            return str
        case .int(let num):
            return String(num)
        }
    }
}

struct FetchableCacheKey {
    var key: String
    var params: [FetchableCacheEnum]? = []

    init(_ key: String, params: FetchableCacheEnum...) {
        self.key = key
        self.params = params
    }

    init(key: String) {
        self.key = key
    }

    func getHashedKey() -> Int {
        var finalKey: String = key

        if let params = params {
            let paramsString = params.map { $0.value }.joined(separator: "_")
            finalKey = "\(key)_\(paramsString)"
        }

        return finalKey.hashValue
    }
}

protocol FetchableCacheItemProtocol {
    var dataUpdatedAt: Double { get }
}

struct FetchableCacheItem<T>: FetchableCacheItemProtocol {
    var dataUpdatedAt: Double
    var state: FetchableResult<T>
}

class FetchableCache {
    static let shared = FetchableCache()
    private var cache: [Int: FetchableCacheItemProtocol] = [:]

    private init() {}

    func get<T: FetchableCacheItemProtocol>(key: Int) -> T? {
        return cache[key] as? T
    }

    func set<T: FetchableCacheItemProtocol>(key: Int, value: T) {
        cache[key] = value
    }

    func clear() {
        cache.removeAll()
    }

    func clearByKey(_ key: FetchableCacheKey) {
        cache.removeValue(forKey: key.getHashedKey())
    }
}
