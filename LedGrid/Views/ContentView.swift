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
    init() {
        let systemFont = UIFont.systemFont(ofSize: 36, weight: .bold)
        var font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: 36)
        } else {
            font = systemFont
        }
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.label,
            NSAttributedString.Key.foregroundColor : UIColor.systemBackground,
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.strokeWidth : 4]
        as [NSAttributedString.Key : Any]
        
        UINavigationBar.appearance().largeTitleTextAttributes = strokeTextAttributes
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .label
    }
    
    @State private var loggedIn = false
    
    var body: some View {
        if loggedIn {
            LoggedInView(loggedIn: $loggedIn)
        } else {
            LoginView(loggedIn: $loggedIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


