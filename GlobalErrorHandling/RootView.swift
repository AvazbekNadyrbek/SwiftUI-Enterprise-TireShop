//
//  RootView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var router = AppRouter()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                // 🎯 Если вошли - показываем главный экран с навигацией
                MainTabView()
                    .environmentObject(router)
            } else {
                // 🔐 Если нет - показываем логин
                LoginView()
            }
        }
        .animation(.easeInOut, value: authViewModel.isAuthenticated)
    }
}

#Preview {
    RootView()
        .environmentObject(AuthViewModel())
}