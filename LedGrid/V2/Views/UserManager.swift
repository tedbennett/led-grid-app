//
//  UserManager.swift
//  LedGrid
//
//  Created by Ted Bennett on 10/02/2024.
//

import SwiftUI

@Observable
class UserManager {
    var user: APIUser

    init(user: APIUser) {
        self.user = user
    }
}
