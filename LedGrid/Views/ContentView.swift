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
    init(loggedIn: Binding<Bool>) {
        self._loggedIn = loggedIn
        
        let systemFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        var font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 36)
        } else {
            font = systemFont
        }
        let strokeTextAttributes = [
            NSAttributedString.Key.font : font,
        ] as [NSAttributedString.Key : Any]
        
        UINavigationBar.appearance().largeTitleTextAttributes = strokeTextAttributes
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
    }
    
    @Binding var loggedIn: Bool
    
    var body: some View {
        if loggedIn {
            LoggedInView(loggedIn: $loggedIn)
        } else {
            OnboardingView {
                NavigationManager.shared.currentTab = 0
                withAnimation {
                    loggedIn = true
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


