//
//  Product.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Domain entity for a product offered by the bank (not specific to the
/// user's account, it's the bank's catalog, things like "savings account",
/// "platinum card" etc). Lives in Core because Home combines Accounts,
/// Cards and Products on the same screen, just like it already did with
/// Account and CreditCard.
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
