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
    private let onBack: () -> Void

    public init(viewModel: CardDetailViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Card", onBack: onBack)

                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.card.nameOnCard)
                                .font(BankAppTheme.Typography.display(22, weight: .bold))
                                .foregroundStyle(BankAppTheme.Color.ink)
                            Text(viewModel.card.maskedNumber)
                                .font(BankAppTheme.Typography.body(13))
                                .foregroundStyle(BankAppTheme.Color.mutedText)
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
