//
//  APIError.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import Foundation

/// Ошибки API запросов
enum APIError: LocalizedError {
    case networkError(underlying: Error)
    case serverError(statusCode: Int)
    case decodingError
    case cancelled
    case unknown(String)
    
    // MARK: - Короткие сообщения для пользователя
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return parseNetworkError(error)
        case .serverError(let code):
            return parseServerError(code)
        case .decodingError:
            return "Ошибка обработки данных"
        case .cancelled:
            return "Запрос отменён"
        case .unknown(let message):
            return message
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkError(let error):
            return getNetworkErrorGuidance(error)
        case .serverError(let code):
            return getServerErrorGuidance(code)
        case .decodingError:
            return "Обновите приложение"
        case .cancelled:
            return "Попробуйте снова"
        case .unknown:
            return "Перезапустите приложение"
        }
    }
    
    // MARK: - Private Helpers
    
    /// Парсим ошибку сети в понятный текст
    private func parseNetworkError(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Проверяем URLError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet:
                return "Нет интернета"
            case NSURLErrorCannotConnectToHost:
                return "Сервер недоступен"
            case NSURLErrorTimedOut:
                return "Время ожидания истекло"
            case NSURLErrorNetworkConnectionLost:
                return "Соединение потеряно"
            case NSURLErrorCannotFindHost:
                return "Сервер не найден"
            case NSURLErrorDNSLookupFailed:
                return "Ошибка DNS"
            default:
                return "Ошибка сети"
            }
        }
        
        return "Ошибка подключения"
    }
    
    /// Получаем подсказку для сетевых ошибок
    private func getNetworkErrorGuidance(_ error: Error) -> String {
        let nsError = error as NSError
        
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet:
                return "Проверьте Wi-Fi или мобильные данные"
            case NSURLErrorCannotConnectToHost, NSURLErrorCannotFindHost:
                return "Убедитесь, что сервер запущен"
            case NSURLErrorTimedOut:
                return "Попробуйте снова через несколько секунд"
            default:
                return "Проверьте подключение и попробуйте снова"
            }
        }
        
        return "Попробуйте позже"
    }
    
    /// Парсим ошибку сервера
    private func parseServerError(_ code: Int) -> String {
        switch code {
        case 400:
            return "Неверный запрос"
        case 401:
            return "Требуется авторизация"
        case 403:
            return "Доступ запрещён"
        case 404:
            return "Данные не найдены"
        case 500:
            return "Ошибка сервера"
        case 502:
            return "Сервер недоступен"
        case 503:
            return "Сервис временно недоступен"
        default:
            return "Ошибка \(code)"
        }
    }
    
    /// Получаем подсказку для ошибок сервера
    private func getServerErrorGuidance(_ code: Int) -> String {
        switch code {
        case 400:
            return "Проверьте введённые данные"
        case 401:
            return "Войдите в систему"
        case 403:
            return "У вас нет доступа к этому ресурсу"
        case 404:
            return "Попробуйте обновить страницу"
        case 500...599:
            return "Попробуйте позже или обратитесь в поддержку"
        default:
            return "Попробуйте снова"
        }
    }
}