//
//  LoginView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import SwiftUI

public struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 16) {
            Text("BankApp")
                .font(.largeTitle.bold())

            TextField("Usuário", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()

            SecureField("Senha", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .font(.footnote)
            }

            Button {
                viewModel.login()
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Entrar")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
