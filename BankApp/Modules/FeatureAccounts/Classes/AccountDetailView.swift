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
    private let onBack: () -> Void

    public init(viewModel: AccountDetailViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Account", onBack: onBack)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.account.label)
                                .font(BankAppTheme.Typography.display(22, weight: .bold))
                                .foregroundStyle(BankAppTheme.Color.ink)
                            if let iban = viewModel.account.iban {
                                Text(iban)
                                    .font(BankAppTheme.Typography.body(13))
                                    .foregroundStyle(BankAppTheme.Color.mutedText)
                            }
                        }

                        TransactionsSection(
                            isLoading: viewModel.isLoading,
                            errorMessage: viewModel.errorMessage,
                            transactions: viewModel.transactions
                        )
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}
