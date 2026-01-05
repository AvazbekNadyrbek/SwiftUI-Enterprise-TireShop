//
//  ServiceSelectionView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct ServiceSelectionView: View {
    
    @StateObject private var viewModel = ServicesViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedService: Components.Schemas.ServiceResponse?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Загрузка услуг...")
                } else if viewModel.services.isEmpty {
                    emptyStateView
                } else {
                    servicesList
                }
            }
            .navigationTitle("Выберите услугу")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.loadServices()
            }
            .sheet(item: $selectedService) { service in
                NavigationStack {
                    BookingViewContainer(
                        serviceId: service.id ?? 0,
                        serviceName: service.name ?? "Услуга",
                        onSuccess: {
                            selectedService = nil
                            dismiss()
                        }
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Назад") {
                                selectedService = nil
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Services List
    
    private var servicesList: some View {
        List(viewModel.services, id: \.id) { service in
            BookingServiceRow(service: service)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedService = service
                }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет доступных услуг")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Booking Service Row Component

struct BookingServiceRow: View {
    let service: Components.Schemas.ServiceResponse
    
    var body: some View {
        HStack(spacing: 16) {
            // Иконка услуги
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: serviceIcon)
                    .font(.title3)
                    .foregroundColor(.blue)
            }
            
            // Информация об услуге
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name ?? "Неизвестная услуга")
                    .font(.headline)
                
                if let description = service.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    // Цена
                    if let price = service.price {
                        Label("\(Int(price)) ₽", systemImage: "rublesign.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    // Длительность
                    if let duration = service.durationMinutes {
                        Label("\(duration) мин", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Spacer()
            
            // Стрелка
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private var serviceIcon: String {
        guard let name = service.name?.lowercased() else {
            return "wrench.and.screwdriver"
        }
        
        if name.contains("масло") {
            return "drop.fill"
        } else if name.contains("балансировка") || name.contains("колес") {
            return "figure.roll"
        } else if name.contains("тормоз") {
            return "brake.signal"
        } else if name.contains("диск") {
            return "circle.hexagongrid"
        } else if name.contains("переобувка") || name.contains("шин") {
            return "car.fill"
        } else {
            return "wrench.and.screwdriver"
        }
    }
}

// MARK: - Container для обработки успеха

struct BookingViewContainer: View {
    let serviceId: Int64
    let serviceName: String
    let onSuccess: () -> Void
    
    @StateObject private var viewModel: BookingViewModel
    
    init(serviceId: Int64, serviceName: String, onSuccess: @escaping () -> Void) {
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.onSuccess = onSuccess
        _viewModel = StateObject(wrappedValue: BookingViewModel(
            serviceId: serviceId,
            serviceName: serviceName
        ))
    }
    
    var body: some View {
        BookingViewContent(viewModel: viewModel)
            .alert("Успешно! ✅", isPresented: $viewModel.showSuccessAlert) {
                Button("Отлично!") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onSuccess()
                    }
                }
            } message: {
                Text("Вы успешно записались на \(serviceName)")
            }
    }
}

#Preview {
    ServiceSelectionView()
}