//
//  ProfileView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Профиль пользователя")
                    .font(.title)
                
                Spacer()
                
                Button(role: .destructive) {
                    authViewModel.logout()
                } label: {
                    Label("Выйти", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Профиль")
        }
    }
}