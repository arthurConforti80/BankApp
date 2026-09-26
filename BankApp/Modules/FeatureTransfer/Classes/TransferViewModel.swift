//
//  TransferViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class TransferViewModel: ObservableObject {
    @Published public var destinationIBAN: String = ""
    @Published public var beneficiaryName: String = ""
    @Published public var amountText: String = ""
    @Published public var note: String = ""
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String?
    @Published public var isCompleted: Bool = false

    public let fromAccount: Account
    private let transferUseCase: TransferUseCaseProtocol

    public init(fromAccount: Account, transferUseCase: TransferUseCaseProtocol) {
        self.fromAccount = fromAccount
        self.transferUseCase = transferUseCase
    }

    public func submit() {
        errorMessage = nil

        guard !destinationIBAN.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Informe o IBAN do beneficiário."
            return
        }

        let normalizedAmount = amountText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Decimal(string: normalizedAmount), amount > 0 else {
            errorMessage = "Informe um valor válido."
            return
        }

        isSubmitting = true

        Task {
            do {
                try await transferUseCase.transfer(
                    from: fromAccount,
                    destinationIBAN: destinationIBAN,
                    amount: amount,
                    currency: fromAccount.currency ?? "EUR",
                    description: note.isEmpty ? "Transferência BankApp" : note
                )
                isSubmitting = false
                isCompleted = true
            } catch {
                isSubmitting = false
                errorMessage = "Não foi possível concluir a transferência."
            }
        }
    }
}
