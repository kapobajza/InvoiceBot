import Foundation

extension NumberFormatter {
    static let amountNumberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.decimalSeparator = "."
        numberFormatter.groupingSeparator = ","
        return numberFormatter
    }()
}
