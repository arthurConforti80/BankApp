//
//  TransactionsSection.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import SwiftUI

/// "RECENT TRANSACTIONS" block reused by the account detail screen and the
/// card detail screen. Lives in Core for the same reason as DetailHeader:
/// both feature modules need it and can't depend on each other.
public struct TransactionsSection: View {
    private let isLoading: Bool
    private let errorMessage: String?
    private let transactions: [Transaction]

    public init(isLoading: Bool, errorMessage: String?, transactions: [Transaction]) {
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.transactions = transactions
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent transactions".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if let errorMessage {
                Text(errorMessage)
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.negative)
            } else if transactions.isEmpty {
                Text("No transactions found.")
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        if index > 0 {
                            Divider().overlay(BankAppTheme.Color.hairline)
                        }
                        TransactionRow(transaction: transaction)
                    }
                }
                .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
                )
            }
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(BankAppTheme.Typography.body(14, weight: .medium))
                    .foregroundStyle(BankAppTheme.Color.ink)
                if let date = transaction.completedDate {
                    Text(date)
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }
            }

            Spacer()

            Text(BankAppTheme.formattedSignedAmount(transaction.amount, currency: transaction.currency))
                .font(BankAppTheme.Typography.body(14, weight: .semibold))
                .foregroundStyle(transaction.amount > 0 ? BankAppTheme.Color.positive : BankAppTheme.Color.ink)
        }
        .padding(16)
    }
}
