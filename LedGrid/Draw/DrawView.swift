//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

struct DrawView: View {
    @StateObject var viewModel = DrawViewModel()
    @Environment(\.scenePhase) var scenePhase
    
    var buttons: some View {
        HStack {
            Spacer()
            Button {
                viewModel.clearGrid()
            } label: {
                Text("Clear")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundColor(.red)
                    .padding()
            }.background(Color(uiColor: .systemGray6))
                .cornerRadius(15)
                .padding(.trailing, 5)
            Button {
                viewModel.sendGrid()
            } label: {
                Text("Send").font(.system(.title3, design: .rounded).bold())
                    .padding()
            }.background(Color(uiColor: .systemGray6))
                .cornerRadius(15)
                .padding(.leading, 5)
            Spacer()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                GridView(viewModel: viewModel)
                ColorPickerView(viewModel: viewModel)
                
                buttons
            }
            .navigationTitle("Draw Something")
            .onAppear {
                viewModel.saveGrid()
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .inactive || newPhase == .background {
                    viewModel.saveGrid()
                }
            }
        }
    }
}

struct DrawView_Previews: PreviewProvider {
    static var previews: some View {
        DrawView()
    }
}
