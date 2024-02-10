//
//  Debounce.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import Combine
import Foundation
import SwiftUI

/// Debounce View Modifier
/// Debounce implementation from here: https://stackoverflow.com/questions/74466453/async-search-bar
/// I just made it a VM
struct Debounce<T: Equatable>: ViewModifier {
    var value: T
    var publisher: PassthroughSubject<T, Never>
    var scheduler: DispatchQueue
    var duration: Int
    var action: (T) -> Void

    func body(content: Content) -> some View {
        content
            .onChange(of: value) { val, _ in
                publisher.send(val)
            }
            .onReceive(publisher.debounce(for: .milliseconds(duration), scheduler: DispatchQueue.main), perform: { val in
                action(val)
            })
    }
}

extension View {
    func debounce<T: Equatable>(_ value: T, publisher: PassthroughSubject<T, Never>, duration: Int = 500, scheduler: DispatchQueue = DispatchQueue.main, action: @escaping (T) -> Void) -> some View {
        modifier(Debounce(value: value, publisher: publisher, scheduler: scheduler, duration: duration, action: action))
    }
}
