//
//  TransferView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import SwiftUI
import Core

public struct TransferView: View {
    @ObservedObject private var viewModel: TransferViewModel
    private let onBack: () -> Void

    public init(viewModel: TransferViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Nova transferência", onBack: onBack)

                if viewModel.isCompleted {
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
            VStack(alignment: .leading, spacing: 26) {
                originSection
                destinationSection
                amountSection

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(BankAppTheme.Typography.body(13))
                        .foregroundStyle(BankAppTheme.Color.negative)
                }

                Button {
                    viewModel.submit()
                } label: {
                    ZStack {
                        if viewModel.isSubmitting {
                            ProgressView()
                                .tint(BankAppTheme.Color.cream)
                        } else {
                            Text("Transferir")
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

    private var originSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("De".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.fromAccount.label)
                    .font(BankAppTheme.Typography.body(15, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                if let iban = viewModel.fromAccount.iban {
                    Text(iban)
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
            )
        }
    }

    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Para".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            underlinedField(label: "IBAN do beneficiário", placeholder: "PT50 0002 0123 1234 5678 9015 4", text: $viewModel.destinationIBAN)
            underlinedField(label: "Nome do beneficiário", placeholder: "Nome completo", text: $viewModel.beneficiaryName)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Valor".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            HStack(alignment: .lastTextBaseline, spacing: 8) {
                TextField("0,00", text: $viewModel.amountText)
                    .keyboardType(.decimalPad)
                    .font(BankAppTheme.Typography.display(28, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)

                Text("EUR")
                    .font(BankAppTheme.Typography.body(15))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }
            .padding(.bottom, 10)
            .overlay(alignment: .bottom) {
                Rectangle().fill(BankAppTheme.Color.hairline).frame(height: 1.5)
            }

            underlinedField(label: "Descrição (opcional)", placeholder: "Ex.: Renda de setembro", text: $viewModel.note)
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

            Rectangle()
                .fill(BankAppTheme.Color.hairline)
                .frame(height: 1.5)
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

            Text("Transferência enviada")
                .font(BankAppTheme.Typography.display(20, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Text("O seu pedido foi enviado à sandbox Open Bank Project e será processado em instantes.")
                .font(BankAppTheme.Typography.body(14))
                .foregroundStyle(BankAppTheme.Color.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            Button(action: onBack) {
                Text("Voltar à Home")
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
