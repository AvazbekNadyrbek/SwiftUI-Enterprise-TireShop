//
//  LoginView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct LoginView: View {
    // Берем ViewModel из окружения (мы передадим её позже)
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var phone = "+7"
    @State private var password = ""
    @State private var isRegisterMode = false // Переключатель Вход/Регистрация
    @State private var name = "" // Только для регистрации
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                // Логотип или иконка
                Image(systemName: "car.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.bottom, 20)
                
                Text(isRegisterMode ? "Регистрация" : "Вход")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Поля ввода
                VStack(spacing: 15) {
                    if isRegisterMode {
                        TextField("Имя", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.words)
                    }
                    
                    TextField("Телефон", text: $phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                    
                    SecureField("Пароль", text: $password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)
                
                // Кнопка действия
                Button(action: {
                    Task {
                        if isRegisterMode {
                            await authViewModel.register(phone: phone, name: name, password: password)
                        } else {
                            await authViewModel.login(phone: phone, password: password)
                        }
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                            .frame(height: 50)
                        
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isRegisterMode ? "Зарегистрироваться" : "Войти")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.horizontal)
                .disabled(authViewModel.isLoading)
                
                // Переключатель режима
                Button {
                    withAnimation {
                        isRegisterMode.toggle()
                    }
                } label: {
                    Text(isRegisterMode ? "Уже есть аккаунт? Войти" : "Нет аккаунта? Регистрация")
                        .font(.footnote)
                }

                Spacer()
            }
            .padding()
            // Показываем ошибки, если они есть во ViewModel (если ты реализовал errorMessage)
            // .alert("Ошибка", isPresented: $authViewModel.showError) { ... }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel()) // Для превью
}
