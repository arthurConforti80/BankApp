//
//  HomeView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import SwiftUI
import Core

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onSelectAccount: (Account) -> Void
    let onSelectCard: (CreditCard) -> Void
    let onSelectTransfer: () -> Void

    var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            Group {
                if viewModel.isLoading {
                    ProgressView("Carregando...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(BankAppTheme.Color.negative)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 32) {
                            header

                            sectionList(
                                title: "Contas",
                                isEmpty: viewModel.accounts.isEmpty,
                                emptyText: "Nenhuma conta encontrada."
                            ) {
                                ForEach(Array(viewModel.accounts.enumerated()), id: \.element.id) { index, account in
                                    if index > 0 {
                                        Divider().overlay(BankAppTheme.Color.hairline)
                                    }
                                    Button {
                                        onSelectAccount(account)
                                    } label: {
                                        accountRow(account)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            sectionList(
                                title: "Cartões",
                                isEmpty: viewModel.cards.isEmpty,
                                emptyText: "Nenhum cartão encontrado."
                            ) {
                                ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                                    if index > 0 {
                                        Divider().overlay(BankAppTheme.Color.hairline)
                                    }
                                    Button {
                                        onSelectCard(card)
                                    } label: {
                                        cardRow(card)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                            transferSection

                            sectionList(
                                title: "Produtos",
                                isEmpty: viewModel.products.isEmpty,
                                emptyText: "Não tem produtos relacionados a sua conta"
                            ) {
                                ForEach(Array(viewModel.products.enumerated()), id: \.element.id) { index, product in
                                    if index > 0 {
                                        Divider().overlay(BankAppTheme.Color.hairline)
                                    }
                                    productRow(product)
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 40)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.load()
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Olá,")
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
                Text(viewModel.displayName)
                    .font(BankAppTheme.Typography.display(24, weight: .bold))
                    .foregroundStyle(BankAppTheme.Color.ink)
            }

            Spacer()

            ZStack {
                Circle().fill(BankAppTheme.Color.emerald)
                Text(viewModel.initials)
                    .font(BankAppTheme.Typography.body(14, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.cream)
            }
            .frame(width: 44, height: 44)
        }
    }

    private var transferSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Transferências".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            Button(action: onSelectTransfer) {
                transferRow
            }
            .buttonStyle(.plain)
            .disabled(viewModel.accounts.isEmpty)
            .opacity(viewModel.accounts.isEmpty ? 0.5 : 1)
        }
    }

    private var transferRow: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(BankAppTheme.Color.emerald)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.cream)
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("Nova transferência")
                    .font(BankAppTheme.Typography.body(15, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                Text("Entre as suas contas")
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }

            Spacer()
        }
        .padding(16)
        .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
        )
    }

    @ViewBuilder
    private func sectionList<Content: View>(
        title: String,
        isEmpty: Bool,
        emptyText: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            if isEmpty {
                Text(emptyText)
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            } else {
                VStack(spacing: 0) {
                    content()
                }
                .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
                )
            }
        }
    }

    private func accountRow(_ account: Account) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text(account.label)
                    .font(BankAppTheme.Typography.body(15, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                if let iban = account.iban {
                    Text(iban)
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }
            }

            Spacer()

            Text(balanceText(for: account))
                .font(BankAppTheme.Typography.body(13))
                .foregroundStyle(BankAppTheme.Color.mutedText)
        }
        .padding(16)
    }

    private func cardRow(_ card: CreditCard) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(BankAppTheme.Color.ink)
                .frame(width: 40, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(card.nameOnCard)
                    .font(BankAppTheme.Typography.body(15, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                Text(card.maskedNumber)
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }

            Spacer()
        }
        .padding(16)
    }

    private func productRow(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(product.name)
                .font(BankAppTheme.Typography.body(15, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)
            if let description = product.description, !description.isEmpty {
                Text(description)
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func balanceText(for account: Account) -> String {
        guard let balance = account.balance, let currency = account.currency else {
            return "Saldo indisponível"
        }
        return BankAppTheme.formattedBalance(balance, currency: currency)
    }
}
