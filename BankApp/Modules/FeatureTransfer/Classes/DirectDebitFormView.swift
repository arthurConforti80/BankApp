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
                DetailHeader(title: "Débito automático", onBack: onBack)

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
                    Text("Autorizar cobrança")
                        .font(BankAppTheme.Typography.display(20, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text("A empresa escolhida poderá debitar direto da sua conta")
                        .font(BankAppTheme.Typography.body(14))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }

                underlinedField(label: "ID da empresa/beneficiário (counterparty_id)", placeholder: "Colar o ID de um beneficiário salvo", text: $viewModel.counterpartyId)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Início")
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                    DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                        .labelsHidden()
                        .tint(BankAppTheme.Color.ink)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Toggle("Definir data de término", isOn: $viewModel.hasEndDate)
                        .font(BankAppTheme.Typography.body(14))
                        .tint(BankAppTheme.Color.emerald)

                    if viewModel.hasEndDate {
                        DatePicker("Data de término", selection: $viewModel.endDate, displayedComponents: .date)
                            .font(BankAppTheme.Typography.body(14))
                            .tint(BankAppTheme.Color.ink)
                    }
                }

                Text("O valor de cada cobrança é definido pela empresa a cada fatura — você continua vendo cada débito no seu extrato e pode cancelar a qualquer momento.")
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
                            Text("Ativar débito automático")
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

            Text("Débito automático ativo")
                .font(BankAppTheme.Typography.display(20, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Text("A autorização foi registrada. Cada cobrança futura vai aparecer no seu extrato normalmente.")
                .font(BankAppTheme.Typography.body(14))
                .foregroundStyle(BankAppTheme.Color.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            Button(action: onBack) {
                Text("Voltar aos pagamentos")
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
