//
//  AccountsListView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import SwiftUI
import Core

public struct AccountsListView: View {
    @ObservedObject private var viewModel: AccountsViewModel

    public init(viewModel: AccountsViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Carregando contas...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                List(viewModel.accounts) { account in
                    AccountRow(account: account)
                }
            }
        }
        .navigationTitle("Minhas contas")
        .onAppear {
            viewModel.loadAccounts()
        }
    }
}

private struct AccountRow: View {
    let account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(account.label)
                .font(.headline)
            if let iban = account.iban {
                Text(iban)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let balance = account.balance, let currency = account.currency {
                Text("\(balance) \(currency)")
                    .foregroundStyle(.secondary)
            } else {
                Text("Saldo indisponível")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
