//
//  Helpers.swift
//  LedGrid
//
//  Created by Ted on 29/08/2022.
//

import UIKit

struct Helpers {
    static func presentAddFriendShareSheet() {
        guard let userId = Utility.user?.id,
              let url = URL(string: "https://www.pixee-app.com/user/\(userId)") else { return }
        let message = "Add me on Pixee to share pixel art!"
        let activityVC = UIActivityViewController(activityItems: [message, url], applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        windowScene?.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    static func presentArtShareSheet(image: UIImage) {
        let message = "Add me on Pixee to create and share pixel art!"
        let activityVC = UIActivityViewController(activityItems: [image, message], applicationActivities: nil)
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        windowScene?.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
    
    static func getImageData(for art: PixelArt) -> Data? {
        let colors = art.art.toColors()
        
        return GridView(grid: colors[0], viewSize: .large).snapshot().pngData()
    }
}

