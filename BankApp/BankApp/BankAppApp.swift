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

/// Ponte entre o mundo SwiftUI (App/Scene) e o UINavigationController que o
/// AppCoordinator usa pra orquestrar as telas. Isso é infraestrutura de
/// bootstrap — não é um papel de arquitetura (View/ViewModel/Coordinator)
/// em si, só o ponto de entrada que os conecta.
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
