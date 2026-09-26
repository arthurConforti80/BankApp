//
//  ProductsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Schema aproximado de GET /banks/{bank_id}/products — ainda não
/// confirmado contra uma resposta real da sandbox (o banco de teste pode
/// simplesmente não ter produtos cadastrados). Seguindo a mesma lição de
/// CardsResponseDTO: só o que usamos, tudo opcional exceto o identificador.
struct ProductsResponseDTO: Decodable {
    let products: [ProductDTO]
}

struct ProductDTO: Decodable {
    let productCode: String?
    let name: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case productCode = "product_code"
        case name
        case description
    }
}
