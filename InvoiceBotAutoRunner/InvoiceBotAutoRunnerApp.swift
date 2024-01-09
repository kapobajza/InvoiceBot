import ServiceManagement
import SwiftUI
import UserNotifications

@main
struct InvoiceBotAutoRunnerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        #if !DEBUG
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                let currentDate = Date.now

                guard let lastWorkingDayOfTheMonth = Date.getLastWorkingDayOfMonth(date: currentDate) else {
                    return
                }

                let calendar = Calendar.current

                if granted, calendar.component(.day, from: currentDate) == lastWorkingDayOfTheMonth {
                    DispatchQueue.main.async {
                        let bundleIdentifier = "com.kapobajza.InvoiceBot"

                        if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
                            let configuration = NSWorkspace.OpenConfiguration()
                            NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
                        } else {
                            fatalError("Could not find application with bundle identifier \(bundleIdentifier)")
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

                DispatchQueue.main.async {
                    NSApp.terminate(nil)
                }
            }
        #endif
    }
}
