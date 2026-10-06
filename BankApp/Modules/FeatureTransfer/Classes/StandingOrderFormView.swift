//
//  StandingOrderFormView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import SwiftUI
import Core

public struct StandingOrderFormView: View {
    @ObservedObject private var viewModel: StandingOrderFormViewModel
    private let onBack: () -> Void

    public init(viewModel: StandingOrderFormViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Recurring payment", onBack: onBack)

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
                    Text("Schedule a payment")
                        .font(BankAppTheme.Typography.display(20, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text("E.g.: \"pay rent every 5th\"")
                        .font(BankAppTheme.Typography.body(14))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }

                underlinedField(label: "Beneficiary ID (counterparty_id)", placeholder: "Paste a saved beneficiary's ID", text: $viewModel.counterpartyId)

                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    TextField("0.00", text: $viewModel.amountText)
                        .keyboardType(.decimalPad)
                        .font(BankAppTheme.Typography.display(28, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text(viewModel.account.currency ?? "EUR")
                        .font(BankAppTheme.Typography.body(15))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }
                .padding(.bottom, 10)
                .overlay(alignment: .bottom) {
                    Rectangle().fill(BankAppTheme.Color.hairline).frame(height: 1.5)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Frequency")
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)

                    HStack(spacing: 8) {
                        ForEach(StandingOrderFormViewModel.Frequency.allCases) { option in
                            frequencyChip(option)
                        }
                    }
                }

                HStack(spacing: 14) {
                    underlinedField(label: "Day of month", placeholder: "5", text: $viewModel.dayOfMonth)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Start date")
                            .font(BankAppTheme.Typography.body(12))
                            .foregroundStyle(BankAppTheme.Color.mutedText)
                        DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                            .labelsHidden()
                            .tint(BankAppTheme.Color.ink)
                    }
                    .frame(maxWidth: .infinity)
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
                            Text("Schedule payment")
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

    private func frequencyChip(_ option: StandingOrderFormViewModel.Frequency) -> some View {
        let isSelected = viewModel.frequency == option
        return Button {
            viewModel.frequency = option
        } label: {
            Text(option.label)
                .font(BankAppTheme.Typography.body(13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(isSelected ? BankAppTheme.Color.cream : BankAppTheme.Color.ink)
                .background(
                    isSelected ? BankAppTheme.Color.ink : BankAppTheme.Color.cardFill,
                    in: Capsule()
                )
                .overlay(
                    Capsule().stroke(BankAppTheme.Color.hairline, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
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

            Text("Payment scheduled")
                .font(BankAppTheme.Typography.display(20, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Text("We'll repeat this payment automatically, at the chosen frequency, until you cancel it.")
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
