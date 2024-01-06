import XCTest

@testable import InvoiceBot

final class EmailUtilitiesTests: XCTestCase {
    func testExtractextractEmailRecipients() {
        let emails = ["test@email.com, someone@email.com"]
        let emailRecipients = extractEmailRecipients(emails)
        XCTAssert(emailRecipients.count == 1)
        XCTAssert(emailRecipients[0].to.count == 2)
    }

    func testExtractextractEmailRecipientsWithCC() {
        let emails = ["test@email.com, cc: ccing@email.com"]
        let emailRecipients = extractEmailRecipients(emails)
        XCTAssert(emailRecipients.count == 1)
        XCTAssert(emailRecipients[0].to.count == 1)
        XCTAssert(emailRecipients[0].cc.count == 1)
    }

    func testExtractextractMultipleEmailRecipients() {
        let emails = [
            "test@email.com, do@email.com, cc: ccing@email.com",
            "my@email.com",
            "some_other@email.com, howdie@gmail.com, cc: hello@world.com, testing@test.com"
        ]
        let emailRecipients = extractEmailRecipients(emails)
        XCTAssert(emailRecipients.count == 3)
        XCTAssert(emailRecipients[0].to.count == 2)
        XCTAssert(emailRecipients[0].cc.count == 1)
        XCTAssert(emailRecipients[1].to.count == 1)
        XCTAssert(emailRecipients[1].cc.count == 0)
        XCTAssert(emailRecipients[2].to.count == 2)
        XCTAssert(emailRecipients[2].cc.count == 2)
    }
}
