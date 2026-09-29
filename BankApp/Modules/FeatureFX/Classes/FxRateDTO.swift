//
//  FxRateDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Resposta de GET /banks/{bank}/fx/{from}/{to} — confirmada direto no
/// resource-docs da própria sandbox (OBPv2.2.0-getCurrentFxRate).
struct FxRateResponseDTO: Decodable {
    let from_currency_code: String?
    let to_currency_code: String?
    let conversion_value: Double?
}
