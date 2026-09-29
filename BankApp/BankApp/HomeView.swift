//
//  HomeView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import SwiftUI
import Core
import FeatureFX

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onSelectAccount: (Account) -> Void
    let onSelectCard: (CreditCard) -> Void
    let onSelectPayments: () -> Void

    /// Alturas ilustrativas para o mini-gráfico do hero. A sandbox OBP usada
    /// neste projeto não expõe um endpoint de saldo histórico — isto é um
    /// placeholder visual, não dado real, até existir uma fonte pra isso.
    private let heroBarHeights: [CGFloat] = [0.40, 0.55, 0.35, 0.70, 0.50, 0.85, 0.65]

    /// Categorias de gastos do mês: também ilustrativas. A OBP não devolve
    /// categorização de transações nesta sandbox, então isto é um mock
    /// visual até existir um use case real de categorização de extrato.
    private let spendingCategories: [(name: String, percent: Double, color: SwiftUI.Color)] = [
        ("Compras", 0.42, BankAppTheme.Color.emerald),
        ("Alimentação", 0.27, BankAppTheme.Color.emerald),
        ("Transporte", 0.18, BankAppTheme.Color.gold),
        ("Outros", 0.13, BankAppTheme.Color.gold)
    ]

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
                        VStack(alignment: .leading, spacing: 28) {
                            header
                            heroBalanceCard
                            quickActions
                            paymentsSection
                            fxSection

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

                            spendingSummaryCard

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

    // MARK: - Hero (saldo total + mini-gráfico)

    private var heroBalanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Saldo total")
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedOnInk)
                    Text(totalBalanceText)
                        .font(BankAppTheme.Typography.display(28, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.cream)
                }

                Spacer()

                if hasKnownBalance {
                    Text("+3,2%")
                        .font(BankAppTheme.Typography.body(11, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.ink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(BankAppTheme.Color.gold, in: Capsule())
                }
            }

            HStack(alignment: .bottom, spacing: 5) {
                ForEach(Array(heroBarHeights.enumerated()), id: \.offset) { index, height in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(index >= heroBarHeights.count - 2 ? BankAppTheme.Color.gold : BankAppTheme.Color.barMuted)
                        .frame(height: 40 * height)
                }
            }
            .frame(height: 40, alignment: .bottom)

            Text("Últimos 7 dias")
                .font(BankAppTheme.Typography.body(11))
                .foregroundStyle(BankAppTheme.Color.mutedOnInk)
        }
        .padding(20)
        .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var hasKnownBalance: Bool {
        viewModel.accounts.contains { $0.balance != nil }
    }

    /// Soma os saldos conhecidos quando todas as contas com saldo estão na
    /// mesma moeda; caso contrário (ou sem nenhum saldo conhecido) mostra o
    /// mesmo texto de indisponibilidade já usado nas linhas de conta, para
    /// nunca exibir um valor inventado.
    private var totalBalanceText: String {
        let knownAccounts = viewModel.accounts.compactMap { account -> (Decimal, String)? in
            guard let balance = account.balance, let currency = account.currency else { return nil }
            return (balance, currency)
        }
        guard let firstCurrency = knownAccounts.first?.1,
              knownAccounts.allSatisfy({ $0.1 == firstCurrency }) else {
            return "Saldo indisponível"
        }
        let total = knownAccounts.reduce(Decimal(0)) { $0 + $1.0 }
        return BankAppTheme.formattedBalance(total, currency: firstCurrency)
    }

    // MARK: - Ações rápidas

    private var quickActions: some View {
        HStack {
            quickActionIcon(systemImage: "arrow.up.right", label: "Transferir")
            Spacer()
            quickActionIcon(systemImage: "creditcard", label: "Cartões")
            Spacer()
            quickActionIcon(systemImage: "square.grid.2x2", label: "Produtos")
            Spacer()
            quickActionIcon(systemImage: "list.bullet", label: "Extrato")
        }
    }

    /// Ícones de referência rápida, sem ação própria — a entrada real pra
    /// pagamentos é o card "Transferência" logo abaixo (ver
    /// paymentsSection), igual ao mockup aprovado no canvas.
    private func quickActionIcon(systemImage: String, label: String) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(BankAppTheme.Color.cream)
                    .overlay(Circle().stroke(BankAppTheme.Color.hairline, lineWidth: 1))
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(BankAppTheme.Color.ink)
            }
            .frame(width: 52, height: 52)

            Text(label)
                .font(BankAppTheme.Typography.body(11))
                .foregroundStyle(BankAppTheme.Color.ink)
        }
        .frame(width: 72)
    }

    // MARK: - Pagamentos (entrada pro hub de transferência/beneficiário/recorrente/débito)

    private var paymentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Pagamentos".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            Button(action: onSelectPayments) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(BankAppTheme.Color.emerald)
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(BankAppTheme.Color.cream)
                    }
                    .frame(width: 40, height: 40)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Transferência")
                            .font(BankAppTheme.Typography.body(15, weight: .semibold))
                            .foregroundStyle(BankAppTheme.Color.ink)
                        Text("Nova, beneficiário, recorrente ou débito automático")
                            .font(BankAppTheme.Typography.body(12))
                            .foregroundStyle(BankAppTheme.Color.mutedText)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.mutedText)
                }
                .padding(16)
                .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.accounts.isEmpty)
            .opacity(viewModel.accounts.isEmpty ? 0.5 : 1)
        }
    }

    // MARK: - Câmbio

    private var fxSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Câmbio".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            if viewModel.fxRates.isEmpty {
                Text("Taxas indisponíveis no momento.")
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.fxRates.enumerated()), id: \.element.id) { index, rate in
                        if index > 0 {
                            Divider().overlay(BankAppTheme.Color.hairline)
                        }
                        fxRow(rate)
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

    private func fxRow(_ rate: FxRate) -> some View {
        HStack {
            Text("\(rate.fromCurrency) → \(rate.toCurrency)")
                .font(BankAppTheme.Typography.body(15, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedRate(rate.conversionValue))
                    .font(BankAppTheme.Typography.body(15, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                Text("1 \(rate.fromCurrency)")
                    .font(BankAppTheme.Typography.body(11))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }
        }
        .padding(16)
    }

    private func formattedRate(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
    }

    // MARK: - Resumo de gastos

    private var spendingSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Gastos do mês".uppercased())
                    .font(BankAppTheme.Typography.body(12, weight: .semibold))
                    .tracking(0.5)
                    .foregroundStyle(BankAppTheme.Color.mutedText)
                Spacer()
                Text(currentMonthName)
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }

            VStack(spacing: 14) {
                ForEach(spendingCategories, id: \.name) { category in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(category.name)
                                .font(BankAppTheme.Typography.body(13))
                                .foregroundStyle(BankAppTheme.Color.ink)
                            Spacer()
                            Text("\(Int(category.percent * 100))%")
                                .font(BankAppTheme.Typography.body(13))
                                .foregroundStyle(BankAppTheme.Color.mutedText)
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Capsule().fill(BankAppTheme.Color.trackFill)
                                Capsule()
                                    .fill(category.color)
                                    .frame(width: geometry.size.width * category.percent)
                            }
                        }
                        .frame(height: 6)
                    }
                }
            }
            .padding(18)
            .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(BankAppTheme.Color.hairline, lineWidth: 1)
            )
        }
    }

    private var currentMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "LLLL"
        return formatter.string(from: Date()).capitalized
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
