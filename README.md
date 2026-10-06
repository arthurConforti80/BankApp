# BankApp

A sample iOS banking app built as the target repository for an architecture audit tool. It exists so the audit has a realistic codebase to run against, with one branch that follows the rules and another where violations were planted on purpose.

The audit itself lives in a separate repository: [MCPServices](https://github.com/arthurConforti80/MCPServices) <!-- adjust the link if the repo name is different -->

## Why this repo exists

Most architecture linters are tested against toy snippets. BankApp gives the audit something closer to a real banking codebase: several feature modules, coordinators handling navigation, view models talking to a domain layer, and a networking layer backed by a real hosted API.

Because the goal is to exercise the rules, the UI is intentionally plain. What matters here is how the code is organized, not how the screens look.

## Architecture

BankApp follows **MVVM-C** split across multiple modules.

| Layer | Responsibility | May depend on |
|---|---|---|
| View | SwiftUI views, rendering and user input only | ViewModel |
| ViewModel | Presentation state, calls use cases | Domain |
| Coordinator | Navigation and flow between screens | View, ViewModel |
| Domain | Entities, use cases, repository protocols | Nothing |
| Data | Repository implementations, API client, DTO mapping | Domain |

A few rules the audit enforces against this layout:

- Views never call the API or a repository directly
- ViewModels don't import UIKit and don't trigger navigation themselves
- The Domain module has no dependency on Data or on any UI framework
- Feature modules don't import each other; shared code goes through a core module

The full rule catalog is defined in the audit repository.

## Branches

| Branch | Purpose |
|---|---|
| `master` | Clean reference. The audit should report zero violations here. |
| `violations` <!-- rename to the real branch name --> | Same app with violations planted deliberately, each one mapped to a rule in the catalog. |

Running the audit on both branches and comparing the reports is the quickest way to see what it catches.

## Backend

There is no local mock. The app talks to the [Open Bank Project sandbox](https://apisandbox.openbankproject.com), a hosted API with banks, accounts and transactions you can use for testing. Endpoints can be browsed in the [API Explorer](https://apiexplorersandbox.openbankproject.com).

To run the app against it you need a free sandbox account and a consumer key.

## Getting started

Requirements:

- Xcode 26 or later
- iOS 15+ deployment target
- CocoaPods

```bash
git clone https://github.com/arthurConforti80/BankApp.git
cd BankApp
pod install
open BankApp.xcworkspace
```

Then add your Open Bank Project credentials. <!-- describe where: e.g. copy Config.example.xcconfig to Config.xcconfig and fill in OBP_CONSUMER_KEY, OBP_USERNAME, OBP_PASSWORD -->

Keep credentials out of the repository; the config file with real values is git-ignored.

## Running the audit

With the MCP server from the audit repository registered in Claude Code (or any MCP client), point it at this project:

```
Audit the architecture of ~/path/to/BankApp
```

On `master` the report should come back clean. Check out the violations branch and run it again to see the findings and the suggested fixes.

## Project structure

<!-- replace with the real tree once the modules are in place -->
```
BankApp/
├── App/                 # Entry point, app coordinator, dependency wiring
├── Modules/
│   ├── Core/            # Shared utilities and UI components
│   ├── Domain/          # Entities, use cases, repository protocols
│   ├── Data/            # OBP API client, DTOs, repository implementations
│   ├── Accounts/        # Feature: account list and details
│   └── Transactions/    # Feature: transaction history
└── Podfile
```

## License

MIT

