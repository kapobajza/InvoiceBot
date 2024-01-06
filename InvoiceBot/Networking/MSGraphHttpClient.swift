import Foundation

class MSGraphHttpClient: HttpClient {
  init(storage: StorageProtocol) {
    super.init(
      baseUrl: "https://graph.microsoft.com/v1.0",
      storage: storage
    )
  }
}
