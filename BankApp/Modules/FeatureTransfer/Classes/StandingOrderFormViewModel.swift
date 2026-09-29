//
//  StandingOrderFormViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class StandingOrderFormViewModel: ObservableObject {
    public enum Frequency: String, CaseIterable, Identifiable {
        case weekly = "WEEKLY"
        case monthly = "MONTHLY"
        case yearly = "YEARLY"

        public var id: String { rawValue }

        public var label: String {
            switch self {
            case .weekly: return "Semanal"
            case .monthly: return "Mensal"
            case .yearly: return "Anual"
            }
        }
    }

    /// Ainda não existe uma tela de listagem de beneficiários salvos — por
    /// ora este campo aceita o counterparty_id colado manualmente (ex.: o
    /// devolvido ao cadastrar um beneficiário). Trocar por um seletor real
    /// é o próximo passo natural quando a listagem de counterparties for
    /// implementada.
    @Published public var counterpartyId: String = ""
    @Published public var amountText: String = ""
    @Published public var frequency: Frequency = .monthly
    @Published public var dayOfMonth: String = ""
    @Published public var startDate: Date = Date()
    @Published public var hasEndDate: Bool = false
    @Published public var endDate: Date = Date().addingTimeInterval(60 * 60 * 24 * 365)
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSaved: Bool = false

    public let account: Account
    private let useCase: StandingOrderUseCaseProtocol

    public init(account: Account, useCase: StandingOrderUseCaseProtocol) {
        self.account = account
        self.useCase = useCase
    }

    public func save() {
        errorMessage = nil

        guard !counterpartyId.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Informe o ID do beneficiário."
            return
        }

        let normalizedAmount = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Decimal(string: normalizedAmount), amount > 0 else {
            errorMessage = "Informe um valor válido."
            return
        }

        let day = dayOfMonth.isEmpty ? "1" : dayOfMonth

        isSubmitting = true

        Task {
            do {
                try await useCase.createStandingOrder(
                    for: account,
                    counterpartyId: counterpartyId,
                    amount: amount,
                    currency: account.currency ?? "EUR",
                    frequency: frequency.rawValue,
                    dayOfMonth: day,
                    startDate: startDate,
                    endDate: hasEndDate ? endDate : nil
                )
                isSubmitting = false
                isSaved = true
            } catch {
                isSubmitting = false
                errorMessage = "Não foi possível agendar o pagamento."
            }
        }
    }
}
