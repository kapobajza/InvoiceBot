import Foundation

struct Invoice: Decodable, Encodable {
    var invoiceNumber: Int = 0
    var fiscalNumber: Int = 0
    var amountEuro: Double = 0.0
    var amountKM: Double = 0.0
    var issueDate: Date?

    init() {}

    init(_ invoiceFormView: InvoiceFormViewDTO) {
        invoiceNumber = Int(invoiceFormView.invoiceNumber) ?? 0
        fiscalNumber = Int(invoiceFormView.fiscalNumber) ?? 0
        amountEuro = NumberFormatter.amountNumberFormatter.number(from: invoiceFormView.amountEuro)?.doubleValue ?? 0.0
        amountKM = NumberFormatter.amountNumberFormatter.number(from: invoiceFormView.amountKM)?.doubleValue ?? 0.0
        issueDate = invoiceFormView.issueDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(invoiceNumber, forKey: .invoiceNumber)
        try container.encode(fiscalNumber, forKey: .fiscalNumber)
        try container.encode(amountEuro, forKey: .amountEuro)
        try container.encode(amountKM, forKey: .amountKM)
    }

    private enum CodingKeys: String, CodingKey {
        case invoiceNumber, fiscalNumber, amountEuro, amountKM
    }

    func jsonRepresentation() -> Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }

    func incrementValues() -> Invoice {
        var invoice = self
        invoice.invoiceNumber += 1
        invoice.fiscalNumber += 1
        return invoice
    }
}

struct InvoiceFormViewDTO: RouteParams {
    var invoiceNumber: String = ""
    var fiscalNumber: String = ""
    var amountEuro: String = ""
    var amountKM: String = ""
    var issueDate: Date?

    init(
        invoiceNumber: String,
        fiscalNumber: String,
        amountEuro: String,
        amountKM: String,
        issueDate: Date? = nil
    ) {
        self.invoiceNumber = invoiceNumber
        self.fiscalNumber = fiscalNumber
        self.amountEuro = amountEuro
        self.amountKM = amountKM
        self.issueDate = issueDate
    }

    init() {}

    init(_ data: Invoice) {
        amountKM = NumberFormatter.amountNumberFormatter.string(from: NSDecimalNumber(value: data.amountKM)) ?? "0"
        amountEuro = NumberFormatter.amountNumberFormatter.string(from: NSDecimalNumber(value: data.amountEuro)) ?? "0"
        invoiceNumber = String(data.invoiceNumber)
        fiscalNumber = String(data.fiscalNumber)
    }
}

struct MSEmailBody: Encodable {
    let contentType: String
    let content: String
}

struct MSEmailAddress: Encodable {
    let address: String
}

struct MSEmailRecipient: Encodable {
    let emailAddress: MSEmailAddress
}

struct MSAttachment: Encodable {
    let odataType: String
    let name: String
    let contentType: String
    let contentBytes: String

    enum CodingKeys: String, CodingKey {
        case odataType = "@odata.type"
        case name
        case contentType
        case contentBytes
    }
}

struct MSEmailMessage: Encodable {
    let subject: String
    let body: MSEmailBody
    let toRecipients: [MSEmailRecipient]
    let ccRecipients: [MSEmailRecipient]
    var attachments: [MSAttachment]
}

struct MSEmail: Encodable {
    let message: MSEmailMessage
}
