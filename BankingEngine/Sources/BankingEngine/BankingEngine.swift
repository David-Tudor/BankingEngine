import Foundation

public class BankingEngine {
    // objects
    public enum OperationError: Error {
        case accountNotFound
        case invalidDeposit
        case invalidWithdrawl
        case genericError
        case noTransactionsFound
    }
    
    public enum TransactionType {
        case credit
        case debt
    }
    
    public struct Transaction: Equatable {
        public typealias ID = UUID
        
        public let amount: Decimal
        public let date: Date
        public let sourceAccount: Account.ID?
        public let destinationAccount: Account.ID?
        public let id: Transaction.ID
        public var type: TransactionType?
        
        func isRecent() -> Bool {
            let threshold = Double(30 * 24 * 3600)
            return (Date().timeIntervalSince1970 - date.timeIntervalSince1970) <= threshold
        }
    }
    
    // properties
    private var accounts: [Account.ID: Account] = [:]
    private var transactions: [Transaction] = []
    
    // methods
    public func createAccount(id: Account.ID, name: String, balance: Decimal) {
        accounts[id] = Account(id: id, name: name, balance: balance)
    }
    
    public func getAccount(for id: Account.ID) throws -> Account {
        if let account = accounts[id] {
            return account
        }
        
        throw OperationError.accountNotFound
    }
    
    public func getBalance(for id: Account.ID) throws -> Decimal {
        if let account = accounts[id] {
            return account.balance
        }
        
        throw OperationError.accountNotFound
    }
    
    public func deposit(amount: Decimal, to id: Account.ID, shouldLogTransaction: Bool = true) throws {
        guard amount >= 0.0 else {
            throw OperationError.invalidDeposit
        }
        // dictionary is value type so make sure to add to the actual dictionary
        guard accounts[id] != nil else {
            throw OperationError.accountNotFound
        }
        accounts[id]?.balance += amount
        
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
        
        let range = 0.0...balance
        
        guard range.contains(amount) else {
            throw OperationError.invalidWithdrawl
        }
        
        accounts[id]?.balance -= amount
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
        
        let transaction = Transaction(amount: amount, date: Date(), sourceAccount: sourceId, destinationAccount: destinationId, id: UUID())
        
        transactions.append(transaction)
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

public class Account {
    public typealias ID = Int
    
    public let id: Account.ID
    public let name: String
    public var balance: Decimal

    init(id: Account.ID, name: String, balance: Decimal) {
        self.id = id
        self.name = name
        self.balance = balance
    }
    
    
    
}


