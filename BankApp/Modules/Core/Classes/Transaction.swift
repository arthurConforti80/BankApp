//
//  Transaction.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

public struct Transaction: Identifiable, Equatable {
    public let id: String
    public let description: String
    public let amount: Decimal
    public let currency: String
    public let completedDate: String?

    public init(id: String, description: String, amount: Decimal, currency: String, completedDate: String?) {
        self.id = id
        self.description = description
        self.amount = amount
        self.currency = currency
        self.completedDate = completedDate
    }
}
