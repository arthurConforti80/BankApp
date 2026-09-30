//
//  CustomerViewModel.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 30/09/2026.
//

import Foundation
import Combine
import Core

@MainActor
public final class CustomerViewModel: ObservableObject {
    @Published public var customer: Customer?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    @Published public var webhookURL: String = ""
    @Published public var isRegisteringWebhook: Bool = false
    @Published public var webhookStatusMessage: String?
    @Published public var webhookRegistered: Bool = false

    public let bankId: String
    private let useCase: CustomerUseCaseProtocol

    public init(bankId: String, useCase: CustomerUseCaseProtocol) {
        self.bankId = bankId
        self.useCase = useCase
    }

    public func load() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                customer = try await useCase.fetchCustomer(bankId: bankId)
                isLoading = false
            } catch {
                isLoading = false
                errorMessage = "Couldn't load your registration data."
            }
        }
    }

    public func registerWebhook() {
        webhookStatusMessage = nil

        let trimmed = webhookURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed.lowercased().hasPrefix("http") else {
            webhookStatusMessage = "Enter a valid URL (e.g. from webhook.site)."
            return
        }

        isRegisteringWebhook = true

        Task {
            do {
                try await useCase.registerTransactionWebhook(bankId: bankId, url: trimmed)
                isRegisteringWebhook = false
                webhookRegistered = true
                webhookStatusMessage = "Webhook registered. New transactions at this bank will POST to that URL."
            } catch {
                isRegisteringWebhook = false
                webhookStatusMessage = "Couldn't register the webhook. Check the URL and try again."
            }
        }
    }
}
