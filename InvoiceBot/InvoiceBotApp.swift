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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            let currentDate = Date.now

            guard let lastWorkingDayOfTheMonth = Date.getLastWorkingDayOfMonth(date: currentDate) else {
                return
            }

            let calendar = Calendar.current

            if granted, calendar.component(.day, from: currentDate) == lastWorkingDayOfTheMonth {
                DispatchQueue.main.async {
                    let bundleIdentifier = Bundle.main.bundleIdentifier

                    if let bundleIdentifier = bundleIdentifier,
                       let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier)
                    {
                        let configuration = NSWorkspace.OpenConfiguration()
                        NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
                    } else {
                        fatalError("Could not find application with bundle identifier \(bundleIdentifier ?? "unknown")")
                    }
                }

                let content = UNMutableNotificationContent()
                content.title = "Send an invoice"
                content.body = "It's time to send a new invoice!"
                content.sound = UNNotificationSound.default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString, content: content, trigger: trigger
                )

                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                return
            }

            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}
