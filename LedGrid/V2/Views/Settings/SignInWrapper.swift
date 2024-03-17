//
//  SignInWrapper.swift
//  LedGrid
//
//  Created by Ted Bennett on 17/03/2024.
//

import Foundation
import SwiftUI

struct SignInWrapper<Content1: View, Content2: View>: View {
    @ViewBuilder var content: () -> Content1
    @ViewBuilder var destination: (APIUser) -> Content2

    var body: some View {
        Group {
        }
    }
}
