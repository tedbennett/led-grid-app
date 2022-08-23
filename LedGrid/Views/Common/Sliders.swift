//
//  Sliders.swift
//  LedGrid
//
//  Created by Ted on 06/08/2022.
//

import SwiftUI
import Sliders

struct ColorPickerSlider: View {
    @Binding var value: Double
    
    var body: some View {
        CustomSlider(value: $value, colors: [
            Color(UIColor.red),
            Color(UIColor.yellow),
            Color(UIColor.green),
            Color(UIColor.cyan),
            Color(UIColor.blue),
            Color(UIColor.purple),
            Color(UIColor.red)
        ])
    }
}

struct OpacityPickerSlider: View {
    @Binding var value: Double
    
    var body: some View {
        CustomSlider(value: $value, colors: [
            Color(UIColor.black),
            Color(UIColor.white)
        ])
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    var colors: [Color]
    var body: some View {
        ValueSlider(value: $value)
            .valueSliderStyle(HorizontalValueSliderStyle(
                track: HorizontalValueTrack(view: EmptyView())
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: colors),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .mask(RoundedRectangle(cornerRadius: 3).frame(height: 4))
                    ),
                thumb: DefaultThumb()
            )
            )
    }
}
