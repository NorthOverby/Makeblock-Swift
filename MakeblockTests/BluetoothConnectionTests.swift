 //
//  BluetoothConnectionTests.swift
//  Makeblock
//
//  Created by Wang Yu on 6/7/16.
//  Copyright © 2016 Makeblock. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Makeblock
import CoreBluetooth
 
class BluetoothDeviceTest: QuickSpec {
    override func spec() {
        describe("Bluetooth Connection") {
            it("can calculates RSSI") {
                let device = BluetoothDevice()
                device.RSSI = 5.0
                expect(device.distanceByRSSI() > 0.08).to(beTrue())
            }
            it("can discover peripherals") {
                let connection = BluetoothConnection();
                let mockCentralManager = MockCentralManager(delegate: connection, queue: DispatchQueue.main)
                var detectedDevices: [Device] = []
                connection.centralManager = mockCentralManager
                connection.startDiscovery()
                connection.onAvailableDevicesChanged = { devices in
                    detectedDevices = devices
                }
                mockCentralManager.testDiscoverPeripheralWithName("Makeblock_LE_3ed8")
                mockCentralManager.testDiscoverPeripheralWithName("Makeblock_LE_2e03")
                let deviceCount = detectedDevices.count
                expect(deviceCount == 2).to(beTrue())
            }
            it("can start, stop, and reset discovery") {
                let connection = BluetoothConnection();
                let mockCentralManager = MockCentralManager(delegate: connection, queue: DispatchQueue.main)
                connection.centralManager = mockCentralManager
                connection.startDiscovery()
                expect(mockCentralManager.testIsScanning).to(beTrue())
                connection.resetDiscovery()
                expect(mockCentralManager.testIsScanning).to(beTrue())
                connection.stopDiscovery()
                expect(!mockCentralManager.testIsScanning).to(beTrue())
            }
            it("can connect and disconnect to devices"){
                // somebody can help me write this test.
                // CBPeripheral will throw OutOfRange error when dealloc
                /*
                let connection = BluetoothConnection();
                let mockCentralManager = MockCentralManager(delegate: connection, queue: dispatch_get_main_queue())
                var detectedDevices: [Device] = []
                connection.centralManager = mockCentralManager
                connection.startDiscovery()
                connection.onAvailableDevicesChanged = { devices in
                    detectedDevices = devices
                }
                let peripheral = MockCBPeripheral.createInstance()
                peripheral.testServices = [MockCBPeripheral.Service(characteristics: ["FFE2", "FFE3"], UUID: "FFE1")]
                mockCentralManager.testDiscoverPeripheral(peripheral)
//                connection.connect(detectedDevices[0])
                */
            }
        }
    }
}
 
 
typealias MockCBPeripheralFactory = ObjectFactory<MockCBPeripheral>
typealias MockCBServiceFactory = ObjectFactory<MockCBService>
 typealias MockCBCharacteristicFactory = ObjectFactory<MockCBCharacteristic>

class MockCBCharacteristic: CBCharacteristic {
    var testUUID: CBUUID?
    
    override var uuid: CBUUID {
        get {
            return testUUID!
        }
    }
}
 
class MockCBService: CBService {
    var testUUID: CBUUID?
    var testCharacteristic: [CBCharacteristic] = []
    
    override var uuid: CBUUID {
        get {
            return testUUID!
        }
    }
    override var characteristics: [CBCharacteristic]? {
        get {
            return testCharacteristic
        }
    }
}
 
class MockCBPeripheral: CBPeripheral {
    var testName: String = ""
    
    struct Service {
        var characteristics: [String] = []
        var UUID: String = ""
    }
    
    var testServices: [Service] = []
    override var services: [CBService] {
        get {
            var cbServcies: [CBService] = []
            for testService in testServices {
                let service = MockCBServiceFactory.createInstance("MakeblockTests.MockCBService")
                service!.testUUID = CBUUID(string: testService.UUID)
                for testCharacteristic in testService.characteristics {
                    let char = MockCBCharacteristicFactory.createInstance("MakeblockTests.MockCBCharacteristic")
                    char?.testUUID = CBUUID(string: testCharacteristic)
                    service!.testCharacteristic.append(char!)
                }
                cbServcies.append(service!)
            }
            return cbServcies
        }
    }
    
    
    
    override var name: String {
        get {
            return testName
        }
        set {
            testName = newValue
        }
    }
    
    override func discoverServices(_ serviceUUIDs: [CBUUID]?) {
        if let uuids = serviceUUIDs {
            var testResult = false
            for uuid in uuids {
                for service in testServices {
                    if uuid.isEqual(CBUUID(string: service.UUID)) {
                        testResult = true
                        break
                    }
                }
            }
            if testResult {
                delegate?.peripheral!(self, didDiscoverServices: nil)
            }
        }
        else{
            delegate?.peripheral!(self, didDiscoverServices: nil)
        }
    }
    
    override func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: CBService) {
        
    }
    
    class func createInstance() -> MockCBPeripheral {
        let instance = MockCBPeripheralFactory.createInstance("MakeblockTests.MockCBPeripheral")
        return instance!
    }
    
}

class MockCentralManager: CBCentralManager {
    let readWriteServiceUUID = "FFE1"
    let readNotifyCharacteristicUUID = "FFE2"
    let writeCharacteristicUUID = "FFE3"
    let unrelatedServiceUUID = "FFE9"
    let unrelatedCharacteristicUUID = "FFEA"
    
    var testIsScanning = false
    var testDelegate: CBCentralManagerDelegate? = nil
    
    override init(delegate: CBCentralManagerDelegate?, queue: DispatchQueue?, options: [String : Any]?) {
        super.init(delegate: nil, queue: nil, options: nil)
        testDelegate = delegate
    }
    
    override func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?) {
        testIsScanning = true;
    }
    
    override func connect(_ peripheral: CBPeripheral, options: [String : Any]?) {
        testDelegate?.centralManager!(self, didConnect: peripheral)
    }
    
    func testDiscoverPeripheral(_ peripheral: MockCBPeripheral) {
        testDelegate?.centralManager!(self, didDiscover: peripheral, advertisementData: [:], rssi: 5.00)
    }
    
    func testDiscoverPeripheralWithName(_ name: String) {
        let peripheral = MockCBPeripheralFactory.createInstance("MakeblockTests.MockCBPeripheral")
        peripheral!.name = name
        testDiscoverPeripheral(peripheral!)
    }
    
    override func stopScan() {
        testIsScanning = false;
    }
    
    
}
