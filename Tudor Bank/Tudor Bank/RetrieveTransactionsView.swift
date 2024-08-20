//
//  RetrieveTransactionsView.swift
//  Tudor Bank
//
//  Created by David Tudor on 15/02/2024.
//

import Foundation
import SwiftUI
import BankingEngine

struct RetrieveTransactionsView: View {
    @StateObject private var model = Model()
    @State var output = ""
    @State var transactions: Array<BankTransaction> = []
    @EnvironmentObject var myBank: BankingEngine
    
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
    
    func buildListItem(with transaction: BankTransaction, isDarkBlue: Bool) -> some View {
        ZStack (alignment: .topLeading) {
            RoundedRectangle(cornerSize: CGSize(width: cornerSize, height: cornerSize))
                .fill(Color(isDarkBlue ? colBlue1 : colBlue2))
            
            HStack {
                VStack(alignment: .leading) {
                    switch (transaction.sourceId, transaction.destinationId) {
                    // cases in order from most specific
                    case (let account, myId):
                        buildListTitle(with: "Transfer from \(account)")
                    case (myId, let account):
                        buildListTitle(with: "Transfer to \(account)")
                    case (_, myId):
                        buildListTitle(with: "Deposit")
                    case (myId, _):
                        buildListTitle(with: "Withdrawal")
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
                let amount = transaction.amount as Decimal
                Text((transaction.type == .credit ? "+" : "-") + amount.formatted(.currency(code: "GBP")))
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
                //Text("Recent transactions")
//                    .foregroundColor(Color(colBlack))
//                    .font(.system(size: 28, weight: .bold))
//                    .padding(EdgeInsets())
                // if no error message i.e there are transactions
                if transactions.count != 0 {
                    ScrollView {
                        VStack {
                            ForEach(0..<transactions.count , id: \.self) { i in
                                buildListItem(with: transactions[transactions.count - 1 - i], isDarkBlue: (i % 2) == 0)
                            }
                        }
                    }
                } else {
                    Text("No transactions found")
                }
            }
            .navigationTitle("Recent transactions")
            .navigationBarTitleDisplayMode(.large)
        }
        .onReceive(myBank.allTransactions, perform: { _ in
            transactions = (try? myBank.retrieveTransactions(accountId: myId)) ?? []
            
        })
    }
}
