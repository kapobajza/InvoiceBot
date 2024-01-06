import Foundation

func getPdfInvoiceHTML(data: InvoiceFormViewDTO) -> String {
    let date = Date()
    let calendar = Calendar.current

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd.MM.yyyy"
    let issueDate = dateFormatter.string(from: data.issueDate ?? Date())
    let firstDayDate = calendar.date(
        from: calendar.dateComponents(
            [.year, .month], from: calendar.startOfDay(for: date)
        )
    )!
    let lastDayDate = Calendar.current.date(
        byAdding: DateComponents(month: 1, day: -1),
        to: firstDayDate
    )!

    let enDateFormatter = DateFormatter()
    enDateFormatter.dateFormat = "MMMM d yyyy"

    let enDescription =
        "Software engineering services for the period \(enDateFormatter.string(from: firstDayDate)) – \(enDateFormatter.string(from: lastDayDate))"

    let baDateFormatterFrom = DateFormatter()
    baDateFormatterFrom.dateFormat = "dd.MM."

    let baDateFormatterTo = DateFormatter()
    baDateFormatterTo.dateFormat = "dd.MM.yy"

    let baDescription =
        "Softwerske usluge za period \(baDateFormatterFrom.string(from: firstDayDate))-\(baDateFormatterTo.string(from: lastDayDate))"

    let invoiceHtmlPath = Bundle.main.path(forResource: "invoice", ofType: "html")
    let invoiceHtml = try! String(contentsOfFile: invoiceHtmlPath!, encoding: .utf8)

    let formatter = NumberFormatter.amountNumberFormatter
    let invoice = Invoice(data)
    formatter.groupingSeparator = ""

    let fromToAmountKM = formatter.string(
        from: invoice.amountKM as NSNumber
    ) ?? "0"

    let invoiceOccurenceMapping = [
        "invoiceNumber": String(format: "%04d", invoice.invoiceNumber),
        "fiscalNumber": data.fiscalNumber,
        "issueDate": issueDate,
        "enDescription": enDescription,
        "baDescription": baDescription,
        "totalEuro": data.amountEuro,
        "totalKM": data.amountKM,
        "fromToAmountKM": fromToAmountKM
    ]

    return invoiceOccurenceMapping.reduce(into: invoiceHtml) { result, mapping in
        result = result.replacingOccurrences(of: "##__\(mapping.key)__##", with: "\(mapping.value)")
    }
}
