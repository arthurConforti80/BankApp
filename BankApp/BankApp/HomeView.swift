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
    let onSelectProfile: () -> Void

    private static let productsSectionID = "produtos-section"

    /// Illustrative heights for the hero mini chart. The OBP sandbox used
    /// in this project doesn't expose a historical balance endpoint, so this
    /// is a visual placeholder, not real data, until a source for it exists.
    private let heroBarHeights: [CGFloat] = [0.40, 0.55, 0.35, 0.70, 0.50, 0.85, 0.65]

    /// Monthly spending categories: also illustrative. The OBP doesn't return
    /// transaction categorization in this sandbox, so this is a visual mock
    /// until a real statement categorization use case exists.
    private let spendingCategories: [(name: String, percent: Double, color: SwiftUI.Color)] = [
        ("Shopping", 0.42, BankAppTheme.Color.emerald),
        ("Food", 0.27, BankAppTheme.Color.emerald),
        ("Transport", 0.18, BankAppTheme.Color.gold),
        ("Other", 0.13, BankAppTheme.Color.gold)
    ]

    var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(BankAppTheme.Color.negative)
                } else {
                    ScrollViewReader { scrollProxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 28) {
                                header
                                heroBalanceCard
                                quickActions(scrollProxy: scrollProxy)
                                paymentsSection
                                fxSection

                                sectionList(
                                    title: "Accounts",
                                    isEmpty: viewModel.accounts.isEmpty,
                                    emptyText: "No accounts found."
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
                                    title: "Cards",
                                    isEmpty: viewModel.cards.isEmpty,
                                    emptyText: "No cards found."
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
                                productsGrid
                            }
                            .padding(.horizontal, 28)
                            .padding(.top, 40)
                            .padding(.bottom, 24)
                        }
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
                Text("Hi,")
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
                Text(viewModel.displayName)
                    .font(BankAppTheme.Typography.display(24, weight: .bold))
                    .foregroundStyle(BankAppTheme.Color.ink)
            }

            Spacer()

            Button(action: onSelectProfile) {
                ZStack {
                    Circle().fill(BankAppTheme.Color.emerald)
                    Text(viewModel.initials)
                        .font(BankAppTheme.Typography.body(14, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.cream)
                }
                .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Profile")
        }
    }

    // MARK: - Hero (total balance + mini chart)

    private var heroBalanceCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total balance")
                        .font(BankAppTheme.Typography.body(12))
                        .foregroundStyle(BankAppTheme.Color.mutedOnInk)
                    Text(totalBalanceText)
                        .font(BankAppTheme.Typography.display(28, weight: .semibold))
                        .foregroundStyle(BankAppTheme.Color.cream)
                }

                Spacer()

                if hasKnownBalance {
                    Text("+3.2%")
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

            Text("Last 7 days")
                .font(BankAppTheme.Typography.body(11))
                .foregroundStyle(BankAppTheme.Color.mutedOnInk)
        }
        .padding(20)
        .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var hasKnownBalance: Bool {
        viewModel.accounts.contains { $0.balance != nil }
    }

    /// Sums the known balances when all accounts with a balance are in the
    /// same currency; otherwise (or with no known balance at all) shows the
    /// same unavailability text already used in the account rows, so it
    /// never displays a made-up value.
    private var totalBalanceText: String {
        let knownAccounts = viewModel.accounts.compactMap { account -> (Decimal, String)? in
            guard let balance = account.balance, let currency = account.currency else { return nil }
            return (balance, currency)
        }
        guard let firstCurrency = knownAccounts.first?.1,
              knownAccounts.allSatisfy({ $0.1 == firstCurrency }) else {
            return "Balance unavailable"
        }
        let total = knownAccounts.reduce(Decimal(0)) { $0 + $1.0 }
        return BankAppTheme.formattedBalance(total, currency: firstCurrency)
    }

    // MARK: - Quick actions

    private func quickActions(scrollProxy: ScrollViewProxy) -> some View {
        HStack {
            quickActionButton(systemImage: "arrow.up.right", label: "Transfer") {
                onSelectPayments()
            }
            Spacer()
            quickActionIcon(systemImage: "creditcard", label: "Cards")
            Spacer()
            quickActionButton(systemImage: "square.grid.2x2", label: "Products") {
                withAnimation {
                    scrollProxy.scrollTo(Self.productsSectionID, anchor: .top)
                }
            }
            Spacer()
            quickActionIcon(systemImage: "list.bullet", label: "Statement")
        }
    }

    /// Quick-reference icon, with no action of its own.
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

    /// Quick-action icon that triggers a real action (today only "Products",
    /// which scrolls down to the Products section further down the same screen).
    private func quickActionButton(systemImage: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            quickActionIcon(systemImage: systemImage, label: label)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Payments (entry point to the transfer/beneficiary/recurring payment/direct debit hub)

    private var paymentsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Payments".uppercased())
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
                        Text("Transfer")
                            .font(BankAppTheme.Typography.body(15, weight: .semibold))
                            .foregroundStyle(BankAppTheme.Color.ink)
                        Text("New, beneficiary, recurring payment or direct debit")
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

    // MARK: - Exchange rates

    private var fxSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Exchange rates".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            if viewModel.fxRates.isEmpty {
                Text("Rates unavailable right now.")
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
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        return formatter.string(from: NSDecimalNumber(decimal: value)) ?? "\(value)"
    }

    // MARK: - Spending summary

    private var spendingSummaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text("Monthly spending".uppercased())
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
        formatter.locale = Locale(identifier: "en_US")
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

    // MARK: - Products (3-column grid, icon + name)

    private var productsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Products".uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            if viewModel.products.isEmpty {
                Text("No products linked to your account")
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            } else {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                    spacing: 20
                ) {
                    ForEach(viewModel.products) { product in
                        productCell(product)
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
        .id(Self.productsSectionID)
    }

    private func productCell(_ product: Product) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(BankAppTheme.Color.cream)
                    .overlay(Circle().stroke(BankAppTheme.Color.hairline, lineWidth: 1))
                Image(systemName: iconName(for: product))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(BankAppTheme.Color.ink)
            }
            .frame(width: 48, height: 48)

            Text(product.name)
                .font(BankAppTheme.Typography.body(11))
                .foregroundStyle(BankAppTheme.Color.ink)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity)
    }

    /// Picks an icon based on keywords in the product name (the API doesn't
    /// return a product category/type, just a free-text name, so this is a
    /// heuristic, best-effort, not an official mapping). All icons use the
    /// same color (ink) and the same box (.resizable + .scaledToFit in
    /// productCell), so size doesn't vary between different SF Symbols or
    /// make one product stand out over another.
    private func iconName(for product: Product) -> String {
        let name = product.name.lowercased()

        if name.contains("mortgage") {
            return "house"
        } else if name.contains("gold") {
            return "star"
        } else if name.contains("loan") {
            return "doc.text.magnifyingglass"
        } else if name.contains("saving") {
            return "banknote"
        } else if name.contains("overdraft") {
            return "arrow.down.circle"
        } else if name.contains("credit card") || name.contains("mastercard") || name.contains("visa") || name.contains("premier") {
            return "creditcard"
        } else if name.contains("reserve") {
            return "lock.shield"
        } else {
            return "square.grid.2x2"
        }
    }

    private func balanceText(for account: Account) -> String {
        guard let balance = account.balance, let currency = account.currency else {
            return "Balance unavailable"
        }
        return BankAppTheme.formattedBalance(balance, currency: currency)
    }
}
