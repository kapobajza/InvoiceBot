import Foundation

extension FileManager {
  public static func getPdfSavePath(_ name: String) -> URL? {
    guard
      let downloadsDirectory = FileManager.default.urls(
        for: .downloadsDirectory, in: .userDomainMask
      ).first
    else {
      return nil
    }

    return downloadsDirectory.appendingPathComponent(name).appendingPathExtension("pdf")
  }
}
