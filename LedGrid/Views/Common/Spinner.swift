//
//  Spinner.swift
//  LedGrid
//
//  Created by Ted Bennett on 02/04/2024.
//

import SwiftUI

struct Spinner: View {
    @State private var isRotating = 0.0
    var size = 7.0
    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 1).stroke(.primary, lineWidth: 1)
                    .frame(width: size, height: size)
                RoundedRectangle(cornerRadius: 1).stroke(.primary, lineWidth: 1)
                    .frame(width: size, height: size)
            }
            HStack(spacing: 3) {
                RoundedRectangle(cornerRadius: 1).stroke(.primary, lineWidth: 1)
                    .frame(width: size, height: size)
                RoundedRectangle(cornerRadius: 1).stroke(.primary, lineWidth: 1)
                    .frame(width: size, height: size)
            }
        }.rotationEffect(.degrees(isRotating))
            .onAppear {
                withAnimation(.linear(duration: 1)
                    .speed(0.7).repeatForever(autoreverses: false))
                {
                    isRotating = 360.0
                }
            }
    }
}

#Preview {
    Spinner()
}
