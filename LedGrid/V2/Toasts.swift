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
    case errorOccurred
    case profileUpdated

    func alert() -> AlertToast {
        switch self {
        case .signInSuccess:
            return AlertToast(displayMode: .hud, type: .complete(.white), title: "Signed in successfully")
        case .signInFailed:
            return AlertToast(displayMode: .hud, type: .error(.white), title: "Sign in failed")
        case .logoutSuccess:
            return AlertToast(displayMode: .hud, type: .complete(.white), title: "Logout failed")
        case .sentDrawingSuccess:
            return AlertToast(displayMode: .hud, type: .complete(.white), title: "Drawing sent!")
        case .sentDrawingFailed:
            return AlertToast(displayMode: .hud, type: .error(.white), title: "Failed to send drawing")
        case .friendInviteSent:
            return AlertToast(displayMode: .hud, type: .complete(.white), title: "Friend invite sent")
        case .profileUpdated:
            return AlertToast(displayMode: .hud, type: .complete(.white), title: "Profile updated")
        case .errorOccurred:
            return AlertToast(displayMode: .hud, type: .error(.white), title: "An error occurred")
        }
    }

    func present() {
        NotificationCenter.default.post(name: Notification.Name.toast, object: self)
    }
}

extension Notification.Name {
    static var toast = Notification.Name("TOAST")
}
