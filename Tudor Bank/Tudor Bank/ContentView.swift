//
//  ContentView.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//
import SwiftUI
import BankingEngine
import Combine

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

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
    // Helps store data and checks values are valid.
    @Published var idField = MyField(type: .id, enteredValue: "")
    @Published var id2Field = MyField(type: .id, enteredValue: "") // used for destination Id
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
    
    func isValidId(input: String) -> Bool {
        let isNilOrNegative = (Int(input) ?? -1) < 0
        if (input != "") && !isNilOrNegative {
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
            return self.isValidId(input: field.enteredValue)
            
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


struct ContentView: View {
    let myId = 123
    @State var myName = ""
    @State var myBalance: Decimal = 0.0
    @State var isLoaded = false
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var myBank: BankingEngine
    
    let colBlack: UInt = 0x000000
    let colGrey: UInt = 0x4A4A4D
    let colBlue: UInt = 0x5746D2
    let colBack1: UInt = 0xF6F5FD
    let colBack2: UInt = 0xD9EADA
    let colBack3: UInt = 0xFFF9F1
    let colBack4: UInt = 0xf5ebf4
    
    func updateAccountDetails() {
        do {
            let account = try myBank.getAccount(for: myId)
            myBalance = account.balance.decimalValue
            myName = account.name
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
                    Text("Hi \(myName),")
                        .foregroundColor(Color(colBlack))
                        .font(.system(size: 28, weight: .bold))
                        .padding(EdgeInsets())
                    
                    
                    if myBalance >= 0.0 {
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
                            NavigationLink(destination: NavigationLazyView(SendMoneyView(myId: myId).padding(.horizontal, 20))) {
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
                            NavigationLink(destination: NavigationLazyView(RetrieveTransactionsView(myId: myId).padding(.horizontal, 20))) {
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
                            NavigationLink(destination: NavigationLazyView(AccountView(myId: myId, myName: myName).padding(.horizontal, 20))) {
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
                            
                            // Dev tools
                            NavigationLink(destination: NavigationLazyView(DevToolsView(myId: myId).padding(.horizontal, 20))) {
                                ZStack (alignment: .topLeading) {
                                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                        .fill(Color(colBack4))
                                    
                                    VStack(alignment: .leading, spacing: 10) {
                                        Image(systemName: "wrench.and.screwdriver")
                                            .foregroundColor(Color(colBlue))
                                            .dynamicTypeSize(.xxxLarge )
                                        Text("Tools")
                                            .font(.system(size: bigMenuText, weight: .semibold))
                                            .foregroundColor(Color(colBlack))
                                        Text("Developer functions")
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
            .padding(.horizontal, 20)
        }
        .onReceive(myBank.allTransactions, perform: { _ in
            if isLoaded {
                updateAccountDetails()
            }
        })
        .onAppear {
            myBank.setup(moc: moc)
        }
    }
}

#Preview {
    ContentView()
}
