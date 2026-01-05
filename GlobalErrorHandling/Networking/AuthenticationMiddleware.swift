import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import HTTPTypes

struct AuthenticationMiddleware: ClientMiddleware {
    
    /// Список публичных операций, которые НЕ требуют авторизации
    private let publicOperations: Set<String> = [
        "authenticate",  // POST /api/auth/authenticate
        "register",      // POST /api/auth/register
        "getServices"    // GET /api/services (публичный просмотр прайса)
    ]
    
    func intercept(
        _ request: HTTPTypes.HTTPRequest,
        body: OpenAPIRuntime.HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPTypes.HTTPRequest, OpenAPIRuntime.HTTPBody?, URL) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?)
    ) async throws -> (HTTPTypes.HTTPResponse, OpenAPIRuntime.HTTPBody?) {
        
        var request = request
        
        // Проверяем: это публичная операция?
        if publicOperations.contains(operationID) {
            print("🌍 Middleware: Публичная операция [\(operationID)] - токен не нужен")
            return try await next(request, body, baseURL)
        }
        
        // Для защищённых операций проверяем токен
        if let token = UserDefaults.standard.string(forKey: "jwt_token"), !token.isEmpty {
            request.headerFields[.authorization] = "Bearer \(token)"
            print("🔐 Middleware: Токен добавлен [\(operationID)]")
        } else {
            print("⚠️ Middleware: Токен отсутствует для защищённой операции [\(operationID)]")
        }
        
        // Выполняем запрос
        let (response, responseBody) = try await next(request, body, baseURL)
        
        // 👇 Проверяем на 401 Unauthorized (истёк токен)
        if response.status == .unauthorized {
            print("🚫 Middleware: 401 Unauthorized - токен истёк, выполняем logout")
            await MainActor.run {
                AuthService.shared.logout()
                // Отправляем уведомление для обновления UI
                NotificationCenter.default.post(name: .unauthorizedError, object: nil)
            }
        }
        
        return (response, responseBody)
    }
}

// MARK: - Notification для 401 ошибки

extension Notification.Name {
    static let unauthorizedError = Notification.Name("unauthorizedError")
}