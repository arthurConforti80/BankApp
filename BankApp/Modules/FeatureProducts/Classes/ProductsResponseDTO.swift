//
//  ProductsResponseDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import Foundation

/// Schema for GET /banks/{bank_id}/products, confirmed against a real
/// sandbox response (bank "inv.01.uk.uk", see ProductsUseCase). The API
/// returns many more fields (parent_product_code, more_info_url,
/// terms_and_conditions_url, meta.license...); we only declare here what we
/// actually use, and `description` is optional because the sandbox
/// sometimes returns an empty string instead of omitting the field.
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
