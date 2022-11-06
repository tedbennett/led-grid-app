//
//  ColorPickerSettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 06/11/2022.
//

import SwiftUI

struct ColorPickerSettingsView: View {
    @AppStorage(UDKeys.colorPicker.rawValue, store: Utility.store) var variant: ColorPickerVariant = .full
    @StateObject var viewModel = DrawColourViewModel()
    @State private var translation = CGSize.zero
    @State private var showSliders = false
    
    var body: some View {
        List {
            VStack {
                Text("Tap here to test!")
                ColorPickerView(
                    viewModel: viewModel,
                    translation: $translation,
                    showSliders: $showSliders,
                    center: true
                ) { drag in
                        withAnimation {
                            translation = drag
                        }
                    } onDragEnd: { _ in
                        withAnimation {
                            translation = .zero
                        }
                    }
            }
            Button {
                variant = .full
            } label: {
                HStack {
                    Text("Sliders and picker")
                    Spacer()
                    if variant == .full {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button {
                variant = .system
            } label: {
                HStack {
                    Text("Picker")
                    Spacer()
                    if variant == .system {
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button {
                variant = .slider
            } label: {
                HStack {
                    Text("Sliders")
                    Spacer()
                    if variant == .slider {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }.navigationTitle("Color Picker")
    }
}

struct ColorPickerSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerSettingsView()
    }
}
