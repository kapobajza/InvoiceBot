import Foundation

enum StorageKey: String {
  case accessToken
}

protocol StorageProtocol {
  func save<T: Encodable>(key: StorageKey, value: T)
  func get<T: Decodable>(key: StorageKey) -> T?
  func remove(key: StorageKey)
}

class Storage: StorageProtocol {
  func save<T: Encodable>(key: StorageKey, value: T) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(value) {
      UserDefaults.standard.set(encoded, forKey: key.rawValue)
    }
  }

  func get<T: Decodable>(key: StorageKey) -> T? {
    if let data = UserDefaults.standard.data(forKey: key.rawValue) {
      let decoder = JSONDecoder()
      if let decoded = try? decoder.decode(T.self, from: data) {
        return decoded
      }
    }
    return nil
  }

  func remove(key: StorageKey) {
    UserDefaults.standard.removeObject(forKey: key.rawValue)
  }
}

class StorageMock: StorageProtocol {
  func save<T: Encodable>(key: StorageKey, value: T) {}
  func get<T: Decodable>(key: StorageKey) -> T? { nil }
  func remove(key: StorageKey) {}
}
