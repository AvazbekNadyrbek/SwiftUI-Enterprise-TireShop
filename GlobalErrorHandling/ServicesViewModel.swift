//
//  ServicesViewModel.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import Foundation
import Combine
import OpenAPIURLSession
import OpenAPIRuntime

/// ViewModel для управления списком услуг
/// Загружает данные с сервера и обрабатывает состояния загрузки/ошибок
@MainActor
final class ServicesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Список услуг, полученный с сервера
    @Published var services: [Components.Schemas.ServiceResponse] = []
    
    /// Индикатор загрузки (для показа ProgressView)
    @Published var isLoading = false
    
    // MARK: - Private Properties
    
    /// HTTP клиент с Middleware для авторизации
    private let client: Client
    
    /// Callback для отображения глобальных ошибок
    private var onError: ((APIError) -> Void)?
    
    // MARK: - Initialization
    
    init(client: Client? = nil) {
        if let client = client {
            self.client = client
        } else {
            // 👇 Используем фабрику с Middleware
            self.client = ClientFactory.createClient()
        }
    }
    
    // MARK: - Public Methods
    
    /// Устанавливает обработчик ошибок
    func setErrorHandler(_ handler: @escaping (APIError) -> Void) {
        self.onError = handler
    }
    
    /// Загружает список услуг с сервера
    func loadServices() async {
        isLoading = true
        
        do {
            let response = try await client.getServices()
            
            switch response {
            case .ok(let okResponse):
                // Body это enum с case .json
                switch okResponse.body {
                case .json(let servicesList):
                    services = servicesList
                    print("✅ Загружено услуг: \(servicesList.count)")
                }
                
            case .undocumented(statusCode: let code, _):
                let error = APIError.serverError(statusCode: code)
                onError?(error)
                print("❌ Ошибка сервера: \(code)")
            }
            
        } catch is CancellationError {
            // Игнорируем отмену (это нормально)
            print("⚠️ Запрос был отменён")
        } catch {
            let apiError = APIError.networkError(underlying: error)
            onError?(apiError)
            print("❌ Ошибка сети: \(error)")
        }
        
        isLoading = false
    }
    
    /// Перезагружает список услуг
    func refresh() async {
        await loadServices()
    }
}
