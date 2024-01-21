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

extension Color {
    init(_ hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
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

struct SendMoneyView: View {
    @StateObject private var model = Model()
    @State var output = ""
    
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
            Text("Send money")
                .foregroundColor(Color(colBlack))
                .font(.system(size: 24, weight: .bold))
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
            
            // NEXT: MAKE THIS BUTTON BETTER !!!!!!
            Button("Enter inputs") {
                do {
                    let id = Int(model.idField.enteredValue)!
                    let balance = Decimal(string: model.balanceField.enteredValue)!
                    
                    try myBank.transfer(amount: balance, from: myId, to: id)
                    output = "£\(balance) transfered from id: \(myId) to id: \(id)"
                    
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

struct RetrieveTransactionsView: View {
    @StateObject private var model = Model()
    @State var output = ""
    @State var transactions: Array<BankingEngine.Transaction> = []
    
    let myId: Int
    let cornerSize = 15
    let biggerText: CGFloat = 18
    let smallerText: CGFloat = 16
    let colBlack: UInt = 0x000000
    let colGrey: UInt = 0x4A4A4D
    let colBlue1: UInt = 0xDBD8FF
    let colBlue2: UInt = 0xEEEBFF

    func buildListTitle(with myString: String) -> some View {
        Text(myString)
            .foregroundColor(Color(colBlack))
            .font(.system(size: biggerText, weight: .bold))
    }
    
    func buildListItem(with transaction: BankingEngine.Transaction, isDarkBlue: Bool) -> some View {
        ZStack (alignment: .topLeading) {
            RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                .fill(Color(isDarkBlue ? colBlue1 : colBlue2))
            
            HStack {
                VStack(alignment: .leading) {
                    switch (transaction.sourceAccount, transaction.destinationAccount) {
                    case (nil, myId):
                        buildListTitle(with: "Deposit")
                    case (myId, nil):
                        buildListTitle(with: "Withdrawal")
                    case (let account, myId):
                        buildListTitle(with: "Transfer from \(account!)")
                    case (myId, let account):
                        buildListTitle(with: "Transfer to \(account!)")
                    case (_, _):
                        buildListTitle(with: "Unknown")
                    }
                    Text("\(transaction.date.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(Color(colGrey))
                        .font(.system(size: smallerText, weight: .regular))
                }
                .padding(.horizontal, 30)
                .frame(height: 80)
                Spacer()
                Text((transaction.type == .credit ? "+" : "-") + transaction.amount.formatted(.currency(code: "GBP")))
                    .padding(10)
            }
        }
        .frame(height: 80)
    }
    
    init(myId: Int) {
        self.myId = myId
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Recent transactions")
                    .foregroundColor(Color(colBlack))
                    .font(.system(size: 28, weight: .bold))
                    .padding(EdgeInsets())
                // if no error message i.e there are transactions
                if transactions.count != 0 {
                    ScrollView {
                        VStack {
                            ForEach(0..<transactions.count , id: \.self) { i in
                                buildListItem(with: transactions[i], isDarkBlue: (i % 2) == 0)
                            }
                        }
                    }
                } else {
                    Text("No transactions found")
                }
            }
        }
        .onReceive(myBank.allTransactions, perform: { _ in
            transactions = (try? myBank.retrieveTransactions(accountId: myId)) ?? []
            
        })
    }
}


struct ContentView: View {
    let myId = 123
    @State var myName = ""
    @State var myBalance: Decimal = 0.0
    @State var isLoaded = false
    //    let myId = 123
    //    let myName = "David"
    //    let myBalance = 10.00
    
    let colBlack: UInt = 0x000000
    let colGrey: UInt = 0x4A4A4D
    let colBlue: UInt = 0x5746D2
    let colBack1: UInt = 0xF6F5FD
    let colBack2: UInt = 0xD9EADA
    let colBack3: UInt = 0xFFF9F1
    
    func updateAccountDetails() {
        do {
            let account = try myBank.getAccount(for: myId)
            myBalance = account.balance
            myName = account.name
            print(myBalance)
        } catch {
            
        }
    }
   
    var balanceString: String {
        myBalance.formatted(.currency(code: "GBP"))
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hi \(myName)")
                        .foregroundColor(Color(colBlack))
                        .font(.system(size: 28, weight: .bold))
                        .padding(EdgeInsets())
                    
                    
                    if myBalance > 0.0 {
                        Text("Your balance is")
                            .font(.system(size: 16))
                            .foregroundColor(Color(colGrey))
                        Text("\(balanceString)")
                            .font(.system(size: 24))
                            .foregroundColor(Color(colBlue))
                    }
                    
                    Text("Here are some things you can do")
                        .font(.system(size: 14))
                        .foregroundColor(Color(colGrey))
              
                    let smallMenuText: CGFloat = 14
                    let bigMenuText: CGFloat = 18
                    let cornerSize = 20
                    let boxSpacing: CGFloat = 20
                    VStack(alignment: .leading, spacing: boxSpacing) {
                        HStack(spacing: boxSpacing) {
                            
                            // send money
                            NavigationLink(destination: SendMoneyView(myId: myId)) {
                                ZStack (alignment: .topLeading) {
                                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                        .fill(Color(colBack1))
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Image(systemName: "person.line.dotted.person")
                                            .foregroundColor(Color(colBlue))
                                            .dynamicTypeSize(.xxxLarge )
                                        Text("Send Money")
                                            .font(.system(size: bigMenuText, weight: .semibold))
                                            .foregroundColor(Color(colBlack))
                                        Text("To wallet, bank or mobile number")
                                            .font(.system(size: smallMenuText))
                                            .foregroundColor(Color(colGrey))
                                    }
                                    .frame(width: (geometry.size.width - boxSpacing) * 0.45, height: (geometry.size.width - boxSpacing) * 0.5)
                                }
                                .frame(width: (geometry.size.width - boxSpacing) * 0.5, height: (geometry.size.width - boxSpacing) * 0.5)
                            }
                            
                            
                            // transactions
                            NavigationLink(destination: RetrieveTransactionsView(myId: myId)) {
                                ZStack (alignment: .topLeading) {
                                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                        .fill(Color(colBack2))
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Image(systemName: "list.bullet")
                                            .foregroundColor(Color(colBlue))
                                            .dynamicTypeSize(.xxxLarge )
                                        Text("Transactions")
                                            .font(.system(size: bigMenuText, weight: .semibold))
                                            .foregroundColor(Color(colBlack))
                                        Text("Lists recent transactions")
                                            .font(.system(size: smallMenuText))
                                            .foregroundColor(Color(colGrey))
                                       
                                    }
                                    .frame(width: (geometry.size.width - boxSpacing) * 0.45, height: (geometry.size.width - boxSpacing) * 0.5)
                                }
                                .frame(width: (geometry.size.width - boxSpacing) * 0.5, height: (geometry.size.width - boxSpacing) * 0.5)
                            }
                        }

                        
                        HStack(spacing: boxSpacing){
                            // Account
                            NavigationLink(destination: RetrieveTransactionsView(myId: myId)) {
                                ZStack (alignment: .topLeading) {
                                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                        .fill(Color(colBack3))
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Image(systemName: "person.fill")
                                            .foregroundColor(Color(colBlue))
                                            .dynamicTypeSize(.xxxLarge )
                                        Text("Account")
                                            .font(.system(size: bigMenuText, weight: .semibold))
                                            .foregroundColor(Color(colBlack))
                                        Text("View account details")
                                            .font(.system(size: smallMenuText))
                                            .foregroundColor(Color(colGrey))
                                    }
                                    .frame(width: (geometry.size.width - boxSpacing) * 0.45, height: (geometry.size.width - boxSpacing) * 0.5)
                                }
                                .frame(width: (geometry.size.width - boxSpacing) * 0.5, height: (geometry.size.width - boxSpacing) * 0.5)
                            }
                        }
                    }
                }
                .onAppear {
                    updateAccountDetails()
                    isLoaded = true
                }
            }
        }
        // pads outer edges
        .padding(20)
        .onReceive(myBank.allTransactions, perform: { _ in
            if isLoaded {
                updateAccountDetails()
            }
        })
    }
}

#Preview {
    ContentView()
}
