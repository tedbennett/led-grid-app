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
    
    @AppStorage(UDKeys.spinningLogo.rawValue, store: Utility.store) var allowSpin = true
    @AppStorage(UDKeys.motionLogo.rawValue, store: Utility.store) var motionSpin = false
    
    @State private var angle = 45.0
    
    var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        HStack {
            
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48, weight: .regular))
                .padding(0)
                .rotationEffect(Angle(degrees: angle))
                .coordinateSpace(name: "icon")
            
       }
//        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//            .onChanged { drag in
//                drag.
//            })
       .onAppear {
           self.motionManager.startDeviceMotionUpdates(to: queue) { (data: CMDeviceMotion?, error: Error?) in
               guard let data = data, Utility.motionLogo else {
                   return
               }

               angle -= (data.rotationRate.z / 3)
           }
       }.onReceive(timer) { _ in
           if !allowSpin { return }
           withAnimation {
               angle += 1
           }
       }
       .onChange(of: allowSpin) {
           if !$0 { angle = 45 }
       }
       .onChange(of: motionSpin) {
           if !$0 { angle = 45 }
       }
    }
}

struct RotatingLogoView_Previews: PreviewProvider {
    static var previews: some View {
        RotatingLogoView()
    }
}
