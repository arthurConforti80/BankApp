# Violações para a branch `demo/introduced-violations`

Depois de criar essa branch a partir da `main` limpa, aplique as 5 mudanças
abaixo (cada uma quebra uma regra específica do catálogo). Depois de aplicar,
rode o audit — ele deve reportar exatamente essas 5 violações, nada mais.

---

## 1. View chamando rede diretamente (`view-no-network-call`)

**Arquivo:** `Modules/FeatureAccounts/Classes/AccountsListView.swift`

Adicione este `.task` no `body`, logo depois do `.onAppear`:

```swift
.task {
    // violação intencional: View chamando rede diretamente, ignorando a ViewModel
    let url = URL(string: "https://apisandbox.openbankproject.com/obp/v4.0.0/my/accounts")!
    _ = try? await URLSession.shared.data(from: url)
}
```

## 2. ViewModel importando UIKit (`viewmodel-no-uikit-import`)

**Arquivo:** `Modules/FeatureLogin/Classes/LoginViewModel.swift`

No topo do arquivo, adicione:

```swift
import UIKit
```

E dentro da classe, adicione (sem chamar de lugar nenhum — só a presença já
é a violação):

```swift
func presentLegacyAlert(on controller: UIViewController) {
    // violação intencional: ViewModel não deveria conhecer UIViewController
}
```

## 3. Secret hardcoded (`no-hardcoded-secret`)

**Arquivo:** `Modules/Core/Classes/OBPAPIClient.swift`

Dentro da classe `OBPAPIClient`, logo abaixo da declaração de `consumerKey`,
adicione uma nova propriedade:

```swift
private let debugConsumerKey: String = "sk_live_9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c"
```

> Nota técnica: o v1 do audit só detecta secret hardcoded em **propriedade
> de classe** (`let`/`var`), não em valor default de parâmetro de função
> (`init(consumerKey: String = "...")`). Isso é uma limitação conhecida do
> heurístico — vale documentar como próximo passo do catálogo de regras.

## 4. Log vazando dado sensível (`no-sensitive-data-in-log`)

**Arquivo:** `Modules/FeatureAccounts/Classes/AccountsUseCase.swift`

Dentro de `fetchAccounts()`, logo antes do `return`, adicione:

```swift
print("contas carregadas, saldo total: \(response.accounts.map { $0.balance.amount })")
```

## 5. Import cross-feature direto (`feature-module-no-cross-feature-import`)

**Arquivo:** `Modules/FeatureAccounts/Classes/AccountsCoordinator.swift`

No topo, adicione:

```swift
import FeatureLogin
```

E dentro da classe, adicione um método não utilizado (a violação é o import
em si, detectado a nível de módulo — não precisa nem ser chamado):

```swift
func logout() {
    // violação intencional: FeatureAccounts importando FeatureLogin direto,
    // sem passar por Core/Shared
}
```

---

Depois de aplicar as 5, rode:

```bash
# a partir da pasta do swift-arch-audit-mcp
python3 -m mcp_server.server  # ou, mais fácil, peça pro Claude Code auditar via a tool
```

ou simplesmente peça, dentro do Claude Code (com o servidor já conectado):

> "usando o swift-arch-audit, audite o repositório BankApp nessa branch e
> me mostre as violações"
