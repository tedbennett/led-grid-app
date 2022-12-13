//
//  OnboardingView.swift
//  LedGrid
//
//  Created by Ted Bennett on 11/11/2022.
//

import SwiftUI

enum OnboardingStep {
    case none
    case signIn
    case notifications
    case friends
    case tutorialDraw
    case plus
}

struct OnboardingView: View {
    @ObservedObject var viewModel: LoginViewModel
    @State private var step = OnboardingStep.none
    @State private var hidden = true
    
    var onComplete: () -> Void
    
    
    var title: some View {
        VStack {
            Text("Welcome to")
                .font(.system(size: 24, design: .rounded).weight(.bold))
                .foregroundColor(.gray)
                .fadeInWithDelay(0.2)
            Text("Pixee")
                .font(.system(size: 40, design: .rounded).weight(.bold))
                .fadeInWithDelay(0.4)
        }
    }
    
    var showTitle: Bool {
        step == .signIn || step == .none
    }
    
    var body: some View {
        VStack {
            
            if showTitle {
                title
            }
            switch step {
            case .signIn:
                SignInView(viewModel: viewModel) {
                    Task {
                        if await NotificationManager.shared.isAuthorised() {
                            withAnimation {
                                step = .friends
                            }
                        } else {
                            withAnimation {
                                step = .notifications
                            }
                        }
                    }
                }
            case .notifications:
                RequestNotificationsView {
                    withAnimation {
                        step = .friends
                    }
                }
            case .friends:
                OnboardingFriendsView {
                    withAnimation {
                        step = .tutorialDraw
                    }
                }
            case .tutorialDraw:
                DrawTutorialView {
                    withAnimation {
                        step = .plus
                    }
                }
            case .plus:
                OnboardingPlusView {
                    onComplete()
                }
            default:
                EmptyView()
            }
        }.padding(EdgeInsets(top: showTitle ? 40 : 20, leading: 20, bottom: 20, trailing: 20)).onAppear {
            Task {
                try! await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    withAnimation {
                        step = .signIn
                    }
                }
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(viewModel: LoginViewModel(loggedIn: false)) {}
    }
}

struct FadeInWithDelay: ViewModifier {
    @State private var hidden = true
    let delay: Double
    func body(content: Content) -> some View {
        content
            .opacity(hidden ? 0 : 1)
            .animation(.easeInOut.delay(delay), value: hidden)
            .onAppear { hidden = false }
    }
}

extension View {
    func fadeInWithDelay(_ delay: Double) -> some View {
        self.modifier(FadeInWithDelay(delay: delay))
  }
}
