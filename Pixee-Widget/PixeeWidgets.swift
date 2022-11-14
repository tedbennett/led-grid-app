//
//  WidgetBudnle.swift
//  Pixee-WidgetExtension
//
//  Created by Ted Bennett on 07/11/2022.
//

import SwiftUI

@main
struct PixeeWidgets: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        FriendWidget()
        // TODO: 1.2
        // NamedArtWidget()
    }
}
