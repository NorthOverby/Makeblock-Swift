//
//  MegaPiBot.swift
//  Makeblock
//
//  Created by North Overby on 12/27/16.
//  Copyright © 2016 Makeblock. All rights reserved.
//

import Foundation

public class MegaPiBot: MakeblockRobot {
    
    // available megapi motor/sensor ports
    public enum Port: UInt8 {
        case port1 = 1, port2 = 2, port3 = 3, port4 = 4 // encoder/stepper/dc motor ports
        case port5 = 5, port6 = 6, port7 = 7, port8 = 8 // RJ25 jack/sensor ports
        case port1B = 9, port2B = 10, port3B = 11, port4B = 12 //dc motor ports

        // dc motor port A aliases (note they just point to base port #)
        static var port1A = Port(rawValue: Port.port1.rawValue)!
        static var port2A = Port(rawValue: Port.port2.rawValue)!
        static var port3A = Port(rawValue: Port.port3.rawValue)!
        static var port4A = Port(rawValue: Port.port4.rawValue)!
    }
    
    /// TODO: double-check in firmware code - an enum of line-follower sensor status.
    public enum LineFollowerSensorStatus: Float {
        case leftBlackRightBlack=0.0, leftBlackRightWhite=1.0, leftWhiteRightBlack=2.0, leftWhiteRightWhite=3.0
    }
    
    /**
     Set the speed of a single dc motor
     
     - parameter port:  which port the motor is connect to
     - parameter speed: the speed of the motor -255~255
     */
    public func setMotor(port: Port, speed: Int){
        let (low, high) = IntToUInt8Bytes(speed)
        sendMessage(.dcMotor, arrayOfBytes: [port.rawValue, low, high])
    }
    
    /**
     Set the speed of both motors
     (uses "joystick" interface on firmware side)
     
     - parameter leftMotor:  speed of the left motor, -255~255
     - parameter rightMotor: speed of the right motor, -255~255
     */
    open func setMotors(leftMotor: Int, rightMotor: Int) {
        let (leftLow, leftHigh) = IntToUInt8Bytes(leftMotor)
        let (rightLow, rightHigh) = IntToUInt8Bytes(rightMotor)
        sendMessage(.dcMotorMove, arrayOfBytes: [leftLow, leftHigh, rightLow, rightHigh])
    }
    
    /**
     Tell the bot to move forward
     
     - parameter speed: the speed of moving. -255~255
     */
    open func moveForward(_ speed: Int){
        setMotors(leftMotor: -speed, rightMotor: speed)
    }
    
    /**
     Tell the bot to move backward
     
     - parameter speed: the speed of moving. -255~255
     */
    open func moveBackward(_ speed: Int){
        setMotors(leftMotor: speed, rightMotor: -speed)
    }
    
    /**
     Tell the bot to turn left
     
     - parameter speed: the speed of moving. -255~255
     */
    open func turnLeft(_ speed: Int){
        setMotors(leftMotor: speed, rightMotor: speed)
    }
    
    /**
     Tell the bot to turn right
     
     - parameter speed: the speed of moving. -255~255
     */
    open func turnRight(_ speed: Int){
        setMotors(leftMotor: -speed, rightMotor: -speed)
    }
    
    /**
     Tell the bot to stop moving
     */
    open func stopMoving(){
        setMotors(leftMotor: 0, rightMotor: 0)
    }
    
    /**
     Read the value of the ultrasonic sensor. and Call the callback when there's value returning
     usage:
     ```
     megaPiBot.getUltrasonicSensorValue() { value in
     print("ultrasonic sensor says \(value)")
     }
     ```
     
     - parameter port:     which port the sensor is connected to. By default .Port3
     - parameter callback: a block of code executed after we have a value. Receive a Float as the argument.
     */
    open func getUltrasonicSensorValue(_ port: Port = .port6, callback: @escaping ((Float) -> Void)) {
        sendMessage(.ultrasonicSensor, arrayOfBytes: [port.rawValue]) { value in
            callback(value.floatValue)
        }
    }
    
}
