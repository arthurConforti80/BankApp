//
//  AccountDetailView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import SwiftUI
import Core

public struct AccountDetailView: View {
    @ObservedObject private var viewModel: AccountDetailViewModel

    public init(viewModel: AccountDetailViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        List {
            Section("Conta") {
                Text(viewModel.account.label)
                if let iban = viewModel.account.iban {
                    Text(iban)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section("Últimas transações") {
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
        .navigationTitle(viewModel.account.label)
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}
