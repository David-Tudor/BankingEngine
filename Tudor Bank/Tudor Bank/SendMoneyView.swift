//
//  SendMoneyView.swift
//  Tudor Bank
//
//  Created by David Tudor on 15/02/2024.
//

import Foundation
import SwiftUI
import BankingEngine

struct SendMoneyView: View {
    @StateObject private var model = Model()
    @State var output = ""
    @EnvironmentObject var myBank: BankingEngine
    
    let myId: Int
    
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
//            Text("Send money")
//                .foregroundColor(Color(colBlack))
//                .font(.system(size: 24, weight: .bold))
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                        .fill(Color(colLightBlue))
                    HStack {
                        TextField("Enter destination id", text: $model.idField.enteredValue)
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                        CrossOrTickMark(isCorrectEntry: model.isIdValid)
                            .padding(5)
                    }
                }
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                        .fill(Color(colLightBlue))
                    HStack {
                        Text("£")
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                        TextField("Enter amount", text: $model.balanceField.enteredValue)
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                        CrossOrTickMark(isCorrectEntry: model.isBalanceValid)
                            .padding(5)
                    }
                }
            }
            .frame(height: 80)
            Spacer()
            
            Button("Make transaction") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let balance = Decimal(string: model.balanceField.enteredValue)!
                    
                    try myBank.transfer(amount: balance, from: myId, to: id)
                    output = "£\(balance) transfered from id: \(myId) to id: \(id)"
                    
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
            .disabled(!(model.isIdValid && model.isBalanceValid))
            .frame(maxWidth: .infinity)
            
            Text(output)
                .padding(20)
        }
        .navigationTitle("Send money")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            model.createIdValidationSubscription()
            
            model.createBalanceValidationSubscription()
        }
    }
}
