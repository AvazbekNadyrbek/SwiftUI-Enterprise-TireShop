//
//  ServiceDetailView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct ServiceDetailView: View {
    
    let serviceId: Int64
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Детали услуги #\(serviceId)")
                .font(.title)
            
            Text("Здесь будет подробное описание услуги")
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // 🎯 Навигация на создание записи
            Button {
//                router.push(.bookingCreate(serviceId: serviceId))
            } label: {
                Text("Записаться")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Услуга #\(serviceId)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
