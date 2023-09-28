//
//  ContentView.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//

import SwiftUI
import BankingEngine

struct ContentView: View {
    @State var id: Account.ID?
    @State var name: String?
    @State var balance: Decimal?
    @State var amount: Decimal?
    @State var withdrawalId: Account.ID?
    @State var depositId: Account.ID?
    
    @State var EnteredId: String?
    @State var EnteredName: String?
    @State var EnteredBalance: String?
    @State var EnteredAmount: String?
    @State var EnteredWithdrawalId: String?
    @State var EnteredDepositId: String?
    
    @State var isInputShowing = ["id" : false, "name" : false, "balance" : false, "withdrawalId" : false, "depositId" : false]
    
    @State var output = ""
    
    let myBank = BankingEngine()
    
    func setOutput(stringToOutput: String) {
        // reset inputs for next function
        id = nil
        name = nil
        balance = nil
        amount = nil
        withdrawalId = nil
        depositId  = nil
        
        setIsInputShowingTrue(keys: [])
         
        output = stringToOutput
    }
    
    func setIsInputShowingTrue(keys: [String]) {
        for (key, _) in isInputShowing {
            if keys.contains(key) {
                isInputShowing[key] = true
            } else {
                isInputShowing[key] = false
            }
        }
    }
    

    func enterVariables() {
        // !!!!
    }
    
    func useCreateAccount() {
        //print(isInputShowing)
    }
    
    func useGetAccount() {
        
    }
    
    func useGetBalance() {
        
    }
    
    func useWithdrawal() {
        
    }
    
    func useDeposit() {
        
    }
    
    func useTransfer() {
        
    }
    
    func useRetrieveTransactions() {
        
    }
    
    var body: some View {
        ZStack {
//            Rectangle()
//                .frame(width: 500, height: 400)
//                .foregroundStyle(.white)
            
            VStack(alignment: .leading) {
                HStack(alignment: .top, spacing: 10) {
                    // first column
                    
                    VStack {
                        Text("Select function:")
                            .underline()
                        //                Image(systemName: "globe")
                        //                    .imageScale(.large)
                        //                    .foregroundStyle(.tint)
                        
                        Button {
                            setIsInputShowingTrue(keys: ["id", "name", "balance"])
                            useCreateAccount()
                        } label: {
                            Text("Create Account")
                        }
                        
                        Button {
                            setIsInputShowingTrue(keys: ["id"])
                            useGetAccount()
                        } label: {
                            Text("Get Account")
                        }
                        
                        Button {
                            setIsInputShowingTrue(keys: ["id"])
                            useGetBalance()
                        } label: {
                            Text("Get Balance")
                        }
                        
                        Button {
                            setIsInputShowingTrue(keys: ["amount", "id"])
                            useDeposit()
                        } label: {
                            Text("Deposit")
                        }
                        
                        Button {
                            setIsInputShowingTrue(keys: ["amount", "id"])
                            useWithdrawal()
                        } label: {
                            Text("Withdrawal")
                        }
                        
                        Button {
                            setIsInputShowingTrue(keys: ["amount", "withdrawalId", "depositId"])
                            useTransfer()
                        } label: {
                            Text("Transfer")
                        }
                        
                        Button {
                            setIsInputShowingTrue(keys: ["id"])
                            useRetrieveTransactions()
                        } label: {
                            Text("Retrieve Transactions")
                        }
                        
                        
                        
                    }
                    .padding()
                    
                    VStack {
                        Text("Variable inputs")
                        
                        //Group {
//                        if isInputShowing["id"]! {
//                            TextField("Enter id", text: $EnteredId?)
//                        }
//                        
//                        if isInputShowing["name"]! {
//                            TextField("Enter name", text: $EnteredName?)
//                        }
//                        
//                        if isInputShowing["balance"]! {
//                            TextField("Enter balance", text: $EnteredBalance?)
//                        }
//                        
//                        if isInputShowing["withdrawalId"]! {
//                            TextField("Enter withdrawalId", text: $EnteredWithdrawalId?)
//                        }
//                        
//                        if isInputShowing["depositId"]! {
//                            TextField("Enter depositId", text: $EnteredDepositId?)
//                        }
                        //}
                        .frame(width: 150)
                        
                        Button {
                            enterVariables()
                        } label: {
                            Text("Enter")
                        }
                        
                        Spacer()
                        
                    }
                    .padding()
                }
                Divider()
                VStack(alignment: .leading) {
                    Text("Output:")
                    Text(output)
                        .frame(width: 150)
                }
                .padding()
            }
        }
        .frame(width: 400, height: 350)
    }

}

#Preview {
    ContentView()
}
