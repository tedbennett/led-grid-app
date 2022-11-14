//
//  ColorPickerView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct ColorPickerView: View {
    @AppStorage(UDKeys.colorPicker.rawValue, store: Utility.store) var variant: ColorPickerVariant = .full
    @ObservedObject var viewModel: DrawColourViewModel
    
    @Binding var translation: CGSize
    @Binding var showSliders: Bool
    @State private var colour = Color.red
    var center = false
    
    var onDragChange: (CGSize) -> Void
    var onDragEnd: (CGPoint) -> Void
    
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                if showSliders {
                    VStack {
                        ColorPickerSlider(value: $viewModel.hue).padding(.horizontal, 5)
                            .padding(.vertical, 0)
                            .frame(height: 20)
                        OpacityPickerSlider(value: $viewModel.opacity)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 0)
                            .frame(height: 20)
                    }
                    if variant == .full {
                        ColorPicker("", selection: $viewModel.currentColor, supportsOpacity: false)
                            .labelsHidden()
                    }
                }
                ZStack {
                    Circle()
                        .strokeBorder(.gray)
                        .background(Circle().fill(viewModel.currentColor))
                        .frame(width: 40, height: 40, alignment: .center)
                        .padding(10)
                        .onTapGesture {
                            if variant == .system { return }
                            withAnimation {
                                showSliders.toggle()
                            }
                        }
                        .allowsHitTesting(variant != .system)
                        .simultaneousGesture(DragGesture().onChanged {
                            onDragChange($0.translation)
                        })
                        .simultaneousGesture(DragGesture(coordinateSpace: .global).onEnded {
                            onDragEnd($0.location)
                        })
                    
                    Circle().fill(viewModel.currentColor).frame(width: 40, height: 40).padding(10)
                        .scaleEffect(translation == CGSize.zero ? 0.5 : 1.2)
                        .offset(translation)
                        .shadow(color: translation == CGSize.zero ? .clear : .black, radius: translation == CGSize.zero ? 0 : 5)
                        .zIndex(translation != .zero ? 2 : 0)
                        .allowsHitTesting(false)
                    if variant == .system {
                        ColorPicker("", selection: $viewModel.currentColor, supportsOpacity: false)
                            .labelsHidden()
                            .opacity(0.015)
                            .simultaneousGesture(DragGesture().onChanged {
                                onDragChange($0.translation)
                            })
                            .simultaneousGesture(DragGesture(coordinateSpace: .global).onEnded {
                                onDragEnd($0.location)
                            })
                    }
                }
                if center && !showSliders {
                    Spacer()
                }
            }.onChange(of: variant) {
                if $0 == .system {
                    showSliders = false
                }
            }
        }
    }
}

//struct ColorPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        ColorPickerView(viewModel: DrawColourViewModel(), translation: .constant(.zero), movementDrag: DragGesture(), coordinateDrag: DragGesture())
//    }
//}


//extension ColorPickerVariant {
//    public init?(rawValue: String) {
//        guard let variant = ColorPickerVariant(rawValue: rawValue) else {
//            return nil
//        }
//        self = variant
//    }
//
//    public var rawValue: String {
//        self.rawValue
//    }
//}
