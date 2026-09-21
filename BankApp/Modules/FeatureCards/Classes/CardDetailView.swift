//
//  CardDetailView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import SwiftUI
import Core

public struct CardDetailView: View {
    @ObservedObject private var viewModel: CardDetailViewModel

    public init(viewModel: CardDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section("Cartão") {
                Text(viewModel.card.nameOnCard)
                Text(viewModel.card.maskedNumber)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Últimas transações da conta vinculada") {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                } else if viewModel.transactions.isEmpty {
                    Text("Nenhuma transação encontrada.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.transactions) { transaction in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(transaction.description)
                            Text("\(transaction.amount) \(transaction.currency)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.card.nameOnCard)
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}
