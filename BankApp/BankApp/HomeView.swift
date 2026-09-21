//
//  HomeView.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 21/09/2026.
//

import SwiftUI
import Core

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    let onSelectAccount: (Account) -> Void
    let onSelectCard: (CreditCard) -> Void

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Carregando...")
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else {
                List {
                    Section("Contas") {
                        if viewModel.accounts.isEmpty {
                            Text("Nenhuma conta encontrada.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.accounts) { account in
                                Button {
                                    onSelectAccount(account)
                                } label: {
                                    Text(account.label)
                                        .foregroundStyle(.primary)
                                }
                            }
                        }
                    }

                    Section("Cartões") {
                        if viewModel.cards.isEmpty {
                            Text("Nenhum cartão encontrado.")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(viewModel.cards) { card in
                                Button {
                                    onSelectCard(card)
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(card.nameOnCard)
                                            .foregroundStyle(.primary)
                                        Text(card.maskedNumber)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("BankApp")
        .onAppear {
            viewModel.load()
        }
    }
}
