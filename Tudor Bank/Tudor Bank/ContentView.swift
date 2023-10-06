//
//  ContentView.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//

import SwiftUI
import BankingEngine

let myBank = BankingEngine()

// revove this
struct InputVar {
    var enteredValue: String = ""
    var name: String
}

struct MyTextField: View {
    var name: String
    @State var enteredValue: String = ""
    var isIncorrectEntry = false
    
    var body: some View {
        HStack {
            TextField("Enter \(name)", text: $enteredValue)
            
            if isIncorrectEntry {
                Image(systemName: "xmark.circle" )
                    .foregroundColor(.red)
            }
        }
    }
}

struct CreateAccountView: View {
    @State var output = ""
    
    @State var myIdView = MyTextField(name: "id")
    @State var myNameView = MyTextField(name: "name")
    @State var myBalanceView = MyTextField(name: "balance")
        
    var body: some View {
        VStack {
            
            List {
                myIdView
                myNameView
                myBalanceView
            }
            
            Button("Enter inputs") {
                print("yooooo", myIdView.enteredValue)
                var id: Int? = Int(myIdView.enteredValue)
                print("id", id)
                var name = myNameView.enteredValue
                var balance: Decimal? = Decimal(string: myBalanceView.enteredValue)
    
                
                if id == nil {
                    myIdView.isIncorrectEntry = true
                } else {
                    myIdView.isIncorrectEntry = false
                }
                if name == "" {
                    myNameView.isIncorrectEntry = true
                } else {
                    myNameView.isIncorrectEntry = false
                }
                if balance == nil {
                    myBalanceView.isIncorrectEntry = true
                } else {
                    myBalanceView.isIncorrectEntry = false
                }
                    
                if (id != nil) && (name != "") && (balance != nil) {
                    // just tested they're not nil so force unwrap
                    myBank.createAccount(id: id!, name: name, balance: balance!)
                    output = "account created"
                }
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
                        try output = "The balance of id: \(id!) is £\(myBank.getBalance(for: id!))"
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
        }
    }
    
    
}

#Preview {
    ContentView()
}
