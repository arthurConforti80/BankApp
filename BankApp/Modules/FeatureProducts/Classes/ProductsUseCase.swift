//
//  ProductsUseCase.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation
import Core

public protocol ProductsUseCaseProtocol {
    func fetchProducts() async throws -> [Product]
}

/// Lists the bank's product catalog (not specific to the user's account).
/// A sandbox with no registered products returns an empty list. Home
/// treats this as a normal empty state, never as an error.
public final class ProductsUseCase: ProductsUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let bankId: String

    // Confirmed against the real sandbox: "inv.01.us.inv" (the bank behind
    // the test user's accounts) has no registered products, but
    // "inv.01.uk.uk" returns a real catalog (mortgages, cards,
    // savings...). The product catalog belongs to the bank, not to the
    // user's account, so it's normal for these to be different banks
    // within the same multi-bank sandbox.
    public init(apiClient: OBPAPIClient = .shared, bankId: String = "inv.01.uk.uk") {
        self.apiClient = apiClient
        self.bankId = bankId
    }

    public func fetchProducts() async throws -> [Product] {
        let response: ProductsResponseDTO = try await apiClient.get(path: "/banks/\(bankId)/products")
        return response.products.compactMap { dto in
            guard let code = dto.productCode else { return nil }
            return Product(id: code, name: dto.name ?? code, description: dto.description)
        }
    }
}
