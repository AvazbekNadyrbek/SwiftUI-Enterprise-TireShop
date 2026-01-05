//
//  ServicesListView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct ServicesListView: View {
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ServicesViewModel()
    @Environment(\.showError) private var showError
    @State private var hasLoadedOnce = false
    
    var body: some View {
        Group {
            if viewModel.isLoading && !hasLoadedOnce {
                ProgressView("Загрузка...")
            } else if viewModel.services.isEmpty {
                ContentUnavailableView(
                    "Нет услуг",
                    systemImage: "list.bullet.clipboard"
                )
            } else {
                List(viewModel.services, id: \.id) { service in
                    ServiceRowView(service: service)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let id = service.id {
                                // 🎯 Навигация на детальный экран
                                router.push(.serviceDetail(id: id))
                            }
                        }
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
        }
        .navigationTitle("Услуги")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    authViewModel.logout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .task {
            guard !hasLoadedOnce else { return }
            viewModel.setErrorHandler { error in
                showError(error, error.recoverySuggestion ?? "Попробуйте снова")
            }
            await viewModel.loadServices()
            hasLoadedOnce = true
        }
    }
}