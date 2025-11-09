//
//  View+Extentions.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 09.11.25.
//

import Foundation
import SwiftUI

extension View {
    func withErrorView() -> some View {
        modifier(ErrorModifier())
    }
}
