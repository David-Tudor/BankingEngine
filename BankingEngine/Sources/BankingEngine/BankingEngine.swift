import Foundation
import SwiftUI
import Combine
import CoreData

public class BankingEngine: ObservableObject {
    // objects
    public enum OperationError: Error {
        case accountNotFound
        case invalidId
        case invalidDeposit
        case invalidWithdrawl
        case genericError
        case noTransactionsFound
        case setupError
    }
    
    public enum TransactionType {
        case credit
        case debt
    }
    
    public struct Transaction: Equatable, Identifiable, Hashable {
        public typealias ID = UUID
        
        public let amount: Decimal
        public let date: Date
        public let sourceAccount: Account.ID?
        public let destinationAccount: Account.ID?
        public let id = UUID()//: Transaction.ID
        public var type: TransactionType?
        
        func isRecent() -> Bool {
            let threshold = Double(30 * 24 * 3600)
            return (Date().timeIntervalSince1970 - date.timeIntervalSince1970) <= threshold
        }
    }
    
    // properties
    
    private var accounts: [Account.ID: Account] = [:]
    private var transactions: [Transaction] = []
    
    public var allTransactions: CurrentValueSubject<[Transaction], Never> = .init([])
    private var moc: NSManagedObjectContext?
    
    // methods
    public func setup(moc: NSManagedObjectContext) {
        guard let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest() as? NSFetchRequest<Account> else { return }
        do {
            let fetchedAccounts = try moc.fetch(fetchRequest)
            
            fetchedAccounts.forEach { account in
                accounts[account.id] = account
            }
            
            self.moc = moc
            createInitialData()
            
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
    }
    
    public func createInitialData() {
        let hasInitalDataBeenSetup = UserDefaults.standard.bool(forKey: "hasInitalDataBeenSetup")
        guard !hasInitalDataBeenSetup else { return }
        do {
            try createAccount(id: 123, name: "David", balance: Decimal(10.00))
            try createAccount(id: 1, name: "James", balance: Decimal(30))
            UserDefaults.standard.setValue(true, forKey: "hasInitalDataBeenSetup")
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    public func createAccount(id: Account.ID, name: String, balance: Decimal) throws {
        if let _ = accounts[id] {
            throw OperationError.invalidId
        } else {
            guard let moc = moc else { throw OperationError.setupError }
            let account = Account(context: moc)
            account.id = id
            account.name = name
            account.balance = (Decimal(10)) as NSDecimalNumber
            try moc.save()
            accounts[id] = account
        }
    }
    
    public func getAccount(for id: Account.ID) throws -> Account {
        if let account = accounts[id] {
            return account
        }
        
        throw OperationError.accountNotFound
    }
    
    public func getBalance(for id: Account.ID) throws -> Decimal {
        if let account = accounts[id] {
            return account.balance.decimalValue
        }
        
        throw OperationError.accountNotFound
    }
    
    public func changeAccountName(for id: Account.ID, to newName: String) throws {
        if let account = accounts[id] {
            account.name = newName
            try moc?.save()
        }
        
        throw OperationError.accountNotFound
    }
    
    public func deposit(amount: Decimal, to id: Account.ID, shouldLogTransaction: Bool = true) throws {
        guard amount >= 0.0 else {
            throw OperationError.invalidDeposit
        }
        // dictionary is value type so make sure to add to the actual dictionary
        guard accounts[id] != nil, let balance = accounts[id]?.balance else {
            throw OperationError.accountNotFound
        }
        
        accounts[id]?.balance = NSDecimalNumber(decimal: balance.decimalValue + amount)
        
        if shouldLogTransaction {
            logTransaction(amount: amount, from: nil, to: id)
        }
    }

    public func withdrawal(amount: Decimal, from id: Account.ID, shouldLogTransaction: Bool = true) throws {
        
        guard
            accounts[id] != nil,
            let balance = accounts[id]?.balance
        else {
            throw OperationError.accountNotFound
        }
        
        let range = 0.0...balance.decimalValue
        
        guard range.contains(amount), let balance = accounts[id]?.balance else {
            throw OperationError.invalidWithdrawl
        }
        
        accounts[id]?.balance = NSDecimalNumber(decimal: balance.decimalValue - amount)
        if shouldLogTransaction {
            logTransaction(amount: amount, from: id, to: nil)
        }
    }
    
    public func transfer(amount: Decimal, from withdrawalId: Account.ID, to depositId: Account.ID) throws {
        
        guard withdrawalId != depositId else {
            throw OperationError.genericError
        }

        try self.withdrawal(amount: amount, from: withdrawalId, shouldLogTransaction: false)
        try self.deposit(amount: amount, to: depositId, shouldLogTransaction: false)
        
        logTransaction(amount: amount, from: withdrawalId, to: depositId)
    }
    
    // this is only used by deposit, withdrawal and transfer
    private func logTransaction(amount: Decimal, from sourceId: Account.ID?, to destinationId: Account.ID?) {
        
        let transaction = Transaction(amount: amount, date: Date(), sourceAccount: sourceId, destinationAccount: destinationId)//, id: UUID())
        
        transactions.append(transaction)
        allTransactions.send(transactions)
    }
    
    public func retrieveTransactions(accountId: Account.ID) throws -> [Transaction] {
        
        var retrievedTransactions =  transactions.filter {
            [$0.destinationAccount, $0.sourceAccount].contains(accountId) && $0.isRecent()
        }
        
        if retrievedTransactions.isEmpty {
            throw OperationError.noTransactionsFound
        }
        
        // set the transaction type for each
        for transactionIndex in 0..<retrievedTransactions.count {
            
            if retrievedTransactions[transactionIndex].sourceAccount == accountId {
                
                retrievedTransactions[transactionIndex].type = .debt
            } else {
                retrievedTransactions[transactionIndex].type = .credit
            }
        }
        
        return retrievedTransactions
    }
    

    public init() {
    }
}

public class Account: NSManagedObject {
    public typealias ID = Int
    
    @NSManaged public var id: Account.ID
    @NSManaged public var name: String
    @NSManaged public var balance: NSDecimalNumber

}


