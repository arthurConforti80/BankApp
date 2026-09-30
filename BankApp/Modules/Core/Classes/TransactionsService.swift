//
//  TransactionsService.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

/// Fetches an account's most recent transactions. Lives in Core because
/// both FeatureAccounts (the account's own statement) and FeatureCards (the
/// statement of the account linked to the card) need this. Putting it in
/// either feature module would force the other to import it directly,
/// violating the boundary rule between feature modules.
public protocol TransactionsServiceProtocol {
    func fetchRecentTransactions(bankId: String, accountId: String, limit: Int) async throws -> [Transaction]
}

public final class TransactionsService: TransactionsServiceProtocol {
    private let apiClient: OBPAPIClient

    public init(apiClient: OBPAPIClient = .shared) {
        self.apiClient = apiClient
    }

    public func fetchRecentTransactions(bankId: String, accountId: String, limit: Int) async throws -> [Transaction] {
        let response: TransactionsResponseDTO = try await apiClient.get(
            path: "/my/banks/\(bankId)/accounts/\(accountId)/transactions"
        )
        // We truncate on the client instead of relying on an API query
        // parameter (e.g. ?limit=5). We haven't confirmed the exact name of
        // that parameter against the API Explorer, and truncating here
        // guarantees the "first 5 items" regardless of what the server
        // supports.
        return response.transactions.prefix(limit).map { dto in
            Transaction(
                id: dto.id,
                description: dto.details?.description ?? "Transaction",
                amount: Decimal(string: dto.details?.value?.amount ?? "") ?? 0,
                currency: dto.details?.value?.currency ?? "",
                completedDate: dto.details?.completed
            )
        }
    }
}

/// Approximate schema for GET /my/banks/{BANK_ID}/accounts/{ACCOUNT_ID}/transactions.
/// Just like what happened with AccountDTO, it's quite possible this will
/// need adjusting against the real response, which is why every field under
/// TransactionDetailsDTO is optional, with a fallback in the mapping above.
struct TransactionsResponseDTO: Decodable {
    let transactions: [TransactionDTO]
}

struct TransactionDTO: Decodable {
    let id: String
    let details: TransactionDetailsDTO?
}

struct TransactionDetailsDTO: Decodable {
    let description: String?
    let completed: String?
    let value: TransactionValueDTO?
}

struct TransactionValueDTO: Decodable {
    let currency: String?
    let amount: String?
}
