//
//  MakeblockRobotTest.swift
//  Makeblock
//
//  Created by Wang Yu on 6/13/16.
//  Copyright © 2016 Makeblock. All rights reserved.
//

import Foundation
import Quick
import Nimble
@testable import Makeblock

class MockConnection: Connection {
    var onConnect: (() -> Void)?
    var onDisconnect: (() -> Void)?
    var onReceive: ((Data) -> Void)?
    var onAvailableDevicesChanged: (([Device]) -> Void)?
    var sentBytes: [UInt8] = []
    
    func startDiscovery() { }
    func stopDiscovery() { }
    func connect(_ device: Device) { }
    func connectDefaultDevice() { }
    func disconnect() { }
    func send(_ data: Data) {
        let count = data.count / MemoryLayout<UInt8>.size
        
        // create an array of Uint8
        var array = [UInt8](repeating: 0, count: count)
        
        // copy bytes into array
        (data as NSData).getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        sentBytes.append(contentsOf: array);
    }
    
    func testReceiveBytes(_ bytes:[UInt8]) {
        if let onrecv = onReceive {
            onrecv(Data(bytes: UnsafePointer<UInt8>(bytes), count: bytes.count))
        }
    }
}

class MakeblockRobotTest: QuickSpec {
    override func spec() {
        describe("SensorValue") {
            it("can receive int value") {
                let value = SensorValue(intValue: 15)
                expect(value.intValue == 15).to(beTrue())
            }
            it("can receive float value") {
                let value = SensorValue(floatValue: 12.3)
                expect(value.floatValue == 12.3).to(beTrue())
            }
            it("can receive string value") {
                let value = SensorValue(string: "hello")
                expect("hello" == value.stringValue).to(beTrue())
            }
        }
        
        describe("ReadSensorRequest") {
            it("can test whether request date is expeired") {
            }
        }
        
        describe("MakeblockRobot") {
            it("can write message to a connection"){
                let conn = MockConnection()
                let robot = MakeblockRobot(connection: conn)
                robot.sendMessage(.dcMotor, arrayOfBytes: [0x09, 0x0a, 0x00])
                // index of write messages are forever 0x01
                let expectedMessage: [UInt8] = [0xff, 0x55, 0x06, 0x01, 0x02, 0x0a, 0x09, 0x0a, 0x00]
                expect(expectedMessage == conn.sentBytes).to(beTrue())
            }
            
            it("can read float values from a connection"){
                let conn = MockConnection()
                let robot = MakeblockRobot(connection: conn)
                var hasValue = false
                let index = robot.sendMessage(.lightnessSensor, arrayOfBytes: [0x0b]) { value in
                    expect(value.floatValue == 305).to(beTrue())
                    hasValue = true
                }
                conn.testReceiveBytes([0xff, 0x55, index, 0x02, 0x00, 0x80, 0x98, 0x43, 0x0d, 0x0a])
                expect(hasValue).to(beTrue())
            }
            
            it("can read string values from sensors"){
                
            }
            
            it("can read int values from sensors"){
                
            }
        }
    }
}
