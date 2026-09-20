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
        HStack {
            Text(account.label)
            Spacer()
            Text("\(account.balance) \(account.currency)")
                .foregroundStyle(.secondary)
        }
    }
}
