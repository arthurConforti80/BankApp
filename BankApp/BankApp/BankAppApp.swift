//
//  BankAppApp.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import SwiftUI
import UIKit

@main
struct BankAppApp: App {
    var body: some Scene {
        WindowGroup {
            RootNavigationView()
                .ignoresSafeArea()
        }
    }
}

/// Bridge between the SwiftUI world (App/Scene) and the UINavigationController
/// that AppCoordinator uses to orchestrate the screens. This is bootstrap
/// infrastructure, not an architecture role (View/ViewModel/Coordinator) in
/// itself, just the entry point that wires them together.
private struct RootNavigationView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        let appCoordinator = AppCoordinator(navigationController: navigationController)
        context.coordinator.appCoordinator = appCoordinator
        appCoordinator.start()
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}

    func makeCoordinator() -> BootstrapHolder {
        BootstrapHolder()
    }

    final class BootstrapHolder {
        var appCoordinator: AppCoordinator?
    }
}
