//
//  AccountView.swift
//  Tudor Bank
//
//  Created by David Tudor on 15/02/2024.
//

import Foundation
import SwiftUI

struct MyAccountView: View {
    @StateObject private var model = Model()
    @State var output = ""
    @State var isEditable = false
    @State var myName: String
    @State var nameHolder: String
    @State var isPickerShowing = false
    @State var selectedImage: UIImage?
    
    let myId: Int
    
    
    let cornerSize = 10
    let smallerText: CGFloat = 16
    let colBlack: UInt = 0x000000
    let colWhite: UInt = 0xFFFFFF
    let colBlue: UInt = 0x5746D2
    let colLightBlue: UInt = 0xEEEBFF
    let colPurple: UInt = 0x82779F
    let colOrange: UInt = 0xFFA115
    
    init(myId: Int, myName: String) {
        self.myId = myId
        self.myName = myName
        self.nameHolder = myName
    }
    

    var body: some View {
        VStack {
            Text("My account")
                .foregroundColor(Color(colBlack))
                .font(.system(size: 24, weight: .bold))
            
            // picture selector
            VStack {
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(Color(colBlue))
                        .font(.system(size: 150))
                }
                
                Button {
                    isPickerShowing = true
                } label: {
                    Text("Change photo")
                }
            }
            .sheet(isPresented: $isPickerShowing, onDismiss: nil) {
                ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing)
            }

            VStack {
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                        .fill(Color(colLightBlue))
                    HStack {
                        Text("Name")
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                        TextField(myName, text: $nameHolder)
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                            .disabled(!isEditable)
                    }
                }
            }
            .frame(height: 20)
            
            HStack {
                Spacer()
                if isEditable {
                    HStack {
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                    .fill(Color(colLightBlue))
                                HStack {
                                    Button("Cancel") {
                                        isEditable = !isEditable
                                        nameHolder = myName
                                    }
                                }
                            }
                        }
                        .frame(width: 90, height: 20)
                        .padding(5)
                        
                        VStack {
                            ZStack {
                                RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                    .fill(Color(colLightBlue))
                                HStack {
                                    Button("Confirm") {
                                        isEditable = !isEditable
                                        do {
                                            try myBank.changeAccountName(for: myId, to: nameHolder)
                                        } catch {
                                            
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: 90, height: 20)
                        .padding(5)
                    }
                } else {
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                                .fill(Color(colLightBlue))
                            HStack {
                                Button("Edit") {
                                    isEditable = !isEditable
                                }
                            }
                        }
                    }
                    .frame(width: 90, height: 20)
                    .padding(5)
                    
                }
            }
            
            Spacer()
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                        .fill(Color(colLightBlue))
                    HStack {
                        Text("ID")
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                        Text("\(myId)")
                            .foregroundColor(Color(colPurple))
                            .font(.system(size: 16, weight: .medium))
                            .padding(5)
                    }
                }
            }
            .frame(height: 30)
        }
        .onAppear {
            model.createIdValidationSubscription()
            model.createBalanceValidationSubscription()
        }
    }
}
