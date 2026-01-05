//
//  AuthService.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import Foundation

/// Сервис для управления JWT токенами
final class AuthService {
    
    // MARK: - Singleton
    
    static let shared = AuthService()
    private init() {}
    
    // MARK: - Constants
    
    private let tokenKey = "jwt_token"
    
    // MARK: - Public Properties
    
    /// Проверяет, авторизован ли пользователь
    var isAuthenticated: Bool {
        token != nil
    }
    
    /// Текущий токен (если есть)
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
                print("🔐 AuthService: Токен сохранён")
            } else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
                print("🔓 AuthService: Токен удалён")
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// Сохраняет токен после успешной авторизации
    func saveToken(_ token: String) {
        self.token = token
    }
    
    /// Удаляет токен (выход из системы)
    func logout() {
        self.token = nil
    }
}