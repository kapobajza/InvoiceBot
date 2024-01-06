import Foundation

extension Date {
    static func getLastDayOfMonth(date: Date) -> Date? {
        let calendar = Calendar.current

        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        if let firstDayOfNextMonth = calendar.date(
            from: DateComponents(year: year, month: month + 1, day: 1)
        ) {
            let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: firstDayOfNextMonth)
            return lastDayOfMonth
        }

        return nil
    }

    static func getLastWorkingDayOfMonth(date: Date) -> Int? {
        let calendar = Calendar.current

        guard let lastDayOfMonth = getLastDayOfMonth(date: date) else {
            return nil
        }

        var workingDay = lastDayOfMonth

        while true {
            let weekday = calendar.component(.weekday, from: workingDay)

            if weekday == 1 || weekday == 7 {
                let dayBefore = calendar.date(byAdding: .day, value: -1, to: workingDay)!
                workingDay = dayBefore
            } else {
                return calendar.component(.day, from: workingDay)
            }
        }
    }
}
