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

/// Lista o catálogo de produtos do banco (não é específico da conta do
/// usuário). Uma sandbox sem produtos cadastrados devolve uma lista vazia —
/// a Home trata isso como estado vazio normal, nunca como erro.
public final class ProductsUseCase: ProductsUseCaseProtocol {
    private let apiClient: OBPAPIClient
    private let bankId: String

    public init(apiClient: OBPAPIClient = .shared, bankId: String = "inv.01.us.inv") {
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
