import Foundation

struct ExtractedEmailRecipient {
    var to: [MSEmailRecipient]
    var cc: [MSEmailRecipient]
}

func extractEmailRecipients(_ emailRecipients: [String]) -> [ExtractedEmailRecipient] {
    return emailRecipients.map { email in
        let emails = email.split(separator: "cc:")
        var toEmails: [MSEmailRecipient] = []
        var ccEmails: [MSEmailRecipient] = []

        if emails.count > 2 {
            fatalError("Inavalid email format: \(emails)")
        }

        let toSeparated = emails.first?.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")

        if let toSeparated = toSeparated, !toSeparated.isEmpty {
            toEmails = toSeparated.map { toEmail in
                MSEmailRecipient(
                    emailAddress: MSEmailAddress(address: String(toEmail))
                )
            }
        }

        if emails.count > 1 {
            let ccSeparated = emails.last?.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ",")

            if let ccSeparated = ccSeparated, !ccSeparated.isEmpty {
                ccEmails = ccSeparated.map { ccEmail in
                    MSEmailRecipient(
                        emailAddress: MSEmailAddress(address: String(ccEmail))
                    )
                }
            }
        }

        return ExtractedEmailRecipient(to: toEmails, cc: ccEmails)
    }
}
