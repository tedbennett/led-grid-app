//
//  RequestNotificationsVIew.swift
//  LedGrid
//
//  Created by Ted Bennett on 14/11/2022.
//

import SwiftUI


struct RequestNotificationsView: View {
    @State private var requesting = false
    var onComplete: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
                VStack {
                    Image(systemName: "bell.circle").font(.largeTitle)
                    Text("Notifications")
                        .font(.system(size: 30, design: .rounded).weight(.bold))
                }
                .fadeInWithDelay(0.3)
                .padding(.top, 20)
                
                VStack {
                    Text("Pixee sends notifications when you receive art, a friend request, or a reaction to your art")
                    
                        .font(.system(size: 20, design: .rounded).weight(.medium))
//                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.top)
                    
                    Text("You can always change your preferences later in Settings")
                    
                        .font(.system(size: 20, design: .rounded).weight(.medium))
//                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.vertical)
                }
                .fadeInWithDelay(0.6)
            Spacer()
            VStack {
                Button {
                    requesting = true
                    Task {
                        await NotificationManager.shared.requestPermission()
                        await MainActor.run {
                            requesting = false
                            onComplete()
                        }
                    }
                } label: {
                    if requesting {
                        Spinner()
                    } else {
                        Text("Allow Notifications")
                    }
                }.buttonStyle(LargeButton())
                    .disabled(requesting)
                    .padding(.horizontal, 30)
                
                Button {
                    onComplete()
                } label: {
                    HStack {
                        Text("Skip")
                        Image(systemName: "chevron.right")
                    }.foregroundColor(.gray)
                }.padding(5)
                .padding(.horizontal, 30)
            }
            .fadeInWithDelay(0.9)
                .padding(.bottom, 60)
        }
    }
}


struct RequestNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        RequestNotificationsView {
            
        }
    }
}
