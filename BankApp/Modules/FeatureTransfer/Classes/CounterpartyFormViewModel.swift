//
//  CounterpartyFormViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class CounterpartyFormViewModel: ObservableObject {
    @Published public var name: String = ""
    @Published public var nickname: String = ""
    @Published public var iban: String = ""
    @Published public var bankName: String = ""
    @Published public var isSubmitting: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSaved: Bool = false

    public let account: Account
    private let useCase: CounterpartyUseCaseProtocol

    public init(account: Account, useCase: CounterpartyUseCaseProtocol) {
        self.account = account
        self.useCase = useCase
    }

    public func save() {
        errorMessage = nil

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Informe o nome do beneficiário."
            return
        }
        guard !iban.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Informe o IBAN."
            return
        }

        isSubmitting = true

        Task {
            do {
                try await useCase.createCounterparty(
                    for: account,
                    name: name,
                    nickname: nickname.isEmpty ? nil : nickname,
                    iban: iban,
                    bankName: bankName.isEmpty ? nil : bankName
                )
                isSubmitting = false
                isSaved = true
            } catch {
                isSubmitting = false
                errorMessage = "Não foi possível salvar o beneficiário."
            }
        }
    }
}
