//
//  CustomerUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 30/09/2026.
//

import Foundation
import Core

public protocol CustomerUseCaseProtocol {
    func fetchCustomer(bankId: String) async throws -> Customer
    func registerTransactionWebhook(bankId: String, url: String) async throws
}

/// Reads the authenticated user's registration data at a bank, and
/// registers the real OBP server-side webhook that fires whenever a new
/// transaction is created on any account at that bank.
public final class CustomerUseCase: CustomerUseCaseProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func fetchCustomer(bankId: String) async throws -> Customer {
        let dto: CustomerResponseDTO = try await apiClient.get(
            path: "/banks/\(bankId)/customer",
            apiVersionOverride: "v1.4.0"
        )

        let dateOfBirth: Date? = dto.date_of_birth.flatMap { string in
            ISO8601DateFormatter().date(from: string)
        }

        return Customer(
            customerId: dto.customer_id,
            customerNumber: dto.customer_number,
            legalName: dto.legal_name,
            email: dto.email,
            mobilePhoneNumber: dto.mobile_phone_number,
            dateOfBirth: dateOfBirth,
            kycStatus: dto.kyc_status,
            employmentStatus: dto.employment_status,
            relationshipStatus: dto.relationship_status
        )
    }

    public func registerTransactionWebhook(bankId: String, url: String) async throws {
        let body = CreateWebhookRequestDTO(
            url: url,
            http_method: "POST",
            http_protocol: "HTTP/1.1"
        )
        let _: CreateWebhookResponseDTO = try await apiClient.post(
            path: "/banks/\(bankId)/web-hooks/account/notifications/on-create-transaction",
            body: body
        )
    }
}
