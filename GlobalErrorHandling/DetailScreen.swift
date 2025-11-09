//
//  DetailScreen.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 30.10.25.
//

import SwiftUI

struct DetailScreen: View {
    
    @Environment(\.showError) private var showError
    var body: some View {
        VStack(spacing: 20) {
            Text("Sheet Content")
                .font(.largeTitle)
            
            Button {
                showError(SampleError.operationFailed, "Sheet Error Demo")
            } label: {
                Text("Trigger Error from Sheet")
            }
            
            Spacer()
        }
    }
}

#Preview {
    DetailScreen()
}
