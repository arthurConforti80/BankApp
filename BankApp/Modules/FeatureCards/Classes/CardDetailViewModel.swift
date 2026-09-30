//
//  CardDetailViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class CardDetailViewModel: ObservableObject {
    @Published public var transactions: [Transaction] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    public let card: CreditCard
    private let cardsUseCase: CardsUseCaseProtocol

    public init(card: CreditCard, cardsUseCase: CardsUseCaseProtocol) {
        self.card = card
        self.cardsUseCase = cardsUseCase
    }

    public func loadTransactions() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                transactions = try await cardsUseCase.fetchRecentTransactions(for: card, limit: 5)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Couldn't load the statement."
            }
        }
    }
}
