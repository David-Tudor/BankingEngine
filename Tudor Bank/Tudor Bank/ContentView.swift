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

// revove this
struct InputVar {
    var enteredValue: String = ""
    var name: String
}

struct CrossOrTickMark: View {
    var isIncorrectEntry: Bool //no @binding?
    
    var body: some View {
        if isIncorrectEntry {
            Image(systemName: "xmark.circle" )
                .foregroundColor(.red)
        }
    }

    init(isIncorrectEntry: Bool) {
        self.isIncorrectEntry = isIncorrectEntry
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
    var isIncorrectEntry: Bool
    
    init(type: FieldTypes, enteredValue: String, isIncorrectEntry: Bool) {
        self.type = type
        self.enteredValue = enteredValue
        self.isIncorrectEntry = isIncorrectEntry
    }
}

class Model: ObservableObject {
    @Published var idField = MyField(type: .id, enteredValue: "", isIncorrectEntry: false)
    @Published var nameField = MyField(type: .name, enteredValue: "", isIncorrectEntry: false)
    @Published var balanceField = MyField(type: .amount, enteredValue: "", isIncorrectEntry: false)
    
//    @Published var enteredId = ""
//    @Published var enteredName = ""
//    @Published var enteredBalance = ""
//    
//    @Published var isIncorrectIdEntry = false
//    @Published var isIncorrectNameEntry = false
//    @Published var isIncorrectBalanceEntry = false
//    
    func isFieldEmpty(input: String) -> Bool {
        if input == "" {
            return true
        } else {
            return false
        }
    }
    
    func isNotInt(input: String) -> Bool {
        let wasntCast = (Int(input) != nil)
        if (input == "") || wasntCast {
            return true
        } else {
            return false
        }
    }
    
    func isNotDec(input: String) -> Bool {
        let wasntCast = (Decimal(string: input) != nil)
        if input == "" || wasntCast {
            return true
        } else {
            return false
        }
    }
    
    // make a func which returns bool depending on validity of entry - currently ONLY empty
    func buildStringToBoolPublisher(with entry: MyField) -> Future<Bool, Error> {
        print("build stb")
        let validationAsyncPublisher = Future<Bool, Error> { promise in
            switch entry.type {
            case .name:
                let isInvalid = self.isFieldEmpty(input: entry.enteredValue)
                promise(.success(isInvalid))
            case .id:
                print("here")
                let isInvalid = self.isNotInt(input: entry.enteredValue)
                promise(.success(isInvalid))
            case .amount:
                let isInvalid = self.isNotDec(input: entry.enteredValue)
                promise(.success(isInvalid))
            }
        }
        print(validationAsyncPublisher)
        return validationAsyncPublisher
    }
    
    // is this one needed if the string to bool is a publisher?
    // this turns the bool into a publisher
    
//    var isEntryEmptyPublisher: AnyPublisher<Bool, Never> {
//        print("hi")
//        return $idField
//            .flatMap({ entry in
//                self.buildStringToBoolPublisher(with: entry)
//                    .catch { error in
//                        Just(false)
//                    }
//            })
//            .eraseToAnyPublisher()
//    }
    
    
    
    func isIdInvalidPublisher() -> AnyPublisher<Bool, Never> {
        return $idField
            .flatMap({ entry in
                self.buildStringToBoolPublisher(with: entry)
                    .catch { error in
                        Just(false)
                    }
            })
            .eraseToAnyPublisher()
    }
    
    func isNameInvalidPublisher() -> AnyPublisher<Bool, Never> {
        return $nameField
            .flatMap({ entry in
                self.buildStringToBoolPublisher(with: entry)
                    .catch { error in
                        Just(false)
                    }
            })
            .eraseToAnyPublisher()
    }
    
    func isBalanceInvalidPublisher() -> AnyPublisher<Bool, Never> {
        return $balanceField
            .flatMap({ entry in
                self.buildStringToBoolPublisher(with: entry)
                    .catch { error in
                        Just(false)
                    }
            })
            .eraseToAnyPublisher()
    }
    
    
    // this receives the bool publisher and does stuff
    private var cancellable: AnyCancellable?
    
    func isFieldIncorrect(field: MyField) {
        let myPublisher: () -> AnyPublisher<Bool, Never>
        
        switch field.type {
        case .name:
            myPublisher = isNameInvalidPublisher
        case .id:
            myPublisher = isIdInvalidPublisher
        case .amount:
            myPublisher = isBalanceInvalidPublisher
        }
        
        print("before cancellable")
        cancellable = myPublisher().sink { completion in
            // no-op
        } receiveValue: { [weak self] isTextInvalid in
            guard let self else {
                return
            }
            idField.isIncorrectEntry = isTextInvalid
        }
        
    }


}

struct CreateAccountView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
    var textChangedPublisher = CurrentValueSubject<String, Never>("")
    
    var body: some View {
        VStack {
            
            List {
                HStack {
                    TextField("Enter id", text: $model.idField.enteredValue)
                    CrossOrTickMark(isIncorrectEntry: model.idField.isIncorrectEntry)
                }
                
                HStack {
                    TextField("Enter name", text: $model.nameField.enteredValue)
                    CrossOrTickMark(isIncorrectEntry: model.nameField.isIncorrectEntry)
                }
                
                HStack {
                    TextField("Enter balance", text: $model.balanceField.enteredValue)
                    CrossOrTickMark(isIncorrectEntry: model.balanceField.isIncorrectEntry)
                }

            }
            
            Button("Enter inputs") {
                output = ""
                print("1")
                model.isFieldIncorrect(field: model.idField)
                
            
            }
            .buttonStyle(BorderedButtonStyle())
            
            
            Text(output)
            
        }
    }
}

//struct CreateAccountView: View {
//    @State var output = ""
//    
//    @State var myId = InputVar(name: "id")
//    @State var myName = InputVar(name: "name")
//    @State var myBalance = InputVar(name: "balance")
//        
//    var body: some View {
//        VStack {
//            
//            List {
//                TextField("Enter id", text: $myId.enteredValue)
//                TextField("Enter name", text: $myName.enteredValue)
//                TextField("Enter balance", text: $myBalance.enteredValue)
//
//            }
//            
//            Button("Enter inputs") {
//                let id: Int? = Int(myId.enteredValue)
//                let name = myName.enteredValue
//                let balance: Decimal? = Decimal(string: myBalance.enteredValue)
//    
//                if (id == nil) || (name == "") || (balance == nil) {
//                    output = "enter again"
//                } else {
//                    myBank.createAccount(id: id!, name: name, balance: balance!)
//                    output = "account created"
//                }
//            }
//            .buttonStyle(BorderedButtonStyle())
//            
//            Text(output)
//        }
//    }
//}

struct GetAccountView: View {
    @State var output = ""
    
    @State var myId = InputVar(name: "id")

    var body: some View {
        VStack {
            
            List {
                TextField("Enter id", text: $myId.enteredValue)
            }
            
            Button("Enter input") {
                let id: Int? = Int(myId.enteredValue)

                if (id == nil) {
                    output = "enter again"
                } else {

                    do {
                        try output = "get account: \(myBank.getAccount(for: id!))"
                    } catch BankingEngine.OperationError.accountNotFound {
                        output = "Error: account not found"
                    } catch is BankingEngine.OperationError {
                        output = "Error: BankingEngine.OperationError"
                    } catch {
                        output = "Some other error"
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            
            Text(output)
        }
    }
}

struct GetBalanceView: View {
    @State var output = ""
    
    @State var myId = InputVar(name: "id")

    var body: some View {
        VStack {
            
            List {
                TextField("Enter id", text: $myId.enteredValue)
            }
            
            Button("Enter input") {
                let id: Int? = Int(myId.enteredValue)

                if (id == nil) {
                    output = "enter again"
                } else {

                    do {
                        // make a variable
                        let myBalance = try myBank.getBalance(for: id!)
                        output = "The balance of id: \(id!) is £\(myBalance)"
                    } catch BankingEngine.OperationError.accountNotFound {
                        output = "Error: accound not found"
                    } catch is BankingEngine.OperationError {
                        output = "Error: BankingEngine.OperationError"
                    } catch {
                        output = "Some other error"
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            
            Text(output)
        }
    }
}

struct DepositView: View {
    @State var output = ""
    
    @State var myId = InputVar(name: "id")
    @State var myAmount = InputVar(name: "amount")
        
    var body: some View {
        VStack {
            
            List {
                TextField("Enter destination id", text: $myId.enteredValue)
                TextField("Enter amount", text: $myAmount.enteredValue)
            }
            
            Button("Enter inputs") {
                let id: Int? = Int(myId.enteredValue)
                let amount: Decimal? = Decimal(string: myAmount.enteredValue)
    
                if (id == nil) || (amount == nil) {
                    output = "enter again"
                } else {
                    do {
                        try myBank.deposit(amount: amount!, to: id!)
                        output = "amount deposited"
                    } catch {
                        output = "deposit threw some error"
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            
            Text(output)
        }
    }
}

struct WithdrawalView: View {
    @State var output = ""
    
    @State var myId = InputVar(name: "id")
    @State var myAmount = InputVar(name: "amount")
        
    var body: some View {
        VStack {
            
            List {
                TextField("Enter source id", text: $myId.enteredValue)
                TextField("Enter amount", text: $myAmount.enteredValue)
            }
            
            Button("Enter inputs") {
                let id: Int? = Int(myId.enteredValue)
                let amount: Decimal? = Decimal(string: myAmount.enteredValue)
    
                if (id == nil) || (amount == nil) {
                    output = "enter again"
                } else {
                    do {
                        try myBank.withdrawal(amount: amount!, from: id!)
                        output = "amount withdrawn"
                    } catch {
                        output = "withdrawal threw some error"
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            
            Text(output)
        }
    }
}

struct TransferView: View {
    @State var output = ""
    
    @State var mySourceId = InputVar(name: "soureId")
    @State var myDestinationId = InputVar(name: "destinationId")
    @State var myAmount = InputVar(name: "amount")
        
    var body: some View {
        VStack {
            
            List {
                TextField("Enter source id", text: $mySourceId.enteredValue)
                TextField("Enter destination id", text: $myDestinationId.enteredValue)
                TextField("Enter amount", text: $myAmount.enteredValue)
            }
            
            Button("Enter inputs") {
                let sourceId: Int? = Int(mySourceId.enteredValue)
                let destinationId: Int? = Int(myDestinationId.enteredValue)
                let amount: Decimal? = Decimal(string: myAmount.enteredValue)
    
                if (sourceId == nil) || (destinationId == nil) || (amount == nil) {
                    output = "enter again"
                } else {
                    do {
                        try myBank.transfer(amount: amount!, from: sourceId!, to: destinationId!)
                        output = "amount transfered"
                    } catch {
                        output = "transfer threw some error"
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            
            Text(output)
        }
    }
}

struct RetrieveTransactionsView: View {
    @State var output = ""
    
    @State var myId = InputVar(name: "id")

    var body: some View {
        VStack {
            
            List {
                TextField("Enter id", text: $myId.enteredValue)
            }
            
            Button("Enter input") {
                let id: Int? = Int(myId.enteredValue)

                if (id == nil) {
                    output = "enter again"
                } else {

                    do {
                        // need this to be readable
                        try output = "transactions: \(myBank.retrieveTransactions(accountId: id!))"
//                    } catch BankingEngine.OperationError.accountNotFound {
//                        output = "Error: accound not found"
//                    } catch is BankingEngine.OperationError {
//                        output = "Error: BankingEngine.OperationError"
                    } catch {
                        output = "Some other error"
                    }
                }
            }
            .buttonStyle(BorderedButtonStyle())
            
            Text(output)
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
                NavigationLink(destination: GetAccountView()) {
                    Text("Preview for get account")
                }
                NavigationLink(destination: GetBalanceView()) {
                    Text("Preview for get balance")
                }
                NavigationLink(destination: DepositView()) {
                    Text("Preview for deposit")
                }
                NavigationLink(destination: WithdrawalView()) {
                    Text("Preview for withdrawl")
                }
                NavigationLink(destination: TransferView()) {
                    Text("Preview for transfer")
                }
                NavigationLink(destination: RetrieveTransactionsView()) {
                    Text("Preview for retrieve transactions")
                }
                    
                    
                
            }
            .navigationTitle("Function list")
        }
    }
    
    
}

#Preview {
    ContentView()
}
