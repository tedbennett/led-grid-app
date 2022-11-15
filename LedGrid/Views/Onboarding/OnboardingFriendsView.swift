//
//  OnboardingFriendsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 15/11/2022.
//

import SwiftUI

struct OnboardingFriendsView: View {
        var onComplete: () -> Void
        
        var body: some View {
            VStack {
                Spacer()
                    VStack {
                        Image(systemName: "person.2.fill").font(.largeTitle)
                        Text("Add Friends")
                            .font(.system(size: 30, design: .rounded).weight(.bold))
                    }
                    .fadeInWithDelay(0.3)
                    .padding(.top, 20)
                    
                    VStack {
                        Text("Share your art with friends! To invite a friend, just press the button below to share a link with them")
                        
                            .font(.system(size: 20, design: .rounded).weight(.medium))
    //                        .font(.title3)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.top)
                        
                        Text("You can always add friends later from Settings tab.")
                        
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
                        Helpers.presentAddFriendShareSheet()
                    } label: {
                        Text("Add Friends")
                    }.buttonStyle(LargeButton())
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

struct OnboardingFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFriendsView {
            
        }
    }
}
