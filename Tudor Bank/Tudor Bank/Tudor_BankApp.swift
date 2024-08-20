//
//  Tudor_BankApp.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//

import SwiftUI
import BankingEngine

@main
struct Tudor_BankApp: App {
    @StateObject private var dataController = DataController()
    @StateObject private var myBank = BankingEngine()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(myBank)
        }
        
    }
    
    
}

