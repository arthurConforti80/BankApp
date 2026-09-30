//
//  Coordinator.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Base contract for every Coordinator in the app. Each feature module
/// exposes its own concrete Coordinator (LoginCoordinator, AccountsCoordinator)
/// that conforms to this protocol. AppCoordinator, in the main target,
/// orchestrates the transition between them.
@MainActor
public protocol Coordinator: AnyObject {
    func start()
}
