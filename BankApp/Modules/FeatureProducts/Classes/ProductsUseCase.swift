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

    // Confirmado contra a sandbox real: "inv.01.us.inv" (o banco das
    // contas do usuário de teste) não tem nenhum produto cadastrado, mas
    // "inv.01.uk.uk" devolve um catálogo real (hipotecas, cartões,
    // poupança...). O catálogo de produtos é do banco, não da conta do
    // usuário, então é normal serem bancos diferentes dentro da mesma
    // sandbox multi-banco.
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
