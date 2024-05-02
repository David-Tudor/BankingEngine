//
//  Tudor_BankApp.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//

import SwiftUI
import BankingEngine

//class CoreModel: ObservableObject {
//    @Published var isLoading = false
//    
//    init() {
//        fetchData()
//    }
//    
//    func fetchData() {
//        isLoading = true
//        do {
//            try myBank.createAccount(id: 123, name: "David", balance: Decimal(10.00))
//            try myBank.createAccount(id: 1, name: "James", balance: Decimal(30))
//            try myBank.deposit(amount: 100, to: 123)
//            try myBank.withdrawal(amount: 1, from: 1)
//            try myBank.transfer(amount: 5.0, from: 123, to: 1)
//            try myBank.transfer(amount: 12, from: 1, to: 123)
//            try myBank.transfer(amount: 13, from: 1, to: 123)
//        } catch {}
//        
//        isLoading = false
//    }
//}

@main
struct Tudor_BankApp: App {
//    @StateObject var coreModel = CoreModel()
    @StateObject private var dataController = DataController()
    @StateObject private var myBank = BankingEngine()
    
    var body: some Scene {
        WindowGroup {
//            if coreModel.isLoading {
//                ProgressView()
//            } else {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(myBank)
//            }
        }
        
    }
    
    
}
