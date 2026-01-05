import Foundation
import OpenAPIURLSession
import OpenAPIRuntime

// 1. Транскодер дат (чтобы понимать Java)
struct JavaDateTranscoder: DateTranscoder {
    
    private let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" // Без Z, как шлет Spring
        f.calendar = Calendar(identifier: .iso8601)
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    // Запасной для миллисекунд
    private let formatterMillis: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        f.calendar = Calendar(identifier: .iso8601)
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()
    
    func encode(_ date: Date) throws -> String {
        return formatter.string(from: date)
    }
    
    func decode(_ dateString: String) throws -> Date {
        if let date = formatter.date(from: dateString) { return date }
        if let date = formatterMillis.date(from: dateString) { return date }
        
        // Попытка обрезать Z если есть
        let clean = dateString.replacingOccurrences(of: "Z", with: "")
        if let date = formatter.date(from: clean) { return date }
        
        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Дата не распознана: \(dateString)"))
    }
}

// 2. Фабрика
enum ClientFactory {
    static func createClient() -> Client {
        let url = URL(string: "http://localhost:8080")!
        let transport = URLSessionTransport()
        let middleware = AuthenticationMiddleware()
        
        var config = OpenAPIRuntime.Configuration()
        config.dateTranscoder = JavaDateTranscoder()
        
        return Client(
            serverURL: url,
            configuration: config,
            transport: transport,
            middlewares: [middleware]
        )
    }
}
