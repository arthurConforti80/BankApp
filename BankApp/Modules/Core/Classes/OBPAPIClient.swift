//
//  OBPAPIClient.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Erros de rede/API expostos pelo client. Os UseCases traduzem isso em
/// mensagem amigável para a ViewModel — o client não sabe nada de UI.
public enum OBPAPIError: Error {
    case invalidResponse
    case unauthorized
    case server(statusCode: Int, message: String?)
    case decoding(Error)
    case transport(Error)
}

/// Cliente compartilhado da API sandbox do Open Bank Project
/// (https://apisandbox.openbankproject.com — ver API Explorer em
/// https://apiexplorersandbox.openbankproject.com para confirmar payloads
/// exatos por versão de endpoint antes de usar em produção).
///
/// Implementa o fluxo Direct Login documentado pela OBP:
/// 1. POST /my/logins/direct com header
///    `Authorization: DirectLogin username="...", password="...", consumer_key="..."`
///    retorna um token.
/// 2. Chamadas seguintes usam `Authorization: DirectLogin token="..."`.
///
/// Este client é intencionalmente "burro": não conhece Account, não conhece
/// tela nenhuma — só sabe autenticar e fazer requests genéricos. Mapeamento
/// pra Entity de domínio é responsabilidade de cada UseCase.
public final class OBPAPIClient {
    public static let shared = OBPAPIClient()

    private let baseURL = URL(string: "https://apisandbox.openbankproject.com")!
    private let apiVersion = "v4.0.0"
    private let session: URLSession
    private var directLoginToken: String?

    /// Consumer key da aplicação registrada na sandbox OBP. Nunca deve ir
    /// hardcoded aqui — injete via variável de ambiente de build ou
    /// arquivo de configuração ignorado pelo git (ver README).
    private let consumerKey: String

    public init(session: URLSession = .shared, consumerKey: String = ProcessInfo.processInfo.environment["OBP_CONSUMER_KEY"] ?? "") {
        self.session = session
        self.consumerKey = consumerKey
    }

    // MARK: - Autenticação

    public func directLogin(username: String, password: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent("/my/logins/direct"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(
            "DirectLogin username=\"\(username)\", password=\"\(password)\", consumer_key=\"\(consumerKey)\"",
            forHTTPHeaderField: "Authorization"
        )

        let (data, response) = try await performRequest(request)
        guard let http = response as? HTTPURLResponse else { throw OBPAPIError.invalidResponse }
        guard http.statusCode == 200 || http.statusCode == 201 else {
            throw OBPAPIError.server(statusCode: http.statusCode, message: String(data: data, encoding: .utf8))
        }

        struct DirectLoginResponse: Decodable { let token: String }
        do {
            let decoded = try JSONDecoder().decode(DirectLoginResponse.self, from: data)
            self.directLoginToken = decoded.token
        } catch {
            throw OBPAPIError.decoding(error)
        }
    }

    public var isAuthenticated: Bool { directLoginToken != nil }

    // MARK: - Requests genéricos

    public func get<T: Decodable>(path: String, apiVersionOverride: String? = nil) async throws -> T {
        guard let token = directLoginToken else { throw OBPAPIError.unauthorized }
        let version = apiVersionOverride ?? apiVersion

        var request = URLRequest(url: baseURL.appendingPathComponent("/obp/\(version)\(path)"))
        request.httpMethod = "GET"
        request.setValue("DirectLogin token=\"\(token)\"", forHTTPHeaderField: "Authorization")

        let (data, response) = try await performRequest(request)
        guard let http = response as? HTTPURLResponse else { throw OBPAPIError.invalidResponse }
        guard 200..<300 ~= http.statusCode else {
            throw OBPAPIError.server(statusCode: http.statusCode, message: String(data: data, encoding: .utf8))
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw OBPAPIError.decoding(error)
        }
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            throw OBPAPIError.transport(error)
        }
    }
}
