//
//  CustomerView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 30/09/2026.
//

import SwiftUI
import Core

public struct CustomerView: View {
    @ObservedObject private var viewModel: CustomerViewModel
    private let onBack: () -> Void

    public init(viewModel: CustomerViewModel, onBack: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onBack = onBack
    }

    public var body: some View {
        ZStack {
            BankAppTheme.Color.cream.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                DetailHeader(title: "Profile", onBack: onBack)

                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(BankAppTheme.Typography.body(14))
                        .foregroundStyle(BankAppTheme.Color.negative)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            registrationCard
                            webhookCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear { viewModel.load() }
    }

    // MARK: - Registration data

    private var registrationCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Registration data")
                .font(BankAppTheme.Typography.display(18, weight: .semibold))
                .foregroundStyle(BankAppTheme.Color.ink)

            VStack(spacing: 0) {
                infoRow(label: "Full name", value: viewModel.customer?.legalName)
                divider
                infoRow(label: "Customer number", value: viewModel.customer?.customerNumber)
                divider
                infoRow(label: "Email", value: viewModel.customer?.email)
                divider
                infoRow(label: "Mobile phone", value: viewModel.customer?.mobilePhoneNumber)
                divider
                infoRow(label: "Date of birth", value: formattedDate(viewModel.customer?.dateOfBirth))
                divider
                infoRow(label: "KYC status", value: formattedKYC(viewModel.customer?.kycStatus))
                divider
                infoRow(label: "Employment status", value: viewModel.customer?.employmentStatus)
                divider
                infoRow(label: "Relationship status", value: viewModel.customer?.relationshipStatus, isLast: true)
            }
            .padding(.horizontal, 16)
            .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(BankAppTheme.Color.hairline, lineWidth: 1))
        }
    }

    private var divider: some View {
        Rectangle().fill(BankAppTheme.Color.hairline).frame(height: 1)
    }

    @ViewBuilder
    private func infoRow(label: String, value: String?, isLast: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(BankAppTheme.Typography.body(13))
                .foregroundStyle(BankAppTheme.Color.mutedText)

            Spacer()

            Text(value?.isEmpty == false ? value! : "Not set")
                .font(BankAppTheme.Typography.body(14, weight: .medium))
                .foregroundStyle(value?.isEmpty == false ? BankAppTheme.Color.ink : BankAppTheme.Color.mutedText)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 14)
    }

    private func formattedDate(_ date: Date?) -> String? {
        guard let date else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    private func formattedKYC(_ status: Bool?) -> String? {
        guard let status else { return nil }
        return status ? "Verified" : "Not verified"
    }

    // MARK: - Webhook

    private var webhookCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Push notifications")
                    .font(BankAppTheme.Typography.display(18, weight: .semibold))
                    .foregroundStyle(BankAppTheme.Color.ink)
                Text("Register a webhook so the sandbox notifies a URL of yours whenever a new transaction is created on any of your accounts at this bank.")
                    .font(BankAppTheme.Typography.body(13))
                    .foregroundStyle(BankAppTheme.Color.mutedText)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Webhook URL")
                    .font(BankAppTheme.Typography.body(12))
                    .foregroundStyle(BankAppTheme.Color.mutedText)

                TextField("e.g. https://webhook.site/your-id", text: $viewModel.webhookURL)
                    .font(BankAppTheme.Typography.body(15))
                    .foregroundStyle(BankAppTheme.Color.ink)
                    .padding(.vertical, 8)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)

                Rectangle().fill(BankAppTheme.Color.hairline).frame(height: 1.5)
            }

            if let statusMessage = viewModel.webhookStatusMessage {
                Text(statusMessage)
                    .font(BankAppTheme.Typography.body(13))
                    .foregroundStyle(viewModel.webhookRegistered ? BankAppTheme.Color.positive : BankAppTheme.Color.negative)
            }

            Button {
                viewModel.registerWebhook()
            } label: {
                ZStack {
                    if viewModel.isRegisteringWebhook {
                        ProgressView().tint(BankAppTheme.Color.cream)
                    } else {
                        Text("Register webhook")
                            .font(BankAppTheme.Typography.body(16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
            }
            .foregroundStyle(BankAppTheme.Color.cream)
            .background(BankAppTheme.Color.ink, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .disabled(viewModel.isRegisteringWebhook)
        }
        .padding(16)
        .background(BankAppTheme.Color.cardFill, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(BankAppTheme.Color.hairline, lineWidth: 1))
    }
}
