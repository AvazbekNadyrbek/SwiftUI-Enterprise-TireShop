//
//  BookingListView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct BookingListView: View {
    
    @StateObject private var viewModel = BookingListViewModel()
    @State private var showingServiceSelection = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.bookings.isEmpty {
                    ProgressView("Загрузка...")
                } else if let error = viewModel.errorMessage, viewModel.bookings.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        Button("Повторить") {
                            Task { await viewModel.loadBookings() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if viewModel.bookings.isEmpty {
                    emptyStateView
                } else {
                    bookingsList
                }
            }
            .navigationTitle("Мои записи")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.isRefreshing {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingServiceSelection = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingServiceSelection) {
                Task { await viewModel.loadBookings(isRefresh: true) }
            } content: {
                ServiceSelectionView()
            }
            .task {
                if viewModel.bookings.isEmpty && !viewModel.isLoading {
                    await viewModel.loadBookings()
                }
            }
        }
    }
    
    // MARK: - Пустое состояние
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 70))
                .foregroundColor(.gray)
            
            Text("У вас пока нет записей")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Выберите услугу и запишитесь на удобное время")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button {
                showingServiceSelection = true
            } label: {
                Label("Создать запись", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    
    // MARK: - Список записей
    
    private var bookingsList: some View {
        List {
            let now = Date()
            let upcoming = viewModel.bookings.filter { $0.startTime >= now }
            let past = viewModel.bookings.filter { $0.startTime < now }
            
            if !upcoming.isEmpty {
                Section {
                    ForEach(upcoming) { booking in
                        BookingCard(booking: booking)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.cancelBooking(booking)
                                    }
                                } label: {
                                    Label("Отменить", systemImage: "xmark.circle")
                                }
                            }
                    }
                } header: {
                    Text("Предстоящие")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .textCase(nil)
                }
            }
            
            if !past.isEmpty {
                Section {
                    ForEach(past) { booking in
                        BookingCard(booking: booking)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .opacity(0.6)
                    }
                } header: {
                    Text("История")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.loadBookings(isRefresh: true)
        }
    }
}

// MARK: - Карточка записи

struct BookingCard: View {
    let booking: AppointmentItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Название услуги
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(.blue)
                Text(booking.serviceName)
                    .font(.headline)
                Spacer()
                statusBadge
            }
            
            // Дата и время
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.secondary)
                Text(formattedTime)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Заметки (если есть)
            if let notes = booking.notes, !notes.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "note.text")
                        .foregroundColor(.secondary)
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private var statusBadge: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }
    
    private var statusText: String {
        switch booking.status.uppercased() {
        case "PENDING": return "Ожидает"
        case "CONFIRMED": return "Подтверждено"
        case "CANCELLED": return "Отменено"
        case "COMPLETED": return "Выполнено"
        default: return booking.status
        }
    }
    
    private var statusColor: Color {
        switch booking.status.uppercased() {
        case "PENDING": return .orange
        case "CONFIRMED": return .green
        case "CANCELLED": return .red
        case "COMPLETED": return .blue
        default: return .gray
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: booking.startTime)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: booking.startTime)
    }
}

#Preview {
    BookingListView()
}