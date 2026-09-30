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

    /// Same visual placeholder as the Home hero's mini chart, just to
    /// reinforce the identity between the two screens. Doesn't represent
    /// real data.
    private let heroBarHeights: [CGFloat] = [0.40, 0.65, 0.45, 0.80, 0.60]

    public init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                inkHeader

                formSheet
                    .padding(.top, -20)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private var inkHeader: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("BankApp")
                    .font(BankAppTheme.Typography.display(30, weight: .bold))
                    .foregroundStyle(BankAppTheme.Color.cream)
                Text("Sandbox Open Bank Project")
                    .font(BankAppTheme.Typography.body(13))
                    .foregroundStyle(BankAppTheme.Color.mutedOnInk)
            }

            HStack(alignment: .bottom, spacing: 5) {
                ForEach(Array(heroBarHeights.enumerated()), id: \.offset) { index, height in
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(index >= heroBarHeights.count - 2 ? BankAppTheme.Color.gold : BankAppTheme.Color.barMuted)
                        .frame(width: 22, height: 28 * height)
                }
            }
            .frame(height: 28, alignment: .bottom)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(minHeight: 320)
        .background(BankAppTheme.Color.ink)
    }

    private var formSheet: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sign in")
                    .font(BankAppTheme.Typography.display(22, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                Text("Access your account to continue")
                    .font(BankAppTheme.Typography.body(14))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }

            VStack(alignment: .leading, spacing: 18) {
                underlinedField(
                    label: "Username",
                    placeholder: "Robert.Us.01",
                    text: $viewModel.username,
                    field: .username,
                    isSecure: false
                )

                underlinedField(
                    label: "Password",
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
                        Text("Sign in")
                            .font(BankAppTheme.Typography.body(16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .foregroundStyle(BankAppTheme.Color.cream)
            .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .disabled(viewModel.isLoading)

            Spacer(minLength: 12)

            Text("Test environment, no real data is used")
                .font(BankAppTheme.Typography.body(12))
                .foregroundStyle(BankAppTheme.Color.mutedText)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 28)
        .padding(.top, 32)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
        .background(
            BankAppTheme.Color.cream,
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
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
