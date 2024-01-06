import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
  var html: String
  @State private var webView = WKWebView()

  func makeNSView(context: Context) -> WKWebView {
    let path = Bundle.main.path(forResource: "line_1_0", ofType: "png")

    var baseURL: URL?

    if let unwrappedPath = path {
      baseURL = URL(fileURLWithPath: unwrappedPath)
    }

    webView.loadHTMLString(html, baseURL: baseURL)
    return webView
  }

  func updateNSView(_ webView: WKWebView, context: Context) {}

  func createPDF(
    configuration: WKPDFConfiguration = .init(),
    completionHandler: @escaping (Result<Data, Error>) -> Void
  ) {
    webView.createPDF(configuration: configuration, completionHandler: completionHandler)
  }
}
