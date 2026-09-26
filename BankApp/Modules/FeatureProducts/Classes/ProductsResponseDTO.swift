//
//  ProductsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Schema de GET /banks/{bank_id}/products, confirmado contra uma resposta
/// real da sandbox (banco "inv.01.uk.uk" — ver ProductsUseCase). A API
/// devolve bem mais campos (parent_product_code, more_info_url,
/// terms_and_conditions_url, meta.license...) — só declaramos aqui o que
/// realmente usamos, e `description` opcional porque a sandbox às vezes
/// devolve string vazia em vez de omitir o campo.
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
