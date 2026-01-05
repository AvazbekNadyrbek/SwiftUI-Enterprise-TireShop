import Foundation
import SwiftUI
import OpenAPIURLSession
import OpenAPIRuntime
import Combine

@MainActor
class BookingViewModel: ObservableObject {
    
    let serviceId: Int64
    let serviceName: String
    
    @Published var selectedDate: Date = Date()
    @Published var timeSlots: [Components.Schemas.TimeSlotResponse] = []
    @Published var selectedSlotIndex: Int?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showSuccessAlert = false
    
    private let client: Client
    
    init(serviceId: Int64, serviceName: String) {
        self.serviceId = serviceId
        self.serviceName = serviceName
        self.client = ClientFactory.createClient()
    }
    
    func selectSlot(at index: Int) {
        selectedSlotIndex = index
    }
    
    func loadSlots() async {
        isLoading = true
        errorMessage = nil
        timeSlots = []
        selectedSlotIndex = nil
        
        do {
            let dateString = formatDateForServer(selectedDate)
            
            print("📅 Запрашиваем слоты для даты: \(dateString), serviceId: \(serviceId)")
            
            let response = try await client.getSlots(
                query: .init(date: dateString, serviceId: serviceId)
            )
            
            switch response {
                
            case .ok(let okResponse):
                switch okResponse.body {
                case .json(let slots):
                    print("✅ Получено слотов: \(slots.count)")
                    self.timeSlots = slots
                }
                
            case .undocumented(statusCode: let code, _):
                errorMessage = "Ошибка сервера: \(code)"
                print("❌ HTTP \(code)")
            }
            
        } catch let decodingError as DecodingError {
            switch decodingError {
            case .dataCorrupted(let context):
                errorMessage = "Ошибка формата данных: \(context.debugDescription)"
                print("❌ DecodingError: \(context)")
            case .keyNotFound(let key, let context):
                errorMessage = "Отсутствует поле: \(key.stringValue)"
                print("❌ KeyNotFound: \(key) - \(context)")
            case .typeMismatch(let type, let context):
                errorMessage = "Неверный тип данных: \(type)"
                print("❌ TypeMismatch: \(type) - \(context)")
            case .valueNotFound(let type, let context):
                errorMessage = "Отсутствует значение типа: \(type)"
                print("❌ ValueNotFound: \(type) - \(context)")
            @unknown default:
                errorMessage = "Неизвестная ошибка декодирования"
            }
        } catch {
            errorMessage = "Ошибка сети: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }
    
    func bookAppointment() async -> Bool {
        guard let selectedSlotIndex = selectedSlotIndex,
              selectedSlotIndex < timeSlots.count else {
            return false
        }
        
        let slot = timeSlots[selectedSlotIndex]
        
        guard let fullDateTime = combineDateAndTime(date: selectedDate, timeSlot: slot) else {
            errorMessage = "Не удалось создать дату"
            return false
        }
        
        isLoading = true
        
        do {
            let body = Components.Schemas.CreateAppointmentRequest(
                serviceId: serviceId,
                startTime: fullDateTime
            )
            
            let response = try await client.createBooking(body: .json(body))
            
            isLoading = false
            
            switch response {
            case .ok:
                showSuccessAlert = true
                return true
            case .undocumented(statusCode: let code, _):
                errorMessage = "Не удалось записаться. Код: \(code)"
                return false
            }
            
        } catch {
            errorMessage = "Ошибка: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    private func formatDateForServer(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
    private func combineDateAndTime(date: Date, timeSlot: Components.Schemas.TimeSlotResponse) -> Date? {
        guard let localTime = timeSlot.time else { return nil }
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = Int(localTime.hour ?? 0)
        components.minute = Int(localTime.minute ?? 0)
        components.second = 0
        
        return calendar.date(from: components)
    }
}