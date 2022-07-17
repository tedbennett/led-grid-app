//
//  SettingsView.swift
//  LedGrid
//
//  Created by Ted Bennett on 30/03/2022.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var manager = PeripheralManager.shared
    var durationOptions = [1, 3, 5, 10, 15, 20, 30, 60, 90, 120, 180, 240, 300]
    @State private var durationIndex: Int = [1, 3, 5, 10, 15, 20, 30, 60, 90, 120, 180, 240, 300].firstIndex {
        $0 == Utility.gridDuration
        
    } ?? 2
    
    func durationToString(_ duration: Int) -> String {
        if duration < 120 {
            return "\(duration)s"
        }
        return "\(duration / 60) min"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("LED Grid Device")) {
                    if manager.connected {
                        Text("Connected to \(EnvironmentVariables.userId)'s Grid")
                        Button {
                            manager.disconnect()
                        } label: {
                            Text("Disconnect").foregroundColor(.red)
                        }
                    } else {
                        Button {
                            manager.startScanning()
                        } label: {
                            Text("Connect to Device")
                        }
                    }
                }
                
                Section {
                    Picker("Light Duration", selection: $durationIndex) {
                        ForEach(0..<durationOptions.count, id: \.self) { index in
                            let duration = durationOptions[index]
                            Text(durationToString(duration)).tag(index)
                        }
                    }.onChange(of: durationIndex) { index in
                        let duration = durationOptions[index]
                        PeripheralManager.shared.updateConfig(config: Config(delay: duration))
                        Utility.gridDuration = duration
                    }
                }
                
                
            }.navigationTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
