//
//  MyBluetooth.swift
//  BluetoothComponent
//
//  Created by Mehul Jadav on 13/11/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import CoreBluetooth

var kDefaultErrorCode = 1234

@objc protocol MyBluetoothDelegate:class {

    @objc optional func receivePeripherals(peripherals:[CBPeripheral])
    @objc optional func dataRecieved(message:String)
}

class MyBluetooth: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {

    public static let `default` = MyBluetooth()
    weak var delegate:MyBluetoothDelegate?
    
    var manager:CBCentralManager?               = nil
    var peripherals:[CBPeripheral]              = []
    var connectedPeripheral:CBPeripheral?       = nil
    var mainCharacteristic:CBCharacteristic?    = nil
    var isConnected: Bool? {
        (self.connectedPeripheral != nil)
    }
    var connectionStatus : CBManagerState? {
        self.manager?.state
    }
    //let BLEService = "DFB0"
    var BLEService  : String?   {
        if isConnected == true {
            return "\(String(describing: self.connectedPeripheral?.identifier))"
        }
        return ""
    }
    let BLECharacteristic   = "DFB1"
    
    public override init() {
        super.init()
        intialize()
    }
    func intialize() {
        self.manager = CBCentralManager(delegate: self, queue: nil)
    }
}

//MARK:- Other methods
extension MyBluetooth {
    
    func getConnectedPeripheral()->CBPeripheral? {
        return connectedPeripheral
    }
    
    func disConnect() {
        if connectedPeripheral != nil {
            self.manager?.cancelPeripheralConnection(self.connectedPeripheral!)
        }
    }
    
    func scanBLEDevices() {
        
        switch self.manager!.state {
          case .unknown:
            //print("central.state is .unknown")
            break
          case .resetting:
            //print("central.state is .resetting")
            break
          case .unsupported:
            //print("central.state is .unsupported")
            break
          case .unauthorized:
            //print("central.state is .unauthorized")
            break
          case .poweredOff:
            //print("central.state is .poweredOff")
            break
          case .poweredOn:
            //print("central.state is .poweredOn")
            //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
            self.manager?.scanForPeripherals(withServices: nil, options: nil)
            //stop scanning after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                //self.stopScan()
            }
            break
        @unknown default:
            break
        }
        //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
        manager?.scanForPeripherals(withServices: nil, options: nil)
        
        //stop scanning after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.stopScan()
        }
    }
    
    func stopScan() {
        manager?.stopScan()
    }
    
    func connectToPeripheral(peripheral : CBPeripheral) {
        self.manager?.connect(peripheral, options: nil)
    }
}

//MARK:- Send-Revieve Message
extension MyBluetooth {
    
    func sendMessage(message : String, completion: @escaping (_ success: Bool?, _ error : Error?) -> ()) {

        let dataToSend = message.data(using: String.Encoding.utf8)
        if (connectedPeripheral != nil && mainCharacteristic != nil) {
            self.connectedPeripheral?.writeValue(dataToSend!, for: mainCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
            completion(true, nil)
        } else {
            //print("haven't discovered device yet")
            let error = NSError(domain: "", code: kDefaultErrorCode, userInfo: [NSLocalizedDescriptionKey : "haven't discovered device yet" ])
            completion(false, error)
        }
    }
}


// MARK: - CBCentralManagerDelegate Methods
extension MyBluetooth {
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        self.connectedPeripheral = nil
        print("Disconnected" + peripheral.name!)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //print("peripheral : \(peripheral)")
        //self.peripherals.removeAll()
        var peripheralsTMP:[CBPeripheral] = []
        if let name = peripheral.name { //, (!peripherals.contains(peripheral)) {
            print("peripheral name : ", name)
            peripheralsTMP.append(peripheral)
        }
        if peripheralsTMP.count > 0 {
            self.peripherals = peripheralsTMP
            self.delegate?.receivePeripherals?(peripherals: self.peripherals)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        connectedPeripheral = peripheral
        
        //pass reference to connected peripheral to parent view
        //parentView?.mainPeripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        //set the manager's delegate view to parent so it can call relevant disconnect methods
        manager?.delegate = self
        
        print("Connected to : " +  peripheral.name!)
        print("UUID identifier : \(peripheral.identifier)")
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print(error!)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print(central.state)
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
            break
          case .resetting:
            print("central.state is .resetting")
            break
          case .unsupported:
            print("central.state is .unsupported")
            break
          case .unauthorized:
            print("central.state is .unauthorized")
            break
          case .poweredOff:
            print("central.state is .poweredOff")
            break
          case .poweredOn:
            print("central.state is .poweredOn")
            //self.manager?.scanForPeripherals(withServices: [CBUUID.init(string: BLEService)], options: nil)
            //if you pass nil in the first parameter, then scanForPeriperals will look for any devices.
            self.manager?.scanForPeripherals(withServices: nil, options: nil)
            //stop scanning after 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                //self.stopScan()
            }
            
            break
        @unknown default:
            break
        }
    }
}

// MARK: CBPeripheralDelegate Methods
extension MyBluetooth {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        for service in peripheral.services! {
            
            print("Service found with UUID: " + service.uuid.uuidString)
            
            //device information service
            if (service.uuid.uuidString == "180A") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //GAP (Generic Access Profile) for Device Name
            // This replaces the deprecated CBUUIDGenericAccessProfileString
            if (service.uuid.uuidString == "1800") {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
            //Bluno Service
            if (service.uuid.uuidString == BLEService) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
            
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            //func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        //get device name
        if (service.uuid.uuidString == "1800") {
            for characteristic in service.characteristics! {
                if (characteristic.uuid.uuidString == "2A00") {
                    peripheral.readValue(for: characteristic)
                    print("Found Device Name Characteristic")
                }
            }
        }
        
        if (service.uuid.uuidString == "180A") {
            for characteristic in service.characteristics! {
                if (characteristic.uuid.uuidString == "2A29") {
                    peripheral.readValue(for: characteristic)
                    print("Found a Device Manufacturer Name Characteristic")
                } else if (characteristic.uuid.uuidString == "2A23") {
                    peripheral.readValue(for: characteristic)
                    print("Found System ID")
                }
            }
        }
        
        if (service.uuid.uuidString == BLEService) {
            
            for characteristic in service.characteristics! {
                
                if (characteristic.uuid.uuidString == BLECharacteristic) {
                    //we'll save the reference, we need it to write data
                    mainCharacteristic = characteristic
                    
                    //Set Notify is useful to read incoming data async
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("Found Bluno Data Characteristic")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.uuid.uuidString == "2A00") {
            //value for device name recieved
            let deviceName = characteristic.value
            print(deviceName ?? "No Device Name")
        } else if (characteristic.uuid.uuidString == "2A29") {
            //value for manufacturer name recieved
            let manufacturerName = characteristic.value
            print(manufacturerName ?? "No Manufacturer Name")
        } else if (characteristic.uuid.uuidString == "2A23") {
            //value for system ID recieved
            let systemID = characteristic.value
            print(systemID ?? "No System ID")
        } else if (characteristic.uuid.uuidString == BLECharacteristic) {
            //data recieved
            if(characteristic.value != nil) {
                if let stringValue = String(data: characteristic.value!, encoding: String.Encoding.utf8){
                    self.delegate?.dataRecieved?(message: stringValue)
                }
            }
        }
        
        
    }
    
}
