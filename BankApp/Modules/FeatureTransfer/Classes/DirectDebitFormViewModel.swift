//
//  DirectDebitFormViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class DirectDebitFormViewModel: ObservableObject {
    /// Mesma ressalva do Pagamento recorrente: sem tela de listagem de
    /// beneficiários ainda, este campo aceita o counterparty_id colado
    /// manualmente.
    @Published public var counterpartyId: String = ""
    @Published public var startDate: Date = Date()
    @Published public var hasEndDate: Bool = false
    @Published public var endDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 365)
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSaved: Bool = false

    public let account: Account
    private let useCase: DirectDebitUseCaseProtocol

    public init(account: Account, useCase: DirectDebitUseCaseProtocol) {
        self.account = account
        self.useCase = useCase
    }

    public func save() {
        errorMessage = nil

        guard !counterpartyId.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Enter the company/beneficiary ID."
            return
        }

        isSubmitting = true

        Task {
            do {
                try await useCase.createDirectDebit(
                    for: account,
                    counterpartyId: counterpartyId,
                    startDate: startDate,
                    endDate: hasEndDate ? endDate : nil
                )
                isSubmitting = false
                isSaved = true
            } catch {
                isSubmitting = false
                errorMessage = "Couldn't activate the direct debit."
            }
        }
    }
}
