//
//  TireDetailView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 1/5/26.
//

import SwiftUI

struct TireDetailView: View {
    let tireId: Int64
    
    var body: some View {
        Text("Детали шины #\(tireId)")
            .navigationTitle("Шина #\(tireId)")
    }
}