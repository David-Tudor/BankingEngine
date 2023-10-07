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

// ObservableObject -> Declares all the mechanisms to the observer pattern can be implemented between the object that implements this protocol and any subscriber.

// If you make youd model conform to ObservableObject then you are making your model a *posible* Publisher.

/* Two property wrappers: @EnvironmentObject @Environment
 View 1: parent declares monkeyName
 View 2: Needs to modify and reads monkeyName
 View 3: Reads monkeyName let monkeyName: String
 View 4: Needs to modify and read monkeyName
 
 @EnvironmentObject can only be an Object
 
 What's an object? In SwiftUI terms and object is anything that
 is a reference type and conform to ObservabableObject protocol
 
 @Environment you can use value types -> Structs and Enums and Tuples, primitive types, closures.
 
 What the F is a design pattern?
 - In software engineering a design pattern is a general reusable solution to a common problem.
 
 - Observation Design Pattern
 
 the problem: 
 
 via the observation design pattern.
 
 */



struct ChildView: View {
    @Binding var textToEdit: String
    
    let myNumber = 1234
    
    // textToEdit -> String
    // $textToEdit -> Binding<String>
    
    var body: some View {
        Button {
           textToEdit = "Davos"
        } label: {
            Text("Update Name")
        }

    }
}



// User 'let' keyword to declare properties that are read only.

// Use @State var keywords to *initialise* properties that need to be read and modified by the current view or child views.

// Use @Binding var keywords to *declare* properties that need to be read and modified within the scope of the view and child views.

// @State -> requests new memory to be allocated to the system for the specified property. i.e "David"
// @Binding -> Tells the system that the type containing it can modify the memory allocated by the propety that's being passed.

// Whenever data changes the body get re-computed // body gets called again by the system.

// What data can change? @State properties and @Binding.

class MyModel: ObservableObject {
    @Published var myName = "Pepe"
    let numbers = 12434
    
    @Published var news = "No news yet!"
    
    func updatedNews() {
        news = "News are new and newing!"
    }
}

struct MyValueTypeModel {
    var isTheSunBright = true
    
    mutating func makeTheSunNotBright() {
        isTheSunBright = false
    }
}

// @State - @StateObject
// @Binding - @ObservedObject

struct ChildView2: View {
    let textToShow: String
    
    // textToEdit -> String
    // $textToEdit -> Binding<String>
    
    var body: some View {
        Text("Current name: \(textToShow)")
       
        SmallView()
    }
}

struct SmallView: View {
    @EnvironmentObject var myModel: MyModel
    
    var body: some View {
        Text("what't the name: \(myModel.myName)")
            .font(.title)
        
        SmallView2()
    }
}

struct SmallView2: View {
    @EnvironmentObject var myModel: MyModel
    
    var body: some View {
        Text("what't the name: \(myModel.myName)")
            .font(.title)
        
        TextField("Type!", text: $myModel.myName)
    }
}


struct ParentView: View {
    @State private var sunBrightModel = MyValueTypeModel()
    @State private var userName = ""
    
    @StateObject var myModel = MyModel()

    
    var body: some View {
        VStack(spacing: 60) {
            Text("Is the sun bright? \(sunBrightModel.isTheSunBright ? "YES" : "NO!")")
                .font(.title)
                                                
            ChildView(textToEdit: $myModel.myName)
            
            ChildView2(textToShow: "Hello! Just a string!")
                .environmentObject(myModel)

            Button(action: doUpdateModelThing) {
                Text("Updated Model")
            }
            
            Button("Update value type model") {
                sunBrightModel.makeTheSunNotBright()
            }
        }
    }
    
    func doUpdateModelThing() {
        myModel.myName = "Something"
    }
}


#Preview {
    ParentView()
}
