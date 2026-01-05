//
//  MainTabView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 📋 Таб 1: Услуги
            NavigationCoordinator()
                .tabItem {
                    Label("Услуги", systemImage: "wrench.and.screwdriver")
                }
                .tag(0)
            
            // 📅 Таб 2: Мои Записи
            BookingListView()
                .tabItem {
                    Label("Записи", systemImage: "calendar")
                }
                .tag(1)
            
            // 🚗 Таб 3: Шины
            TireListView()
                .tabItem {
                    Label("Шины", systemImage: "car.fill")
                }
                .tag(2)
            
            // 👤 Таб 4: Профиль
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.circle")
                }
                .tag(3)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
        .environmentObject(AuthViewModel())
}