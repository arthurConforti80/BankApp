//
//  FxRateDTO.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 29/09/2026.
//

import Foundation

/// Response for GET /banks/{bank}/fx/{from}/{to}, confirmed directly against
/// the sandbox's own resource docs (OBPv2.2.0-getCurrentFxRate).
struct FxRateResponseDTO: Decodable {
    let from_currency_code: String?
    let to_currency_code: String?
    let conversion_value: Double?
}
