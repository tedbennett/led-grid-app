//
//  ContentView.swift
//  LedGrid
//
//  Created by Ted Bennett on 27/03/2022.
//

import SwiftUI
import AlertToast
import WidgetKit

struct ContentView: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        if viewModel.loggedIn {
            LoggedInView(loggedIn: $viewModel.loggedIn)
        } else {
            OnboardingView(viewModel: viewModel) {
                NavigationManager.shared.currentTab = 0
                withAnimation {
                    viewModel.loggedIn = true
                }
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


