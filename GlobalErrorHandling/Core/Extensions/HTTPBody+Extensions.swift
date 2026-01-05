//
//  HTTPBody+Extensions.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import Foundation
import OpenAPIRuntime

extension HTTPBody {
    
    /// Конвертирует HTTPBody в декодированный объект
    /// - Parameters:
    ///   - type: Тип для декодирования
    ///   - maxBytes: Максимальный размер данных (по умолчанию 10MB)
    /// - Returns: Декодированный объект
    func decode<T: Decodable>(
        _ type: T.Type,
        upTo maxBytes: Int = 10 * 1024 * 1024
    ) async throws -> T {
        let data = try await Data(collecting: self, upTo: maxBytes)
        return try JSONDecoder().decode(type, from: data)
    }
}