//
//  UserOrb.swift
//  LedGrid
//
//  Created by Ted on 01/08/2022.
//

import SwiftUI

struct UserOrb: View {
    var user: User?
    var isSelected: Bool = false
    
    var body: some View {
        InitialsOrbView(
            text: user?.fullName?.split(separator: " ")
                .map { $0.prefix(1) }
                .joined()
                .uppercased()
        )
    }
}

struct UserOrb_Previews: PreviewProvider {
    static var previews: some View {
        UserOrb(user: User.example)
    }
}
