//
//  LoginView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import SwiftUI
import Core

public struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case username, password
    }

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(alignment: .leading, spacing: 40) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("BankApp")
                            .font(BankAppTheme.Typography.display(26, weight: .bold))
                            .foregroundStyle(BankAppTheme.Color.ink)
                        Text("Sandbox Open Bank Project")
                            .font(BankAppTheme.Typography.body(13))
                            .foregroundStyle(BankAppTheme.Color.mutedText)
                    }

                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Entrar")
                                .font(BankAppTheme.Typography.display(22, weight: .semibold))
                                .foregroundStyle(BankAppTheme.Color.ink)
                            Text("Acesse sua conta para continuar")
                                .font(BankAppTheme.Typography.body(14))
                                .foregroundStyle(BankAppTheme.Color.mutedText)
                        }

                        VStack(alignment: .leading, spacing: 18) {
                            underlinedField(
                                label: "Usuário",
                                placeholder: "Robert.Us.01",
                                text: $viewModel.username,
                                field: .username,
                                isSecure: false
                            )

                            underlinedField(
                                label: "Senha",
                                placeholder: "••••••••••",
                                text: $viewModel.password,
                                field: .password,
                                isSecure: true
                            )
                        }

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(BankAppTheme.Typography.body(13))
                                .foregroundStyle(BankAppTheme.Color.negative)
                        }

                        Button {
                            focusedField = nil
                            viewModel.login()
                        } label: {
                            ZStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(BankAppTheme.Color.cream)
                                } else {
                                    Text("Entrar")
                                        .font(BankAppTheme.Typography.body(16, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                        }
                        .foregroundStyle(BankAppTheme.Color.cream)
                        .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                        .disabled(viewModel.isLoading)
                    }
                }
                .padding(.horizontal, 28)

                Spacer()

                Text("Ambiente de testes — nenhum dado real é utilizado")
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
                    .padding(.bottom, 24)
            }
        }
    }

    @ViewBuilder
    private func underlinedField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        field: Field,
        isSecure: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label.uppercased())
                .font(BankAppTheme.Typography.body(12, weight: .semibold))
                .tracking(0.5)
                .foregroundStyle(BankAppTheme.Color.mutedText)

            Group {
                if isSecure {
                    SecureField(placeholder, text: text)
                } else {
                    TextField(placeholder, text: text)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
            }
            .font(BankAppTheme.Typography.body(16))
            .foregroundStyle(BankAppTheme.Color.ink)
            .focused($focusedField, equals: field)
            .padding(.vertical, 10)

            Rectangle()
                .fill(BankAppTheme.Color.hairline)
                .frame(height: 1.5)
        }
    }
}
