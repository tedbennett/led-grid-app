//
//  Toasts.swift
//  LedGrid
//
//  Created by Ted Bennett on 15/03/2024.
//

import AlertToast
import Foundation
import Swift

enum Toast {
    case signInSuccess
    case signInFailed
    case logoutSuccess
    case sentDrawingSuccess
    case sentDrawingFailed
    case friendInviteSent
    case friendRequestAccepted
    case friendRequestRejected
    case errorOccurred
    case profileUpdated

    func alert() -> AlertToast {
        switch self {
        case .signInSuccess:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Signed in successfully")
        case .signInFailed:
            return AlertToast(displayMode: .hud, type: .error(.primary), title: "Sign in failed")
        case .logoutSuccess:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Logged out successfully")
        case .sentDrawingSuccess:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Drawing sent!")
        case .sentDrawingFailed:
            return AlertToast(displayMode: .hud, type: .error(.primary), title: "Failed to send drawing")
        case .friendInviteSent:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Friend invite sent")
        case .profileUpdated:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Profile updated")
        case .errorOccurred:
            return AlertToast(displayMode: .hud, type: .error(.primary), title: "An error occurred")
        case .friendRequestAccepted:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Friend request accepted")
        case .friendRequestRejected:
            return AlertToast(displayMode: .hud, type: .complete(.primary), title: "Friend request dismissed")
        }
    }

    func present() {
        NotificationCenter.default.post(name: Notification.Name.toast, object: self)
    }
}

extension Notification.Name {
    static var toast = Notification.Name("TOAST")
    static var showSignIn = Notification.Name("SHOW_SIGN_IN")
    static var handleSignIn = Notification.Name("HANDLE_SIGN_IN")
    static var logout = Notification.Name("LOGOUT")
    static var navigate = Notification.Name("NAVIGATE")
}
