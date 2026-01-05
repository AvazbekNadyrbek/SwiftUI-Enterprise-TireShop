//
//  TimeSlotPickerView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct TimeSlotPickerView: View {
    let date: Date
    let serviceId: Int64
    
    var body: some View {
        Text("Выбор времени на \(date.formatted())")
            .navigationTitle("Выбор времени")
    }
}