//
//  Coordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Contrato base de todo Coordinator do app. Cada feature module expõe seu
/// próprio Coordinator concreto (LoginCoordinator, AccountsCoordinator) que
/// conforma este protocolo — o AppCoordinator, no target principal, orquestra
/// a transição entre eles.
public protocol Coordinator: AnyObject {
    func start()
}
