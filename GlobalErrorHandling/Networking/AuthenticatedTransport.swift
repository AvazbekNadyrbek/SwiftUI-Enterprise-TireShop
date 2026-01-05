//
//  AuthenticatedTransport.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

/// Кастомный Transport, который автоматически добавляет токен
final class AuthenticatedTransport: ClientTransport {
    
    private let underlyingTransport: URLSessionTransport
    
    init(configuration: URLSessionTransport.Configuration = .init()) {
        self.underlyingTransport = URLSessionTransport(configuration: configuration)
    }
    
    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        
        var mutableRequest = request
        
        // Добавляем токен, если есть
        if let token = UserDefaults.standard.string(forKey: "jwt_token") {
            mutableRequest.headerFields[.authorization] = "Bearer \(token)"
            print("🔐 Transport: Токен добавлен к запросу [\(operationID)]")
        }
        
        // Отправляем через обычный transport
        return try await underlyingTransport.send(
            mutableRequest,
            body: body,
            baseURL: baseURL,
            operationID: operationID
        )
    }
}