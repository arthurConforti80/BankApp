//
//  TransferUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation
import Core

public protocol TransferUseCaseProtocol {
    func transfer(
        from account: Account,
        destinationIBAN: String,
        amount: Decimal,
        currency: String,
        description: String
    ) async throws
}

/// Cria um transaction request do tipo SEPA na conta de origem, usando o
/// IBAN de destino informado. Ver o comentário em TransactionRequestDTO
/// sobre o que ainda precisa ser confirmado contra a sandbox real (schema
/// exato do body e o possível fluxo de challenge/OTP).
public final class TransferUseCase: TransferUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func transfer(
        from account: Account,
        destinationIBAN: String,
        amount: Decimal,
        currency: String,
        description: String
    ) async throws {
        let body = TransactionRequestDTO(
            to: TransactionRequestDTO.Counterparty(iban: destinationIBAN),
            value: TransactionRequestDTO.Value(currency: currency, amount: Self.formattedAmount(amount)),
            description: description
        )

        // Qualquer resposta 2xx é tratada como sucesso por ora — não
        // inspecionamos `status` (ex.: "PENDING" aguardando challenge)
        // porque esse fluxo ainda não foi validado contra a sandbox real.
        let _: TransactionRequestResponseDTO = try await apiClient.post(
            path: "/banks/\(account.bankId)/accounts/\(account.id)/owner/transaction-request-types/SEPA/transaction-requests",
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
