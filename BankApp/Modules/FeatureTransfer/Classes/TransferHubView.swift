//
//  TransferHubView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import SwiftUI
import Core

/// Screen for choosing between the four payment/transfer types. Lives in
/// FeatureTransfer (not in the app target) because it only composes screens
/// from its own module, unlike Home, which needs to combine different
/// modules and therefore lives in the composition target.
public struct TransferHubView: View {
    private let onNewTransfer: () -> Void
    private let onNewCounterparty: () -> Void
    private let onStandingOrder: () -> Void
    private let onDirectDebit: () -> Void
    private let onBack: () -> Void

    public init(
        onNewTransfer: @escaping () -> Void,
        onNewCounterparty: @escaping () -> Void,
        onStandingOrder: @escaping () -> Void,
        onDirectDebit: @escaping () -> Void,
        onBack: @escaping () -> Void
    ) {
        self.onNewTransfer = onNewTransfer
        self.onNewCounterparty = onNewCounterparty
        self.onStandingOrder = onStandingOrder
        self.onDirectDebit = onDirectDebit
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Payments", onBack: onBack)

                Text("What would you like to do?")
                    .font(BankAppTheme.Typography.display(22, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                    .padding(.horizontal, 28)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 12) {
                        hubRow(
                            icon: "arrow.up.right",
                            title: "New transfer",
                            subtitle: "To an IBAN, with code confirmation",
                            action: onNewTransfer
                        )
                        hubRow(
                            icon: "person.2",
                            title: "New beneficiary",
                            subtitle: "Save a contact to transfer faster",
                            action: onNewCounterparty
                        )
                        hubRow(
                            icon: "calendar",
                            title: "Recurring payment",
                            subtitle: "Schedule a fixed amount, every month",
                            action: onStandingOrder
                        )
                        hubRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Direct debit",
                            subtitle: "Authorize a company to charge your account directly",
                            action: onDirectDebit
                        )
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 4)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func hubRow(icon: String, title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(BankAppTheme.Color.emerald)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(BankAppTheme.Color.cream)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(BankAppTheme.Typography.body(15, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text(subtitle)
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }
            .padding(18)
            .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
