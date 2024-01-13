import Foundation

protocol ConfigProtocol {
    var msalClientID: String { get }
    var msalScopes: [String] { get }
    var authorityURL: URL { get }
    var oneDriveItemId: String { get }
    var emailRecipients: [String] { get }
    var companyName: String { get }
}

struct Config: ConfigProtocol, Decodable {
    let msalClientID: String
    let msalScopes: [String]
    let authorityURL: URL
    let oneDriveItemId: String
    let emailRecipients: [String]
    let companyName: String

    enum ConfigError: Error {
        case missingFile, decodingError(Error), invalidURL
    }

    enum CodingKeys: String, CodingKey {
        case msalClientID, msalScopes, authorityURL, oneDriveItemId, emailRecipients, companyName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        msalClientID = try container.decode(String.self, forKey: .msalClientID)
        msalScopes = try container.decode([String].self, forKey: .msalScopes)
        oneDriveItemId = try container.decode(String.self, forKey: .oneDriveItemId)
        emailRecipients = try container.decode([String].self, forKey: .emailRecipients)
        companyName = try container.decode(String.self, forKey: .companyName)

        let authorityURLString = try container.decode(String.self, forKey: .authorityURL)
        guard let url = URL(string: authorityURLString) else {
            throw ConfigError.invalidURL
        }
        authorityURL = url
    }

    init() throws {
        var env = "Dev"

        #if PRODUCTION
        env = "Prod"
        #endif

        guard let url = Bundle.main.url(forResource: "Config-\(env)", withExtension: "plist") else {
            throw ConfigError.missingFile
        }

        let data = try Data(contentsOf: url)
        let decoder = PropertyListDecoder()

        do {
            self = try decoder.decode(Config.self, from: data)
        } catch {
            throw ConfigError.decodingError(error)
        }
    }
}

class ConfigMock: ConfigProtocol {
    let msalClientID: String = ""
    let msalScopes: [String] = []
    let authorityURL: URL = .init(string: "https://example.com")!
    let oneDriveItemId: String = ""
    let emailRecipients: [String] = []
    let companyName: String = ""
}
