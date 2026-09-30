//
//  HomeViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation
import Combine
import Core
import FeatureAccounts
import FeatureCards
import FeatureProducts
import FeatureFX

/// Lives in the app target, not in any feature module, because it needs to
/// know about FeatureAccounts, FeatureCards, FeatureProducts and FeatureFX to
/// combine their lists into a single screen, and only the composition target
/// can do that without violating the module boundary between features.
@MainActor
final class HomeViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var cards: [CreditCard] = []
    @Published var products: [Product] = []
    @Published var fxRates: [FxRate] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// Authenticated OBP username (e.g. "Robert.Us.01"), used only for the
    /// Home greeting and avatar. The API doesn't return a display name.
    let username: String

    private let accountsUseCase: AccountsUseCaseProtocol
    private let cardsUseCase: CardsUseCaseProtocol
    private let productsUseCase: ProductsUseCaseProtocol
    private let fxUseCase: FxUseCaseProtocol

    init(
        username: String,
        accountsUseCase: AccountsUseCaseProtocol,
        cardsUseCase: CardsUseCaseProtocol,
        productsUseCase: ProductsUseCaseProtocol,
        fxUseCase: FxUseCaseProtocol
    ) {
        self.username = username
        self.accountsUseCase = accountsUseCase
        self.cardsUseCase = cardsUseCase
        self.productsUseCase = productsUseCase
        self.fxUseCase = fxUseCase
    }

    /// First name extracted from the username (e.g. "Robert.Us.01" -> "Robert").
    var displayName: String {
        username.split(separator: ".").first.map(String.init) ?? username
    }

    /// Initials for the avatar: one letter from each of the first two
    /// alphabetic components of the username (e.g. "Robert.Us.01" -> "RU").
    var initials: String {
        let letterComponents = username
            .split(separator: ".")
            .filter { $0.contains(where: { $0.isLetter }) }
        let letters = letterComponents.prefix(2).compactMap { $0.first }
        return String(letters).uppercased()
    }

    func load() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                async let accountsResult = accountsUseCase.fetchAccounts()
                async let cardsResult = cardsUseCase.fetchCards()
                let (fetchedAccounts, fetchedCards) = try await (accountsResult, cardsResult)
                accounts = fetchedAccounts
                cards = fetchedCards
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Couldn't load accounts and cards."
            }

            // Products and exchange rates are handled separately, best-effort:
            // a failure here (or a sandbox with no registered data) shouldn't
            // bring down the whole Home screen. The UI already treats an empty
            // list as a normal state, never as an error.
            products = (try? await productsUseCase.fetchProducts()) ?? []
            fxRates = (try? await fxUseCase.fetchRates()) ?? []
        }
    }
}
