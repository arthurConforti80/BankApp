//
//  DetailHeader.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 26/09/2026.
//

import SwiftUI

/// Minimal header for the detail screens (account / card), mirroring the
/// mockup: circular back button + title, without the system's standard
/// navigation bar. Lives in Core because both FeatureAccounts and
/// FeatureCards need it, and no feature module can depend on another.
public struct DetailHeader: View {
    private let title: String
    private let onBack: () -> Void

    public init(title: String, onBack: @escaping () -> Void) {
        self.title = title
        self.onBack = onBack
    }

    public var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                    .frame(width: 32, height: 32)
                    .background(BankAppTheme.Color.cardFill, in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Text(title)
                .font(BankAppTheme.Typography.body(15, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }
}
