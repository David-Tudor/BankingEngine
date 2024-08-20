//
//  OldBasicViews.swift
//  Tudor Bank
//
//  Created by David Tudor on 28/04/2024.
//

import Foundation

/*
 struct BasicCreateAccountView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Create account")
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
 
 do {
 try myBank.createAccount(id: id, name: name, balance: balance)
 output = "Account created"
 } catch BankingEngine.OperationError.invalidId {
 output = "CreateAccount - Error: account already exists"
 } catch is BankingEngine.OperationError {
 output = "CreateAccount - Error: BankingEngine.OperationError"
 } catch {
 output = "CreateAccount - Some other error"
 }
 
 }
 .buttonStyle(BorderedButtonStyle())
 .disabled(!(model.isIdValid && model.isNameValid && model.isBalanceValid))
 
 Text(output)
 .padding(20)
 }
 .onAppear {
 model.createIdValidationSubscription()
 model.createNameValidationSubscription()
 model.createBalanceValidationSubscription()
 }
 }
 }
 
 
 struct BasicGetAccountView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Get account")
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
 .padding(20)
 }
 .onAppear {
 model.createIdValidationSubscription()
 }
 }
 }
 
 struct BasicGetBalanceView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Get balance")
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
 .padding(20)
 }
 .onAppear {
 model.createIdValidationSubscription()
 }
 }
 }
 
 
 struct BasicDepositView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Deposit")
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
 .padding(20)
 }
 .onAppear {
 model.createIdValidationSubscription()
 model.createBalanceValidationSubscription()
 }
 }
 }
 
 struct BasicWithdrawalView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Withdrawal")
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
 .padding(20)
 }
 .onAppear {
 model.createIdValidationSubscription()
 model.createBalanceValidationSubscription()
 }
 }
 }
 
 struct BasicTransferView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Transfer")
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
 .padding(20)
 }
 .onAppear {
 model.createIdValidationSubscription()
 model.createId2ValidationSubscription()
 model.createBalanceValidationSubscription()
 }
 }
 }
 
 struct BasicRetrieveTransactionsView: View {
 @StateObject private var model = Model()
 @State var output = ""
 
 var body: some View {
 VStack {
 Text("Retrieve transactions")
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
 
 output = ""
 for i in 0..<transactions.count {
 output += "TRANSACTION \(i+1): \(transactions[i])\n"
 }
 
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
 .padding(20)
 }
 }
 .onAppear {
 model.createIdValidationSubscription()
 }
 }
 }
 */
