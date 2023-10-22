//
//  ContentView.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//
import SwiftUI
import BankingEngine
import Combine

let myBank = BankingEngine()

struct CrossOrTickMark: View {
    var isCorrectEntry: Bool
    
    var body: some View {
        if !isCorrectEntry {
            Image(systemName: "xmark.circle" )
                .foregroundColor(.red)
        }
    }

    init(isCorrectEntry: Bool) {
        self.isCorrectEntry = isCorrectEntry
    }
}

enum FieldTypes {
    case id
    case amount
    case name
}

struct MyField {
    var type: FieldTypes
    var enteredValue: String
    
    init(type: FieldTypes, enteredValue: String) {
        self.type = type
        self.enteredValue = enteredValue
    }
}

class Model: ObservableObject {
    @Published var idField = MyField(type: .id, enteredValue: "")
    @Published var id2Field = MyField(type: .id, enteredValue: "") // used for destinations Id
    @Published var nameField = MyField(type: .name, enteredValue: "")
    @Published var balanceField = MyField(type: .amount, enteredValue: "")
    
    @Published var isIdValid = true
    @Published var isId2Valid = true
    @Published var isNameValid = true
    @Published var isBalanceValid = true

    func isValidString(input: String) -> Bool {
        if input != "" {
            return true
        } else {
            return false
        }
    }
    
    func isValidInt(input: String) -> Bool {
        let wasCast = (Int(input) != nil)
        if (input != "") && wasCast {
            return true
        } else {
            return false
        }
    }
    
    func isValidDec(input: String) -> Bool {
        let wasCast = (Decimal(string: input) != nil)
        if input != "" && wasCast {
            return true
        } else {
            return false
        }
    }
    
    func buildStringToBoolVar(with field: MyField) -> Bool {
        switch field.type {
        case .name:
            return self.isValidString(input: field.enteredValue)
            
        case .id:
            return self.isValidInt(input: field.enteredValue)
            
        case .amount:
            return self.isValidDec(input: field.enteredValue)
        }
    }
    
    func isFieldValidPublisher(field: Published<MyField>.Publisher) -> AnyPublisher<Bool, Never> {
        return field
            .map({ entry in
                self.buildStringToBoolVar(with: entry)
            })
            .eraseToAnyPublisher()
    }
    
    var subscriptions = Set<AnyCancellable>()
    
    func createIdValidationSubscription() {
        
        isFieldValidPublisher(field: $idField).sink { completion in
            // no-op
        } receiveValue: { [weak self] isTextValid in
            guard let self else {
                return
            }
            isIdValid = isTextValid
        }
        .store(in: &subscriptions)
    }
    
    func createId2ValidationSubscription() {
        isFieldValidPublisher(field: $id2Field).sink { completion in
            // no-op
        } receiveValue: { [weak self] isTextValid in
            guard let self else {
                return
            }
            isId2Valid = isTextValid
        }
        .store(in: &subscriptions)
    }
    
    func createNameValidationSubscription() {
        isFieldValidPublisher(field: $nameField).sink { completion in
            // no-op
        } receiveValue: { [weak self] isTextValid in
            guard let self else {
                return
            }
            isNameValid = isTextValid
        }
        .store(in: &subscriptions)
    }
        
    func createBalanceValidationSubscription() {
        isFieldValidPublisher(field: $balanceField).sink { completion in
            // no-op
        } receiveValue: { [weak self] isTextValid in
            guard let self else {
                return
            }
            isBalanceValid = isTextValid
        }
        .store(in: &subscriptions)
    }

}

struct CreateAccountView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
                
                HStack {
                    TextField("Enter name", text: $model.nameField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isNameValid)
                }
                
                HStack {
                    TextField("Enter balance", text: $model.balanceField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isBalanceValid)
                }
            }
            
            Button("Enter inputs") {
                let id = Int(model.idField.enteredValue)!
                let name = model.nameField.enteredValue
                let balance = Decimal(string: model.balanceField.enteredValue)!
                
                myBank.createAccount(id: id, name: name, balance: balance)
                output = "Account created"
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid && model.isNameValid && model.isBalanceValid))
            
            Text(output)
        }
        .onAppear {
            model.createIdValidationSubscription()
            model.createNameValidationSubscription()
            model.createBalanceValidationSubscription()
        }
    }
}


struct GetAccountView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
            }
            
            Button("Enter input") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let gotAccount = try myBank.getAccount(for: id)
                                                           
                    output = "got account: id = \(gotAccount.id), name = \(gotAccount.name), balance = \(gotAccount.balance)"
                } catch BankingEngine.OperationError.accountNotFound {
                    output = "GetAccount - Error: account not found"
                } catch is BankingEngine.OperationError {
                    output = "GetAccount - Error: BankingEngine.OperationError"
                } catch {
                    output = "GetAccount - Some other error"
                }
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid))
            
            Text(output)
        }
        .onAppear {
            model.createIdValidationSubscription()
        }
    }
}

struct GetBalanceView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
            }
            
            Button("Enter input") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let gotBalance = try myBank.getBalance(for: id)
                    output = "The balance of id: \(id) is £\(gotBalance)"
                    
                } catch BankingEngine.OperationError.accountNotFound {
                    output = "GetBalance - Error: account not found"
                } catch is BankingEngine.OperationError {
                    output = "GetBalance - Error: BankingEngine.OperationError"
                } catch {
                    output = "GetBalance - Some other error"
                }
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid))
            
            Text(output)
        }
        .onAppear {
            model.createIdValidationSubscription()
        }
    }
}


struct DepositView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter destination id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
                
                HStack {
                    TextField("Enter amount", text: $model.balanceField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isBalanceValid)
                }
            }
            
            Button("Enter inputs") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let balance = Decimal(string: model.balanceField.enteredValue)!
                    try myBank.deposit(amount: balance, to: id)
                    output = "£\(balance) deposited to id: \(id)"
                    
                } catch BankingEngine.OperationError.accountNotFound {
                    output = "Deposit - Error: account not found"
                } catch BankingEngine.OperationError.invalidDeposit {
                        output = "Deposit - Error: invalid deposit"
                } catch is BankingEngine.OperationError {
                    output = "Deposit - Error: BankingEngine.OperationError"
                } catch {
                    output = "Deposit - Some other error"
                }
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid && model.isBalanceValid))
            
            Text(output)
        }
        .onAppear {
            model.createIdValidationSubscription()
            model.createBalanceValidationSubscription()
        }
    }
}

struct WithdrawalView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter source id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
                
                HStack {
                    TextField("Enter amount", text: $model.balanceField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isBalanceValid)
                }
            }
            
            Button("Enter inputs") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let balance = Decimal(string: model.balanceField.enteredValue)!
                    try myBank.withdrawal(amount: balance, from: id)
                    output = "£\(balance) withdrawn from id: \(id)"
                    
                } catch BankingEngine.OperationError.accountNotFound {
                    output = "Withdrawal - Error: account not found"
                } catch BankingEngine.OperationError.invalidWithdrawl {
                        output = "Withdrawal - Error: invalid deposit"
                } catch is BankingEngine.OperationError {
                    output = "Withdrawal - Error: BankingEngine.OperationError"
                } catch {
                    output = "Withdrawal - Some other error"
                }
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid && model.isBalanceValid))
            
            Text(output)
        }
        .onAppear {
            model.createIdValidationSubscription()
            model.createBalanceValidationSubscription()
        }
    }
}

struct TransferView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter source id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
                
                HStack {
                    TextField("Enter destination id", text: $model.id2Field.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isId2Valid)
                }
                
                HStack {
                    TextField("Enter amount", text: $model.balanceField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isBalanceValid)
                }
            }
            
            Button("Enter inputs") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let id2 = Int(model.id2Field.enteredValue)!
                    let balance = Decimal(string: model.balanceField.enteredValue)!
                    
                    try myBank.transfer(amount: balance, from: id, to: id2)
                    output = "£\(balance) transfered from id: \(id) to id: \(id2)"
                    
                } catch BankingEngine.OperationError.accountNotFound {
                    output = "Transfer - Error: account not found"
                } catch BankingEngine.OperationError.invalidDeposit {
                        output = "Transfer - Error: invalid deposit"
                } catch BankingEngine.OperationError.invalidWithdrawl {
                        output = "Transfer - Error: invalid withdrawal"
                } catch BankingEngine.OperationError.genericError {
                        output = "Transfer - Error: can't transfer to the same id"
                } catch is BankingEngine.OperationError {
                    output = "Transfer - Error: BankingEngine.OperationError"
                } catch {
                    output = "Transfer - Some other error"
                }
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid && model.isId2Valid && model.isBalanceValid))
            
            Text(output)
        }
        .onAppear {
            model.createIdValidationSubscription()
            model.createId2ValidationSubscription()
            model.createBalanceValidationSubscription()
        }
    }
}

struct RetrieveTransactionsView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var body: some View {
        VStack {
            List {
                HStack {
                    TextField("Enter id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isCorrectEntry: model.isIdValid)
                }
            }
            
            Button("Enter input") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let transactions = try myBank.retrieveTransactions(accountId: id)
                    output = "\(transactions)"
                    
                } catch BankingEngine.OperationError.noTransactionsFound {
                    output = "LogTransactions - Error: no transactions found"
                } catch is BankingEngine.OperationError {
                    output = "LogTransactions - Error: BankingEngine.OperationError"
                } catch {
                    output = "LogTransactions - Some other error"
                }
            
            }
            .buttonStyle(BorderedButtonStyle())
            .disabled(!(model.isIdValid))
            ScrollView {
                Text(output)
            }
        }
        .onAppear {
            model.createIdValidationSubscription()
        }
    }
}

struct ContentView: View {
    
    var body: some View {
        NavigationView {
            List {
                
                NavigationLink(destination: CreateAccountView()) {
                    Text("Preview for create account")
                }
                .navigationTitle("Create account")
                NavigationLink(destination: GetAccountView()) {
                    Text("Preview for get account")
                }
                .navigationTitle("Get account")
                NavigationLink(destination: GetBalanceView()) {
                    Text("Preview for get balance")
                }
                .navigationTitle("Get balance")
                NavigationLink(destination: DepositView()) {
                    Text("Preview for deposit")
                }
                .navigationTitle("Deposit")
                NavigationLink(destination: WithdrawalView()) {
                    Text("Preview for withdrawl")
                }
                .navigationTitle("Withdrawal")
                NavigationLink(destination: TransferView()) {
                    Text("Preview for transfer")
                }
                .navigationTitle("Transfer")
                NavigationLink(destination: RetrieveTransactionsView()) {
                    Text("Preview for retrieve transactions")
                }
                .navigationTitle("Recent transactions")
                    
            }
            .navigationTitle("Function list")
        }
    }
}

#Preview {
    ContentView()
}
