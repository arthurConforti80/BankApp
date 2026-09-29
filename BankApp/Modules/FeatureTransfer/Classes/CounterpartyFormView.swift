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
                DetailHeader(title: "Novo beneficiário", onBack: onBack)

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
                    Text("Dados do beneficiário")
                        .font(BankAppTheme.Typography.display(20, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                    Text("Guarde os dados pra usar em transferências futuras")
                        .font(BankAppTheme.Typography.body(14))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }

                underlinedField(label: "Nome do beneficiário", placeholder: "Nome completo", text: $viewModel.name)
                underlinedField(label: "Apelido (opcional)", placeholder: "Ex.: Renda, Sócio, Família", text: $viewModel.nickname)
                underlinedField(label: "IBAN", placeholder: "PT50 0002 0123 1234 5678 9015 4", text: $viewModel.iban)
                underlinedField(label: "Banco (opcional)", placeholder: "Ex.: Open Bank Project", text: $viewModel.bankName)

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
                            Text("Salvar beneficiário")
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

            Text("Beneficiário salvo")
                .font(BankAppTheme.Typography.display(20, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Text("Já pode usá-lo nas próximas transferências, pagamentos recorrentes ou débitos automáticos.")
                .font(BankAppTheme.Typography.body(14))
                .foregroundStyle(BankAppTheme.Color.mutedText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 280)

            if let counterpartyId = viewModel.savedCounterpartyId {
                counterpartyIdCard(counterpartyId)
            }

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

    /// Enquanto não existe uma tela de listagem de beneficiários, exibe
    /// o ID recém-criado pra ser copiado e colado nos formulários de
    /// pagamento recorrente e débito automático.
    @ViewBuilder
    private func counterpartyIdCard(_ counterpartyId: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("ID do beneficiário (counterparty_id)")
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
