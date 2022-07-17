//
//  PeripheralManager.swift
//  LedGrid
//
//  Created by Ted Bennett on 03/04/2022.
//

import Foundation
import CoreBluetooth

class PeripheralManager: NSObject, ObservableObject {
    static var shared = PeripheralManager()
    
    private var SERVICE_UUID = CBUUID(string: EnvironmentVariables.serviceUUID)
    private var COLOR_CHARACTERISTIC_UUID = CBUUID(string:  EnvironmentVariables.colorCharacteristicUUID)
    private var CONFIG_CHARACTERISTIC_UUID = CBUUID(string: EnvironmentVariables.configCharacteristicUUID)
    
    private override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    private var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var colorCharacteristic: CBCharacteristic?
    var configCharacteristic: CBCharacteristic?
    
    @Published var connected = false
    
    func sendToDevice(colors: [String]) {
        let colors = colors.map { String($0.suffix(6))}.joined(separator: "")
        guard let peripheral = peripheral,
              let characteristic = colorCharacteristic else { return }
        let data = colors.data(using: .utf8)!
        peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    func updateConfig(config: Config) {
        guard let peripheral = peripheral,
              let characteristic = configCharacteristic,
              let data = try? JSONEncoder().encode(config) else { return }
        peripheral.writeValue(data, for: characteristic, type: CBCharacteristicWriteType.withoutResponse)
    }
    
    func startScanning() {
        centralManager.stopScan()
        centralManager.scanForPeripherals(withServices: [SERVICE_UUID])
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func disconnect() {
        guard let peripheral = peripheral else {
            connected = false
            return
        }
        let colors = [
            "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
            "#000000","#110000","#000000","#000000","#000000","#000000","#110000","#000000",
            "#000000","#000000","#110000","#000000","#000000","#110000","#000000","#000000",
            "#000000","#000000","#000000","#110000","#110000","#000000","#000000","#000000",
            "#000000","#000000","#000000","#110000","#110000","#000000","#000000","#000000",
            "#000000","#000000","#110000","#000000","#000000","#110000","#000000","#000000",
            "#000000","#110000","#000000","#000000","#000000","#000000","#110000","#000000",
            "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000"
        ]
        sendToDevice(colors: colors)
        centralManager.cancelPeripheralConnection(peripheral)
    }
}

// MARK: CBCentralManagerDelegate

extension PeripheralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("State did change")
        switch central.state {
        case .poweredOff: stopScanning()
        case .poweredOn: startScanning()
        case .unsupported: break
        case .unauthorized: break
        case .unknown: break
        case .resetting: break
        @unknown default:
            print("Error")
        }
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        self.peripheral = peripheral
        centralManager.connect(peripheral)
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        stopScanning()
        print("Connected")
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
    }
    
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print(error!)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.peripheral = nil
        
        connected = false
    }
}

// MARK: CBPeripheralDelegate

extension PeripheralManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            if characteristic.uuid.isEqual(COLOR_CHARACTERISTIC_UUID) {
                self.colorCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            } else if characteristic.uuid.isEqual(CONFIG_CHARACTERISTIC_UUID) {
                self.configCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
        if self.peripheral != nil {
            connected = true
            updateConfig(config: Config(delay: Utility.gridDuration))
            let colors = [
                "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000",
                "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#001100",
                "#000000","#000000","#000000","#000000","#000000","#000000","#001100","#000000",
                "#000000","#000000","#000000","#000000","#000000","#001100","#000000","#000000",
                "#001100","#000000","#000000","#000000","#001100","#000000","#000000","#000000",
                "#000000","#001100","#000000","#001100","#000000","#000000","#000000","#000000",
                "#000000","#000000","#001100","#000000","#000000","#000000","#000000","#000000",
                "#000000","#000000","#000000","#000000","#000000","#000000","#000000","#000000"
            ]
            sendToDevice(colors: colors)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                
                self.sendToDevice(colors: Array(repeating: "#000000", count: 64))
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value,
           let string = String(data: data, encoding: .utf8) {
            print(string)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print("Peripheral modified services")
        if invalidatedServices.contains(where: {$0.uuid == SERVICE_UUID}) {
            self.peripheral = nil
            self.connected = false
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
        }
        
    }
}

struct Config: Codable {
    var delay: Int
}
