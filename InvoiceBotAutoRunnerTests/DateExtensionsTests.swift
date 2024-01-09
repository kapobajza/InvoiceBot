import XCTest

@testable import InvoiceBotAutoRunner

final class DateExtensionsTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLastDayOfOctoberShouldBeThirtyOne() {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2021, month: 10, day: 25))!

        guard let lastDayOfMonth = Date.getLastDayOfMonth(date: currentDate) else {
            XCTFail("Failed to get last day of month")
            return
        }

        let lastDayOfMonthYear = calendar.component(.year, from: lastDayOfMonth)
        let lastDayOfMonthMonth = calendar.component(.month, from: lastDayOfMonth)
        let lastDayOfMonthDay = calendar.component(.day, from: lastDayOfMonth)

        XCTAssertEqual(lastDayOfMonthYear, 2021)
        XCTAssertEqual(lastDayOfMonthMonth, 10)
        XCTAssertEqual(lastDayOfMonthDay, 31)
    }

    func testLastDayWithMarginalityOfOctoberShouldBeThirtyOne() {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2021, month: 10, day: 31, hour: 0))!

        guard let lastDayOfMonth = Date.getLastDayOfMonth(date: currentDate)
        else {
            XCTFail("Failed to get last day of month")
            return
        }

        let lastDayOfMonthYear = calendar.component(.year, from: lastDayOfMonth)
        let lastDayOfMonthMonth = calendar.component(.month, from: lastDayOfMonth)
        let lastDayOfMonthDay = calendar.component(.day, from: lastDayOfMonth)

        XCTAssertEqual(lastDayOfMonthYear, 2021)
        XCTAssertEqual(lastDayOfMonthMonth, 10)
        XCTAssertEqual(lastDayOfMonthDay, 31)
    }

    func testLastWorkingDayAndWeekdayOfOctoberTwentyTwentyThree() {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2023, month: 10, day: 25))!

        guard let lastWorkingDayOfMonth = Date.getLastWorkingDayOfMonth(date: currentDate) else {
            XCTFail("Failed to get last day of month and weekday")
            return
        }

        XCTAssertEqual(lastWorkingDayOfMonth, 31)
    }

    func testLastWorkingDayAndWeekdayOfNovemberTwentyTwentyThree() {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2023, month: 11, day: 25))!

        guard let lastWorkingDayOfMonth = Date.getLastWorkingDayOfMonth(date: currentDate) else {
            XCTFail("Failed to get last day of month and weekday")
            return
        }

        XCTAssertEqual(lastWorkingDayOfMonth, 30)
    }

    func testLastWorkingDayAndWeekdayOfNovemberTwentyTwentyThreeWithMarginality() {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2023, month: 11, day: 30, hour: 0))!

        guard let lastWorkingDayOfMonth = Date.getLastWorkingDayOfMonth(date: currentDate) else {
            XCTFail("Failed to get last day of month and weekday")
            return
        }

        XCTAssertEqual(lastWorkingDayOfMonth, 30)
    }

    func testLastWorkingDayAndWeekdayOfDecemberTwentyTwentyThree() {
        let calendar = Calendar.current
        let currentDate = calendar.date(from: DateComponents(year: 2023, month: 12, day: 25))!

        guard let lastWorkingDayOfMonth = Date.getLastWorkingDayOfMonth(date: currentDate) else {
            XCTFail("Failed to get last day of month and weekday")
            return
        }

        let lastWorkingDayDate = calendar.date(from: DateComponents(year: 2023, month: 12, day: 29))!

        XCTAssertEqual(lastWorkingDayOfMonth, calendar.component(.day, from: lastWorkingDayDate))
    }
}
