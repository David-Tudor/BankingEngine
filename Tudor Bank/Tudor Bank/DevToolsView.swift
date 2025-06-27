//
//  DevToolsView.swift
//  Tudor Bank
//
//  Created by David Tudor on 27/06/2025.
//

import Foundation
import SwiftUI
import BankingEngine


struct DevToolsView: View {
    @StateObject private var model = Model()
    @State var output = ""
    @State var outputDeposit = ""
    @State private var newId: Int?
    @State private var newName = ""
    @EnvironmentObject var myBank: BankingEngine
    
    let myId: Int
    
    let depositAmount = 10
    let cornerSize = 10
    let smallerText: CGFloat = 16
    let colBlack: UInt = 0x000000
    let colWhite: UInt = 0xFFFFFF
    let colBlue: UInt = 0x5746D2
    let colLightBlue: UInt = 0xEEEBFF
    let colPurple: UInt = 0x82779F
    let colOrange: UInt = 0xFFA115
    
    init(myId: Int) {
        self.myId = myId
    }
    
    var body: some View {
        VStack {
            Text("Create a new account")
            
            VStack {
                // Name field
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                        .fill(Color(colLightBlue))
                    HStack {
                        TextField("Enter name", text: $model.nameField.enteredValue)
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                        CrossOrTickMark(isCorrectEntry: model.isNameValid)
                            .padding(5)
                    }
                }
                
                // Id field
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                        .fill(Color(colLightBlue))
                    HStack {
                        TextField("Enter id", text: $model.idField.enteredValue)
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                        CrossOrTickMark(isCorrectEntry: model.isIdValid)
                            .padding(5)
                    }
                }
            }
            .frame(height: 80)
            
            // Make account button
            Button("Make account") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let name = model.nameField.enteredValue
                    
                    try myBank.createAccount(id: id, name: name, balance: Decimal(0))
                    output = "Account named \(name) created with id \(String(describing: id))"
                    
                } catch BankingEngine.OperationError.accountNotFound {
                    output = "Transfer - Error: account not found"
                    print(output)
                } catch BankingEngine.OperationError.invalidDeposit {
                    output = "Transfer - Error: invalid deposit"
                    print(output)
                } catch BankingEngine.OperationError.invalidWithdrawl {
                    output = "Transfer - Error: invalid withdrawal"
                    print(output)
                } catch BankingEngine.OperationError.genericError {
                    output = "Transfer - Error: can't transfer to the same id"
                    print(output)
                } catch is BankingEngine.OperationError {
                    output = "Transfer - Error: BankingEngine.OperationError"
                    print(output)
                } catch {
                    output = "Transfer - Some other error"
                    print(output)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(!(model.isIdValid && model.isNameValid))
            .frame(maxWidth: .infinity)
            
            Text(output)
                .padding(20)
            
        Spacer()
            
        // Deposit money
        Button("Deposit £\(depositAmount) in current account") {
            do {
                try myBank.deposit(amount: Decimal(depositAmount), to: myId)
                outputDeposit = "£\(depositAmount) deposited"
                
            } catch BankingEngine.OperationError.accountNotFound {
                outputDeposit = "Deposit - Error: account not found"
                print(outputDeposit)
            } catch BankingEngine.OperationError.invalidDeposit {
                outputDeposit = "Deposit - Error: invalid deposit"
                print(outputDeposit)
            } catch BankingEngine.OperationError.invalidWithdrawl {
                outputDeposit = "Deposit - Error: invalid withdrawal"
                print(outputDeposit)
            } catch BankingEngine.OperationError.transactionNotLogged {
                outputDeposit = "Deposit - Error: transaction not logged"
                print(outputDeposit)
            } catch BankingEngine.OperationError.genericError {
                outputDeposit = "Deposit - Error: can't transfer to the same id"
                print(outputDeposit)
            } catch is BankingEngine.OperationError {
                outputDeposit = "Deposit - Error: BankingEngine.OperationError"
                print(outputDeposit)
            } catch {
                outputDeposit = "Deposit - Some other error"
                print(outputDeposit)
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.blue)
        
        Text(outputDeposit)
            .padding(20)
            
        }
        .navigationTitle("Tools")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            model.createIdValidationSubscription()
            model.createNameValidationSubscription()
        }
        
    }
}

