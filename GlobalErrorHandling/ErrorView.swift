//
//  ErrorView.swift
//  GlobalErrorHandling
//
//  Created by Авазбек Надырбек уулу on 30.10.25.
//

import SwiftUI

struct ErrorView: View {
    
    @Binding var errorWrapper: ErrorWrapper?
    @State private var offset: CGFloat = 100
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(errorWrapper?.error.localizedDescription ?? "")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(errorWrapper?.guidance ?? "")
                        .font(.subheadline)
                }
                
                Spacer()
                
                Button {
                    withAnimation(.spring()) {
                        errorWrapper = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.red)
                .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
        )
        .padding(.horizontal)
        .padding(.bottom, 16)
        .offset(y: offset)
        .task(id: errorWrapper?.id) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                offset = 0
            }
            
            // Автоматически скрываем через 4 секунды
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            
            withAnimation(.spring()) {
                offset = 100
            }
            
            try? await Task.sleep(for: .milliseconds(300))
            errorWrapper = nil
        }
    }
}

#Preview {
    VStack {
        Spacer()
        ErrorView(errorWrapper: .constant(ErrorWrapper(
            error: APIError.networkError(underlying: URLError(.notConnectedToInternet)),
            guidance: "Проверьте подключение к интернету"
        )))
    }
}