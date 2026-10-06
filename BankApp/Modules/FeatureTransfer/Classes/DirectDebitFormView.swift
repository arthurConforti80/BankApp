//
//  DirectDebitFormView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import SwiftUI
import Core

public struct DirectDebitFormView: View {
    @ObservedObject private var viewModel: DirectDebitFormViewModel
    private let onBack: () -> Void

    public init(viewModel: DirectDebitFormViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Direct debit", onBack: onBack)

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
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Authorize a charge")
                        .font(BankAppTheme.Typography.display(20, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text("The chosen company will be able to charge your account directly")
                        .font(BankAppTheme.Typography.body(14))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }

                underlinedField(label: "Company/beneficiary ID (counterparty_id)", placeholder: "Paste a saved beneficiary's ID", text: $viewModel.counterpartyId)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Start date")
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                    DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(BankAppTheme.Color.ink)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Set end date", isOn: $viewModel.hasEndDate)
                        .font(BankAppTheme.Typography.body(14))
                        .tint(BankAppTheme.Color.emerald)

                    if viewModel.hasEndDate {
                        DatePicker("End date", selection: $viewModel.endDate, displayedComponents: .date)
                            .font(BankAppTheme.Typography.body(14))
                            .tint(BankAppTheme.Color.ink)
                    }
                }

                Text("The amount of each charge is set by the company per invoice. You'll still see every debit on your statement and can cancel at any time.")
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(BankAppTheme.Color.hairline, lineWidth: 1))

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
                            Text("Activate direct debit")
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

            Text("Direct debit active")
                .font(BankAppTheme.Typography.display(20, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Text("The authorization has been registered. Every future charge will show up on your statement as usual.")
                .font(BankAppTheme.Typography.body(14))
                .foregroundStyle(BankAppTheme.Color.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

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
}
