//
//  AppRouter.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import Foundation
import SwiftUI
import Combine

/// Центральный роутер приложения
@MainActor
final class AppRouter: ObservableObject {
    
    /// Стек навигации
    @Published var path = NavigationPath()
    
    /// Показывать ли модальное окно
    @Published var sheet: Route? = nil
    
    /// Показывать ли full screen cover
    @Published var fullScreenCover: Route?
    
    // MARK: - Navigation Methods
    
    /// Переход на новый экран (push)
    func push(_ route: Route) {
        path.append(route)
    }
    
    /// Назад на предыдущий экран (pop)
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Вернуться к корневому экрану (pop to root)
    func popToRoot() {
        path = NavigationPath()
    }
    
    /// Показать модальное окно (sheet)
    func presentSheet(_ route: Route) {
        sheet = route
    }
    
    /// Показать full screen cover
    func presentFullScreenCover(_ route: Route) {
        fullScreenCover = route
    }
    
    /// Закрыть модальное окно
    func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }
    
    
    
}
