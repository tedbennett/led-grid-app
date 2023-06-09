//
//  Home.swift
//  LedGrid
//
//  Created by Ted Bennett on 08/06/2023.
//

import OSLog
import SwiftUI

let logger = Logger(subsystem: "Pixee", category: "Canvas")

struct Home: View {
    @State private var tab = 0
    let model = GridModel()

    var body: some View {
        ZStack {
            TabView(selection: $tab) {
                ZStack {
                    VStack {
                        Spacer()
                        CanvasView(model: model)
                        Spacer()
                    }
                    VStack {
                        Spacer().allowsHitTesting(false)
                        BottomBarView()
                    }
                }.tag(0)
                VStack {
                    Text("First")
                }.tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeOut(duration: 0.2), value: tab)
            VStack {
                HeaderBarView(tab: $tab)
                Spacer().allowsHitTesting(false)
            }
        }
    }
}

#Preview {
    Home()
}

struct LocalTapGesture: ViewModifier {
    let action: (CGPoint, CGSize) -> Void
    let space = UUID().uuidString

    func body(content: Content) -> some View {
        content
            .allowsHitTesting(false)
            .coordinateSpace(.named(space))
            .background {
                GeometryReader { geometry in
                    Color.black
                        .onTapGesture(count: 1, coordinateSpace: .named(space)) { position in
                            action(position, geometry.size)
                        }
                }.padding(1)
            }
    }
}

extension View {
    func onLocalTapGesture(_ action: @escaping (CGPoint, CGSize) -> Void) -> some View {
        modifier(LocalTapGesture(action: action))
    }
}
