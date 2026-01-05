//
//  ContentView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 29.10.25.
//

import SwiftUI
import OpenAPIURLSession
import OpenAPIRuntime

struct ContentView: View {
    
    // 1. "Ловим" AuthViewModel из окружения, чтобы работала кнопка Выйти
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // 2. Создаем ViewModel для загрузки данных (услуг)
    @StateObject private var viewModel = ServicesViewModel()
    
    // 3. Получаем функцию showError из environment
    @Environment(\.showError) private var showError
    
    // 4. Флаг для отслеживания первой загрузки
    @State private var hasLoadedOnce = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Контент
                Group {
                    if viewModel.isLoading && !hasLoadedOnce {
                        // Показываем спиннер только при первой загрузке
                        VStack {
                            Spacer()
                            ProgressView("Загрузка прайса...")
                            Spacer()
                        }
                    } else if viewModel.services.isEmpty && !viewModel.isLoading {
                        // Пустой список
                        ContentUnavailableView(
                            "Нет услуг",
                            systemImage: "list.bullet.clipboard",
                            description: Text("Список услуг пуст или сервер недоступен")
                        )
                    } else {
                        // СПИСОК УСЛУГ
                        List(viewModel.services, id: \.id) { service in
                            ServiceRowView(service: service)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            await refreshServices()
                        }
                    }
                }
            }
            .navigationTitle("Прайс-лист")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            await refreshServices()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        authViewModel.logout()
                    }) {
                        HStack {
                            Text("Выйти")
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .task {
                guard !hasLoadedOnce else { return }
                
                // Устанавливаем обработчик ошибок ДО загрузки
                viewModel.setErrorHandler { apiError in
                    showError(apiError, apiError.recoverySuggestion ?? "Попробуйте снова")
                }
                
                await loadInitialData()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Загружает данные при первом отображении экрана
    private func loadInitialData() async {
        await viewModel.loadServices()
        hasLoadedOnce = true
    }
    
    /// Обновляет список услуг (для pull-to-refresh и кнопки обновления)
    private func refreshServices() async {
        await viewModel.refresh()
    }
}

// Для превью
#Preview {
    ContentView()
        .environmentObject(AuthViewModel()) // Обязательно для превью!
}
