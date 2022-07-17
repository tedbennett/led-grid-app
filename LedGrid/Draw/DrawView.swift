//
//  DrawView.swift
//  LedGrid
//
//  Created by Ted Bennett on 29/03/2022.
//

import SwiftUI

struct DrawView: View {
    @StateObject var viewModel = DrawViewModel()
    @ObservedObject var peripheralManager = PeripheralManager.shared
    @Environment(\.scenePhase) var scenePhase
    
    var headerButtons: some View {
        HStack(alignment: .center, spacing: 5) {
            Button {
                viewModel.sendGridToDevice()
            } label: {
                Text("Preview").font(.system(.title3, design: .rounded).bold())
                    .padding()
            }.disabled(!peripheralManager.connected).background(Color(uiColor: .systemGray6))
                .cornerRadius(15)
            Menu("...") {
                Button {
                    viewModel.isLiveEditing.toggle()
                } label: {
                    Text("\(viewModel.isLiveEditing ? "Stop" : "Start") Live Preview")
                }.disabled(!PeripheralManager.shared.connected)
                Button {
                    viewModel.clearGrid()
                } label: {
                    Text("Clear").tint(.red)
                }
            }
            .font(.system(.title3, design: .rounded).bold())
            .padding()
            .background(Color(uiColor: .systemGray6))
            .cornerRadius(15)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                headerButtons
                GridView(viewModel: viewModel)
                ColorPickerView(viewModel: viewModel)
                Button {
                    viewModel.uploadGrid()
                } label: {
                    Text("Send to \(EnvironmentVariables.recipientId)")
                        .font(.system(.title3, design: .rounded).bold())
                        .padding()
                }.background(Color(uiColor: .systemGray6))
                    .cornerRadius(15)
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
            .previewDevice("iPhone 13 mini")
    }
}
