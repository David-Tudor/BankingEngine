//
//  ExampleView.swift
//  Tudor Bank
//
//  Created by Rolando Rodriguez on 30/09/2023.
//

import SwiftUI

// UINavigationController -> UIKit
// NavigationView 

struct MessagePreview: View {
    let contactName: String
    let lastMessage: String
    let time: String
    
    var body: some View {
        HStack {
            Circle()
                .foregroundColor(.red)
                .frame(width: 45, height: 45)
            
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(contactName)
                    
                    Text(lastMessage)
                        .padding(.trailing, 60)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text(time)
                    
                    Image(systemName: "chevron.right")
                }
            }
        }
    }
}

// Table or TableView in UIKIT -> UITableView
// SwiftUI it is called a List

struct MessageDetail: View {
    let contactName: String
    let messages: [String]
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(messages, id: \.self) { message in
                Text(message)
                    .padding()
                    .background(Color.blue.cornerRadius(8))
            }
        }
        .navigationTitle(contactName)
    }
}

struct FiltersView: View {
    let options: [String] = ["All Messages", "Known Senders", "Unknown Senders", "Unread Messages"]
    
    let extraGroup: [String] = ["Recently Deleted"]
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    NavigationLink(destination: ExampleView()) {
                        Text(option)
                    }
                }
            }
        }
    }
}

struct ExampleViewNoList: View {
    let messageCount = 4
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(0..<messageCount, id: \.self) { index in
                    NavigationLink(destination: MessageDetail(contactName: "David Tudor", messages: ["Hey", "Xcode is good!"])) {
                        
                        MessagePreview(contactName: "David Tudor \(index)", lastMessage: "git@github.com:DvdTd/BankingEngine.git", time: "10: 41")
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .navigationTitle("Messages")
    }
}

struct ExampleView: View {
    let messageCount = 4
    
    var body: some View {
        List {
            ForEach(0..<messageCount, id: \.self) { index in
                NavigationLink(destination: MessageDetail(contactName: "David Tudor", messages: ["Hey", "Xcode is good!"])) {
                    
                    MessagePreview(contactName: "David Tudor \(index)", lastMessage: "git@github.com:DvdTd/BankingEngine.git", time: "10: 41")
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle("Messages")
    }
}

#Preview {
    FiltersView()
}
