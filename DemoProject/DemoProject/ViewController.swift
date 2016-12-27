//
//  ViewController.swift
//  DemoProject
//
//  Created by Wang Yu on 6/7/16.
//  Copyright © 2016 Makeblock. All rights reserved.
//

import UIKit
import Makeblock

var connection = BluetoothConnection()
var mBot = MBot(connection: connection)

class BluetoothDeviceTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    
}

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var deviceTableView: UITableView!
    var deviceList: [BluetoothDevice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        deviceTableView.dataSource = self;
        deviceTableView.delegate = self;
        connection.onAvailableDevicesChanged = { devices in
            if let bleDevices = devices as? [BluetoothDevice] {
                self.deviceList = bleDevices
                self.deviceTableView.reloadData()
            }
        }
        
        connection.onConnect = {
            self.performSegue(withIdentifier: "showDetails", sender: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let deviceCell = deviceTableView.dequeueReusableCell(withIdentifier: "deviceTableView", for: indexPath) as! BluetoothDeviceTableViewCell
        let device = deviceList[indexPath.row]
        deviceCell.nameLabel.text = "\(device.name) (\(device.distance))"
        return deviceCell
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = deviceList[indexPath.row]
        connection.connect(device)
    }
}

class DetailViewController: UIViewController {
    @IBOutlet weak var ultrasonicValue: UILabel!
    
    @IBAction func onDisconnect(_ sender: AnyObject) {
        connection.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onMoveForward(_ sender: AnyObject) {
        mBot.moveForward(255)
    }
    
    @IBAction func onStopMoving(_ sender: AnyObject) {
        mBot.stopMoving()
    }
    
    @IBAction func onRGBLED(_ sender: AnyObject) {
        mBot.setRGBLED(.all, red: 255, green: 0, blue: 0)
    }
    
    @IBAction func onBeepBuzzer(_ sender: AnyObject) {
        mBot.setBuzzer(.c4, duration: .half)
    }
    
    @IBAction func onUltrasonic(_ sender: AnyObject) {
        mBot.getUltrasonicSensorValue() { value in
            self.ultrasonicValue.text = "\(value)"
        }
    }
}

