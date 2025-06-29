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
        case transactionNotLogged
    }
    
    // properties
    private var accounts: [Account.ID: Account] = [:]
    private var transactions: [BankTransaction] = []
    public var allTransactions: CurrentValueSubject<[BankTransaction], Never> = .init([])
    private var moc: NSManagedObjectContext?
    
    // methods
    public func setup(moc: NSManagedObjectContext) {
        guard let accountFetchRequest: NSFetchRequest<Account> = Account.fetchRequest() as? NSFetchRequest<Account> else { return }
        self.moc = moc
        do {
            let fetchedAccounts = try moc.fetch(accountFetchRequest)
            
            fetchedAccounts.forEach { account in
                accounts[account.id] = account
            }
 
            createInitialData()
            
        } catch {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
        
        guard let transactionFetchRequest: NSFetchRequest<BankTransaction> = BankTransaction.fetchRequest() as? NSFetchRequest<BankTransaction> else { return }
        do {
            let fetchedTransactions = try moc.fetch(transactionFetchRequest)
            
            transactions = fetchedTransactions
            allTransactions.send(transactions)
            
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
        // don't allow if id is taken or negative
        if let _ = accounts[id] {
            throw OperationError.invalidId
            
        } else if id < 0 {
            throw OperationError.invalidId
            
        } else {
            guard let moc = moc else { throw OperationError.setupError }
            let account = Account(context: moc)
            account.id = id
            account.name = name
            account.balance = (Decimal(10)) as NSDecimalNumber // LATER CHANGE STARTING BALANCE
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
            try logTransaction(amount: amount, from: -1, to: id) // can't have nil ids, so negative used to show impossible accounts
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
            try logTransaction(amount: amount, from: id, to: -1) // can't have nil ids, so negative used to show impossible accounts
        }
    }
    
    public func transfer(amount: Decimal, from withdrawalId: Account.ID, to depositId: Account.ID) throws {
        
        guard withdrawalId != depositId else {
            throw OperationError.genericError
        }

        try self.withdrawal(amount: amount, from: withdrawalId, shouldLogTransaction: false)
        try self.deposit(amount: amount, to: depositId, shouldLogTransaction: false)
        
        try logTransaction(amount: amount, from: withdrawalId, to: depositId)
    }
    
    // this is only used by deposit, withdrawal and transfer
    private func logTransaction(amount: Decimal, from sourceId: Account.ID, to destinationId: Account.ID) throws {
        
        guard let moc = moc else { //, let sourceId = sourceId, let destinationId = destinationId
            throw OperationError.transactionNotLogged}
        let transaction = BankTransaction(context: moc)
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.sourceId = sourceId
        transaction.destinationId = destinationId
        transaction.date = Date()
        transaction.id = UUID()
        try moc.save()
        
        transactions.append(transaction)
        allTransactions.send(transactions)

    }
    
    public func retrieveTransactions(accountId: Account.ID) throws -> [BankTransaction] {
        
        let retrievedTransactions =  transactions.filter {
            [$0.destinationId, $0.sourceId].contains(accountId) && $0.isRecent()
        }
        
        if retrievedTransactions.isEmpty {
            throw OperationError.noTransactionsFound
        }
        
        // sets the transaction type for each transaction
        for transactionIndex in 0..<retrievedTransactions.count {
            if retrievedTransactions[transactionIndex].sourceId == accountId {
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
    @NSManaged public var picture: Data

}

public enum TransactionType {
    case credit
    case debt
}

public class BankTransaction: NSManagedObject, Identifiable {
    public typealias ID = UUID
    
    @NSManaged public var amount: NSDecimalNumber
    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    public var type: TransactionType?
    
    // @NSManaged cannot be nil as must be compatible with C. Therefore, ids will be positive, and negative ones taken to be nil.
    @NSManaged public var sourceId: Account.ID
    @NSManaged public var destinationId: Account.ID
    
    func isRecent() -> Bool {
        let threshold = Double(30 * 24 * 3600) // within 30 days
        return (Date().timeIntervalSince1970 - date.timeIntervalSince1970) <= threshold
    }

}
