//
//  ContentView.swift
//  Tudor Bank
//
//  Created by David Tudor on 23/09/2023.
//

import SwiftUI
import BankingEngine

struct ContentView: View {
     @State var name = ""
    
    let myBank = BankingEngine()
    
    func testBank() {
        myBank.createAccount(id: 1, name: "David", balance: 12.39)
        print(name)
    }
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            TextField("Enter name", text: $name)
            Button {
                testBank()
                
            } label: {
                Text("Run testBank")
            }

        }
        .padding()
    }
}

#Preview {
    ContentView()
}
