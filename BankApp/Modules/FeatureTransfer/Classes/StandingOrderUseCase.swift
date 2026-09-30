//
//  StandingOrderUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Core

public protocol StandingOrderUseCaseProtocol {
    func createStandingOrder(
        for account: Account,
        counterpartyId: String,
        amount: Decimal,
        currency: String,
        frequency: String,
        dayOfMonth: String,
        startDate: Date,
        endDate: Date?
    ) async throws
}

/// Cria um pagamento recorrente (standing order) pra um counterparty já
/// cadastrado. Ver comentário em CreateStandingOrderRequestDTO.
public final class StandingOrderUseCase: StandingOrderUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let dateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    /// Sem data final, a OBP ainda exige o campo `date_expires` presente
    /// no JSON — usamos uma data bem distante em vez de omitir a chave.
    private static let farFutureExpiry = "2099-12-31T00:00:00Z"

    public func createStandingOrder(
        for account: Account,
        counterpartyId: String,
        amount: Decimal,
        currency: String,
        frequency: String,
        dayOfMonth: String,
        startDate: Date,
        endDate: Date?
    ) async throws {
        let userId = try await apiClient.currentUserId()
        let customerId = try await apiClient.currentCustomerId(bankId: account.bankId)

        let body = CreateStandingOrderRequestDTO(
            customer_id: customerId,
            user_id: userId,
            counterparty_id: counterpartyId,
            amount: CreateStandingOrderRequestDTO.Amount(currency: currency, amount: Self.formattedAmount(amount)),
            when: CreateStandingOrderRequestDTO.When(frequency: frequency, detail: dayOfMonth),
            date_signed: dateFormatter.string(from: Date()),
            date_starts: dateFormatter.string(from: startDate),
            date_expires: endDate.map { dateFormatter.string(from: $0) } ?? Self.farFutureExpiry
        )
        let _: StandingOrderResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/standing-order",
            body: body
        )
    }

    private static func formattedAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
    }
}
