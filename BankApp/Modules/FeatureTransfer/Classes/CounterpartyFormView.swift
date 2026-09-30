//
//  CounterpartyFormView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import SwiftUI
import UIKit
import Core

public struct CounterpartyFormView: View {
    @ObservedObject private var viewModel: CounterpartyFormViewModel
    private let onBack: () -> Void

    public init(viewModel: CounterpartyFormViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "New beneficiary", onBack: onBack)

                if viewModel.isSaved {
                    successView
                } else {
                    formView
                }
            }
        }
        .navigationBarHidden(true)
    }

    private var formView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Beneficiary details")
                        .font(BankAppTheme.Typography.display(20, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text("Save these details to use in future transfers")
                        .font(BankAppTheme.Typography.body(14))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }

                underlinedField(label: "Beneficiary name", placeholder: "Full name", text: $viewModel.name)
                underlinedField(label: "Nickname (optional)", placeholder: "E.g.: Rent, Partner, Family", text: $viewModel.nickname)
                underlinedField(label: "IBAN", placeholder: "PT50 0002 0123 1234 5678 9015 4", text: $viewModel.iban)
                underlinedField(label: "Bank (optional)", placeholder: "E.g.: Open Bank Project", text: $viewModel.bankName)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(BankAppTheme.Typography.body(13))
                        .foregroundStyle(BankAppTheme.Color.negative)
                }

                Button {
                    viewModel.save()
                } label: {
                    ZStack {
                        if viewModel.isSubmitting {
                            ProgressView().tint(BankAppTheme.Color.cream)
                        } else {
                            Text("Save beneficiary")
                                .font(BankAppTheme.Typography.body(16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                }
                .foregroundStyle(BankAppTheme.Color.cream)
                .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .disabled(viewModel.isSubmitting)
            }
            .padding(.horizontal, 28)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
    }

    @ViewBuilder
    private func underlinedField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(BankAppTheme.Typography.body(12))
                .foregroundStyle(BankAppTheme.Color.mutedText)

            TextField(placeholder, text: text)
                .font(BankAppTheme.Typography.body(15))
                .foregroundStyle(BankAppTheme.Color.ink)
                .padding(.vertical, 8)
                .autocorrectionDisabled()

            Rectangle().fill(BankAppTheme.Color.hairline).frame(height: 1.5)
        }
    }

    private var successView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle().fill(BankAppTheme.Color.emerald)
                Image(systemName: "checkmark")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(BankAppTheme.Color.cream)
            }
            .frame(width: 64, height: 64)

            Text("Beneficiary saved")
                .font(BankAppTheme.Typography.display(20, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Text("You can now use it in future transfers, recurring payments or direct debits.")
                .font(BankAppTheme.Typography.body(14))
                .foregroundStyle(BankAppTheme.Color.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let counterpartyId = viewModel.savedCounterpartyId {
                counterpartyIdCard(counterpartyId)
            }

            Button(action: onBack) {
                Text("Back to payments")
                    .font(BankAppTheme.Typography.body(16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
            }
            .foregroundStyle(BankAppTheme.Color.cream)
            .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }

    /// While there's no beneficiary listing screen yet, shows the
    /// newly created ID to be copied and pasted into the recurring payment
    /// and direct debit forms.
    @ViewBuilder
    private func counterpartyIdCard(_ counterpartyId: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Beneficiary ID (counterparty_id)")
                .font(BankAppTheme.Typography.body(11))
                .foregroundStyle(BankAppTheme.Color.mutedText)

            HStack {
                Text(counterpartyId)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(BankAppTheme.Color.ink)
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()

                Button {
                    UIPasteboard.general.string = counterpartyId
                } label: {
                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(BankAppTheme.Color.ink)
                }
            }
        }
        .padding(12)
        .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(BankAppTheme.Color.hairline, lineWidth: 1))
        .frame(maxWidth: 280)
    }
}
