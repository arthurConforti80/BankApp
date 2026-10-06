//
//  LoginUseCaseProtocol.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

public protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) async throws
}
