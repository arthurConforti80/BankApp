//
//  TransactionsService.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import Foundation

/// Busca as últimas transações de uma conta. Vive no Core porque tanto
/// FeatureAccounts (extrato da própria conta) quanto FeatureCards (extrato
/// da conta vinculada ao cartão) precisam disso — colocar em qualquer um
/// dos dois feature modules forçaria o outro a importá-lo diretamente,
/// violando a regra de fronteira entre módulos de feature.
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
        // Truncamos no cliente em vez de confiar num parâmetro de query da
        // API (ex: ?limit=5) — não confirmamos o nome exato desse parâmetro
        // contra o API Explorer, e truncar aqui garante o "5 primeiros
        // itens" independente do que o servidor suportar.
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

/// Schema aproximado de GET /my/banks/{BANK_ID}/accounts/{ACCOUNT_ID}/transactions.
/// Assim como aconteceu com AccountDTO, é bem possível que isto precise de
/// ajuste contra a resposta real — por isso todos os campos abaixo de
/// TransactionDetailsDTO são opcionais, com fallback no mapeamento acima.
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
