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
    public enum Step {
        case form
        case challenge
        case success
    }

    @Published public var destinationIBAN: String = ""
    @Published public var beneficiaryName: String = ""
    @Published public var amountText: String = ""
    @Published public var note: String = ""
    @Published public var code: String = ""
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String?
    @Published public var step: Step = .form

    public let fromAccount: Account
    private let transferUseCase: TransferUseCaseProtocol

    private var pendingTransactionRequestId: String?
    private var pendingChallengeId: String?

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
                let outcome = try await transferUseCase.transfer(
                    from: fromAccount,
                    destinationIBAN: destinationIBAN,
                    amount: amount,
                    currency: fromAccount.currency ?? "EUR",
                    description: note.isEmpty ? "Transferência BankApp" : note
                )
                isSubmitting = false

                switch outcome {
                case .completed:
                    step = .success
                case .challengeRequired(let transactionRequestId, let challengeId):
                    pendingTransactionRequestId = transactionRequestId
                    pendingChallengeId = challengeId
                    step = .challenge
                }
            } catch {
                isSubmitting = false
                errorMessage = "Não foi possível concluir a transferência."
            }
        }
    }

    public func answerChallenge() {
        errorMessage = nil

        guard !code.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Informe o código de verificação."
            return
        }
        guard let transactionRequestId = pendingTransactionRequestId, let challengeId = pendingChallengeId else {
            errorMessage = "Sessão de confirmação expirada, tente novamente."
            step = .form
            return
        }

        isSubmitting = true

        Task {
            do {
                try await transferUseCase.answerChallenge(
                    from: fromAccount,
                    transactionRequestId: transactionRequestId,
                    challengeId: challengeId,
                    code: code
                )
                isSubmitting = false
                step = .success
            } catch {
                isSubmitting = false
                errorMessage = "Código inválido ou expirado."
            }
        }
    }
}
