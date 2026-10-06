//
//  OBPAPIClient.swift
//  BankApp
//
//  Created by Arthur Borges Conforti on 20/09/2026.
//

import Foundation

/// Network/API errors exposed by the client. UseCases translate these into
/// a friendly message for the ViewModel. The client knows nothing about UI.
public enum OBPAPIError: Error {
    case invalidResponse
    case unauthorized
    case server(statusCode: Int, message: String?)
    case decoding(Error)
    case transport(Error)
}

/// Shared client for the Open Bank Project sandbox API
/// (https://apisandbox.openbankproject.com. See the API Explorer at
/// https://apiexplorersandbox.openbankproject.com to confirm exact payloads
/// per endpoint version before using this in production).
///
/// Implements the Direct Login flow documented by OBP:
/// 1. POST /my/logins/direct with header
///    `Authorization: DirectLogin username="...", password="...", consumer_key="..."`
///    returns a token.
/// 2. Subsequent calls use `Authorization: DirectLogin token="..."`.
///
/// This client is intentionally "dumb": it doesn't know about Account, it
/// doesn't know about any screen, it only knows how to authenticate and make
/// generic requests. Mapping to a domain Entity is each UseCase's
/// responsibility.
public final class OBPAPIClient {
    public static let shared = OBPAPIClient()

    private let baseURL = URL(string: "https://apisandbox.openbankproject.com")!
    private let apiVersion = "v4.0.0"
    private let session: URLSession
    private var directLoginToken: String?
    private var cachedUserId: String?
    private var cachedCustomerIds: [String: String] = [:]

    /// Consumer key of the application registered in the OBP sandbox. Should
    /// never be hardcoded here; inject it via a build environment variable or
    /// a config file ignored by git (see README).
    private let consumerKey: String

    public init(session: URLSession = .shared, consumerKey: String = ProcessInfo.processInfo.environment["OBP_CONSUMER_KEY"] ?? "") {
        self.session = session
        self.consumerKey = consumerKey
    }

    // MARK: - Authentication

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

    /// `user_id` of the authenticated user, required in the Standing
    /// Order and Direct Debit request body. Fetched once from
    /// `/users/current` (v3.0.0, following the official DAuth doc example)
    /// and cached for the rest of the session.
    public func currentUserId() async throws -> String {
        if let cachedUserId { return cachedUserId }
        struct CurrentUserResponse: Decodable { let user_id: String }
        let response: CurrentUserResponse = try await get(path: "/users/current", apiVersionOverride: "v3.0.0")
        cachedUserId = response.user_id
        return response.user_id
    }

    /// `customer_id` of the authenticated user AT A SPECIFIC BANK (the
    /// customer relationship is per bank), also required in Standing Order
    /// and Direct Debit. Cached by `bankId`.
    public func currentCustomerId(bankId: String) async throws -> String {
        if let cached = cachedCustomerIds[bankId] { return cached }
        struct CurrentCustomerResponse: Decodable { let customer_id: String }
        let response: CurrentCustomerResponse = try await get(path: "/banks/\(bankId)/customer", apiVersionOverride: "v1.4.0")
        cachedCustomerIds[bankId] = response.customer_id
        return response.customer_id
    }

    // MARK: - Generic requests

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

    /// Generic POST, used to create resources in the API (e.g. transfer
    /// transaction requests in FeatureTransfer). Follows exactly the same
    /// auth and error-handling pattern as `get`.
    public func post<T: Decodable, Body: Encodable>(path: String, body: Body, apiVersionOverride: String? = nil) async throws -> T {
        guard let token = directLoginToken else { throw OBPAPIError.unauthorized }
        let version = apiVersionOverride ?? apiVersion

        var request = URLRequest(url: baseURL.appendingPathComponent("/obp/\(version)\(path)"))
        request.httpMethod = "POST"
        request.setValue("DirectLogin token=\"\(token)\"", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw OBPAPIError.decoding(error)
        }

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
