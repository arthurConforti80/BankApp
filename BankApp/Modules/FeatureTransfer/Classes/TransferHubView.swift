//
//  TransferHubView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import SwiftUI
import Core

/// Tela de escolha entre os quatro tipos de pagamento/transferência. Fica
/// em FeatureTransfer (não no app target) porque só compõe telas do
/// próprio módulo — diferente da Home, que precisa combinar módulos
/// diferentes e por isso vive no target de composição.
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
                DetailHeader(title: "Pagamentos", onBack: onBack)

                Text("O que você quer fazer?")
                    .font(BankAppTheme.Typography.display(22, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                    .padding(.horizontal, 28)
                    .padding(.top, 8)
                    .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 12) {
                        hubRow(
                            icon: "arrow.up.right",
                            title: "Nova transferência",
                            subtitle: "Para um IBAN, com confirmação por código",
                            action: onNewTransfer
                        )
                        hubRow(
                            icon: "person.2",
                            title: "Novo beneficiário",
                            subtitle: "Guarde um contato pra transferir mais rápido",
                            action: onNewCounterparty
                        )
                        hubRow(
                            icon: "calendar",
                            title: "Pagamento recorrente",
                            subtitle: "Agende um valor fixo, todo mês",
                            action: onStandingOrder
                        )
                        hubRow(
                            icon: "arrow.triangle.2.circlepath",
                            title: "Débito automático",
                            subtitle: "Autorize uma empresa a cobrar direto na conta",
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
