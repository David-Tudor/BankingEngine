import XCTest
@testable import BankingEngine

final class BankingEngineTests: XCTestCase {
    func testCreateAccount() {
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 12.39)
        
        XCTAssertEqual(try myBank.getAccount(for: 236528).name, "David")
    }
    
    func testGetAccountCanFail() {
        let myBank = BankingEngine()
        XCTAssertThrowsError(try myBank.getAccount(for: 1))
        
    }
    
    func testDeposit() throws {
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 1.0)
        
        try myBank.deposit(amount: 2.0, to: 236528)

        XCTAssertEqual(try myBank.getAccount(for: 236528).balance, 3.0)
        
    }
    
    func testCanDepositFail() {
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 1.0)
        
        XCTAssertThrowsError(try myBank.deposit(amount: -1.0, to: 236528))
        XCTAssertThrowsError(try myBank.deposit(amount: 1.0, to: 1))
    }
    
    func testWithdrawal() {
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 3.0)
        
        try? myBank.withdrawal(amount: 2.0, from: 236528)

        XCTAssertEqual(try myBank.getAccount(for: 236528).balance, 1.0)
        
    }
    
    func testCanWithdrawalFail() {
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 3.0)
        
        XCTAssertThrowsError(try myBank.withdrawal(amount: -1.0, from: 236528))
        XCTAssertThrowsError(try myBank.withdrawal(amount: 1.0, from: 1))
        XCTAssertThrowsError(try myBank.withdrawal(amount: 4.0, from: 236528))
        
    }
    
    func testTransfer() throws {
        let myBank = BankingEngine()
        myBank.createAccount(id: 1, name: "David", balance: 5.0)
        myBank.createAccount(id: 2, name: "Rolando", balance: 5.0)
        
        try myBank.transfer(amount: 4.0, from: 1, to: 2)
        XCTAssertEqual(try myBank.getAccount(for: 1).balance, 1.0)
        XCTAssertEqual(try myBank.getAccount(for: 2).balance, 9.0)
    }
    
    func testCanTransferFail() {
        let myBank = BankingEngine()
        myBank.createAccount(id: 1, name: "David", balance: 5.0)
        myBank.createAccount(id: 2, name: "Rolando", balance: 5.0)
        
        XCTAssertThrowsError(try myBank.transfer(amount: -1.0, from: 1, to: 2))
        XCTAssertThrowsError(try myBank.transfer(amount: 1.0, from: 11, to: 2))
        XCTAssertThrowsError(try myBank.transfer(amount: 1.0, from: 2, to: 2))
    }
    //: given...when...then
    func testGivenAccountWhenTransferringWithSameIdThenTransferFails() {
        // Given
        let myBank = BankingEngine()
        myBank.createAccount(id: 2, name: "Rolando", balance: 5.0)
        // When
        XCTAssertThrowsError(try myBank.transfer(amount: 1.0, from: 2, to: 2))
    }
    
    func testGivenAccountWhenWithdrawingThenTransactionIsLoggedAndRetrieved() throws {
        
        // Given
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 3.0)
        
        
        // When
        try? myBank.withdrawal(amount: 2.0, from: 236528)
        
        let myTransaction = try myBank.retrieveTransactions(accountId: 236528)[0]
       
        // Then
        XCTAssertEqual(myTransaction.amount, 2.0 )
        // transaction is older than current date, using Date()-1 fails and shows the times different by a second
        XCTAssertLessThanOrEqual(myTransaction.date, Date())
        XCTAssertEqual(myTransaction.sourceAccount, 236528 )
        XCTAssertNil(myTransaction.destinationAccount)
        XCTAssertEqual(myTransaction.type, BankingEngine.TransactionType.debt )
        
    }
    
    func testGivenAccountWhenDepositingThenTransactionIsLoggedAndRetrievable() throws {
        
        // Given
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 3.0)
        
        // When
        try? myBank.deposit(amount: 2.0, to: 236528)
        
        let myTransaction = try myBank.retrieveTransactions(accountId: 236528)[0]
       
        // Then
        XCTAssertEqual(myTransaction.amount, 2.0 )
        XCTAssertLessThanOrEqual(myTransaction.date , Date())
        XCTAssertNil(myTransaction.sourceAccount)
        XCTAssertEqual(myTransaction.destinationAccount, 236528 )
        XCTAssertEqual(myTransaction.type, BankingEngine.TransactionType.credit )
           
    }
    
    
    
    func testGivenAccountWhenNoTransactionsThenError () {
        // MADE TRANSACTION EQUATABLE
        
        // Given
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 3.0)
        
        // When
        // no transaction
        
        // Then
        XCTAssertThrowsError(try myBank.retrieveTransactions(accountId: 236528))
        
    }
    
    
    func testTransactionsOnOneAccountDoNotAffectAnother() throws {
        
        // Given
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 3.0)
        
        // When
        // no transactions for that id
        try myBank.withdrawal(amount: 2.0, from: 236528)
        
        // Then
        XCTAssertThrowsError(try myBank.retrieveTransactions(accountId: 1))
        XCTAssertEqual(try myBank.retrieveTransactions(accountId: 236528).count, 1)
    }
    
    // test for only showing recent transactions?
    // test for UUIDs?
    
    func testGetBalance() {
        let myBank = BankingEngine()
        myBank.createAccount(id: 236528, name: "David", balance: 12.39)
        
        XCTAssertEqual(try myBank.getBalance(for: 236528), 12.39)
    }
    
    func testGetBalanceCanFail() {
        let myBank = BankingEngine()
        XCTAssertThrowsError(try myBank.getBalance(for: 1))
        
    }
}
