import XCTest
@testable import BankingEngine

final class TransactionTests: XCTestCase {
    func testGivenTransactionWhenDateIsOldThenIsRecentFails() {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: "2023-05-27T18:00:00Z")
        else {
            XCTFail()
            return
        }
        
        let myTransaction = BankingEngine.Transaction(amount: 1.0, date: date, sourceAccount: 1, destinationAccount: 2, id: UUID(), type: BankingEngine.TransactionType.credit)
        
        XCTAssertFalse(myTransaction.isRecent())
    }
    
    func testGivenTransactionWhenDateIsRecentThenIsRecentSucceeds() {
        
        let dateInterval = Date().timeIntervalSince1970 - 29 * 24 * 3600
        let date = Date(timeIntervalSince1970: dateInterval)
        
        let myTransaction = BankingEngine.Transaction(amount: 1.0, date: date, sourceAccount: 1, destinationAccount: 2, id: UUID(), type: BankingEngine.TransactionType.credit)
        
        XCTAssertTrue(myTransaction.isRecent())
    }
}
