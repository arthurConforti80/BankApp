# BankApp (demo)

App bancário fake, multi-módulo (CocoaPods, pods locais), MVVM-C — construído
como repositório-exemplo para o [swift-arch-audit-mcp](https://github.com/arthurconforti/swift-arch-audit-mcp).

Este repositório não busca ser bonito nem completo como produto: o único
objetivo dele é existir como código Swift real o suficiente pra provar que o
audit funciona contra algo diferente de fixtures sintéticas.

## Estrutura

```
BankApp.xcodeproj      # criar localmente (ver "Abrindo no Xcode" abaixo)
Podfile
BankApp/
  BankAppApp.swift      # entry point SwiftUI, hospeda o UINavigationController
  AppCoordinator.swift  # coordinator raiz: decide Login -> Home
  HomeView.swift         # combina Contas, Cartões, Transferência e Produtos
  HomeViewModel.swift    # só aqui, porque precisa conhecer as 3 features de dado ao mesmo tempo
  HomeCoordinator.swift  # navega Home -> Detalhe da conta / Detalhe do cartão / Transferência
Modules/
  Core/
    Core.podspec
    Classes/
      Coordinator.swift        # protocolo base de todo Coordinator
      Account.swift             # Entity de domínio
      CreditCard.swift           # Entity de domínio
      Transaction.swift           # Entity de domínio
      Product.swift                 # Entity de domínio
      OBPAPIClient.swift             # client compartilhado (DirectLogin + requests genéricos)
      TransactionsService.swift       # extrato compartilhado entre FeatureAccounts e FeatureCards
      Theme.swift                      # paleta e tipografia compartilhadas
      DetailHeader.swift                # cabeçalho compartilhado das telas de detalhe
      TransactionsSection.swift          # bloco "Últimas transações" compartilhado
  FeatureLogin/
    FeatureLogin.podspec
    Classes/
      LoginView.swift
      LoginViewModel.swift
      LoginCoordinator.swift
      LoginUseCase.swift
      LoginUseCaseProtocol.swift
  FeatureAccounts/
    FeatureAccounts.podspec
    Classes/
      AccountDetailView.swift
      AccountDetailViewModel.swift
      AccountsUseCase.swift
      AccountsResponseDTO.swift
  FeatureCards/
    FeatureCards.podspec
    Classes/
      CardDetailView.swift
      CardDetailViewModel.swift
      CardsUseCase.swift
      CardsResponseDTO.swift
  FeatureTransfer/
    FeatureTransfer.podspec
    Classes/
      TransferView.swift
      TransferViewModel.swift
      TransferUseCase.swift
      TransactionRequestDTO.swift
  FeatureProducts/
    FeatureProducts.podspec
    Classes/
      ProductsUseCase.swift
      ProductsResponseDTO.swift
```

Nenhum feature module importa outro diretamente — quando uma tela precisa de
mais de uma feature ao mesmo tempo (a Home, combinando Contas + Cartões +
Produtos, ou o Detalhe do cartão mostrando o extrato da conta vinculada), a
composição acontece no target do app (`HomeViewModel`/`HomeCoordinator`) ou
via um tipo compartilhado no `Core` (`TransactionsService`, `DetailHeader`,
`Theme`) — nunca via import cruzado entre `Feature*`.

## Backend: Open Bank Project sandbox

Usa a sandbox pública da OBP (https://apisandbox.openbankproject.com), sem
precisar rodar nada local. Autenticação via **Direct Login**:

1. `POST /my/logins/direct` com header
   `Authorization: DirectLogin username="...", password="...", consumer_key="..."`
2. Resposta traz um token; chamadas seguintes usam
   `Authorization: DirectLogin token="..."`.

Você precisa registrar uma aplicação na sandbox pra ter um `consumer_key`
próprio (gratuito, self-service). O client lê isso da variável de ambiente
`OBP_CONSUMER_KEY` — nunca hardcoded no código (é literalmente uma das regras
que o audit verifica).

Os endpoints e o schema JSON em `AccountsResponseDTO.swift` são uma
aproximação razoável do formato real da API — antes de rodar contra a
sandbox de verdade, confira o schema atual no API Explorer
(https://apiexplorersandbox.openbankproject.com) e ajuste se necessário.

## Abrindo no Xcode

Este repositório traz os pods locais (`Modules/*`) e o código-fonte do
target `BankApp`, mas **não** inclui um `.xcodeproj`/`.xcworkspace` gerado —
montar esses arquivos de projeto à mão fora do Xcode tem alto risco de gerar
um `.pbxproj` corrompido, e não agrega nada ao propósito deste repo (que é
ser lido pelo audit, não necessariamente compilado).

Pra abrir e rodar de verdade:

1. No Xcode: File → New → Project → iOS App, nome `BankApp`, interface
   SwiftUI, salve na raiz deste repositório (sobrescrevendo o `BankAppApp.swift`
   gerado automaticamente pelos arquivos deste repo).
2. `pod install`
3. Abra `BankApp.xcworkspace` (não o `.xcodeproj`).
4. Defina `OBP_CONSUMER_KEY` no scheme (Edit Scheme → Run → Arguments →
   Environment Variables).

## Duas branches, dois propósitos

- **`main`** — código limpo. Rodar o audit aqui retorna zero violações,
  prova que a arquitetura está de acordo com o catálogo de regras.
- **`demo/introduced-violations`** — os mesmos arquivos, com um punhado de
  violações reais plantadas de propósito (ver `VIOLATIONS.md` nessa branch).
  Serve como material de demonstração: "aqui está o PR, aqui está o que o
  swift-arch-audit pegou automaticamente".

## Licença

MIT
