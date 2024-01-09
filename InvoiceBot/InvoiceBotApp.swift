import ServiceManagement
import SwiftUI
import UserNotifications

@main
struct InvoiceBotApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var loginViewModel: LoginViewModel
    @StateObject private var invoiceFormViewModel: InvoiceFormViewModel
    @StateObject private var invoicePdfViewModel: InvoicePdfViewModel

    init() {
        let storage = Storage()
        let config = try! Config()
        let msGraphHttpClient = HttpClient(
            baseUrl: "https://graph.microsoft.com/v1.0",
            storage: storage
        )

        _loginViewModel = StateObject(
            wrappedValue: LoginViewModel(
                msGraphHttpClient: msGraphHttpClient,
                msAuth: MSAuth(config: config),
                storage: storage
            ))

        _invoiceFormViewModel = StateObject(
            wrappedValue: InvoiceFormViewModel(
                msGraphHttpClient: MSGraphHttpClient(storage: storage),
                config: config
            )
        )

        _invoicePdfViewModel = StateObject(
            wrappedValue: InvoicePdfViewModel(
                msGraphHttpClient: msGraphHttpClient,
                config: config
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(loginViewModel)
                .environmentObject(invoiceFormViewModel)
                .environmentObject(invoicePdfViewModel)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let loginItem = SMAppService.loginItem(identifier: "com.kapobajza.InvoiceBotAutoRunner")
        try! loginItem.register()
    }
}
