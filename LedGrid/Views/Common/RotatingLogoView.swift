//
//  RotatingLogoView.swift
//  LedGrid
//
//  Created by Ted Bennett on 28/10/2022.
//

import SwiftUI
import CoreMotion

struct RotatingLogoView: View {
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    @State private var yaw = Double.zero
    var body: some View {
        HStack {
            
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48, weight: .regular))
                .padding(0)
                .rotationEffect(Angle(degrees: (yaw * 90) + 45))
       }
       .onAppear {
           self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
               guard let data = data else {
                   return
               }
               let attitude: CMAttitude = data.attitude

               if abs(self.yaw - attitude.yaw) > 0.1 {
                   withAnimation {
                       self.yaw = attitude.yaw
                   }
               }
           }
       }
    }
}

struct RotatingLogoView_Previews: PreviewProvider {
    static var previews: some View {
        RotatingLogoView()
    }
}
