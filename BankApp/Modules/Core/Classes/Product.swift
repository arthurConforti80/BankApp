//
//  Product.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Entity de domínio pra um produto oferecido pelo banco (não é específico
/// da conta do usuário — é o catálogo do banco, tipo "conta poupança",
/// "cartão platinum" etc). Vive em Core porque a Home combina Accounts,
/// Cards e Products na mesma tela, igual já acontecia com Account e
/// CreditCard.
public struct Product: Identifiable, Equatable {
    public let id: String
    public let name: String
    public let description: String?

    public init(id: String, name: String, description: String?) {
        self.id = id
        self.name = name
        self.description = description
    }
}
