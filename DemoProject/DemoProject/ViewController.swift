//
//  ViewController.swift
//  DemoProject
//
//  Created by Wang Yu on 6/7/16.
//  Copyright © 2016 Makeblock. All rights reserved.
//

import UIKit
import Makeblock
import Speech

var connection = BluetoothConnection()
var megaPiBot = MegaPiBot(connection: connection)


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
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                print("Speech authorization allowed")
            default:
                print("Speech authorization not allowed")
            }
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

class DetailViewController: UIViewController, SFSpeechRecognizerDelegate {
    @IBOutlet weak var ultrasonicValue: UILabel!
    @IBOutlet weak var voiceCommandButton: UIButton!
    @IBOutlet weak var armUpButton: UIForceTouchButton!
    @IBOutlet weak var armDownButton: UIForceTouchButton!
    @IBOutlet weak var forwardButton: UIForceTouchButton!
    @IBOutlet weak var backwardButton: UIForceTouchButton!
    @IBOutlet weak var clampButton: UIForceTouchButton!
    @IBOutlet weak var unclampButton: UIForceTouchButton!
    
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        setupForceTouchButtonHandlers()
    }
    
    @IBAction func onDisconnect(_ sender: AnyObject) {
        connection.disconnect()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onStopMoving(_ sender: AnyObject) {
        megaPiBot.stopMoving()
    }
    
    @IBAction func onUltrasonic(_ sender: AnyObject) {
        megaPiBot.getUltrasonicSensorValue() { value in
            self.ultrasonicValue.text = "\(value)"
        }
    }
    
    @IBAction func onVoiceCommandRecord(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            voiceCommandButton.isEnabled = false
            voiceCommandButton.setTitle("Voice command", for: .normal)
        } else {
            startRecording()
            voiceCommandButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                if let recognizedText = result?.bestTranscription.formattedString {
                    print("you said: \(recognizedText)")
                    if recognizedText.lowercased().contains("forward") {
                        megaPiBot.moveForward(128)
                    } else if recognizedText.lowercased().contains("backwards") {
                        megaPiBot.moveBackward(128)
                    } else if recognizedText.lowercased().contains("stop") {
                        megaPiBot.stopMoving()
                    }
                }
                print(result?.bestTranscription.formattedString ?? "can't tell what you said")
                
                //self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.voiceCommandButton.isEnabled = true
                //self.microphoneButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            voiceCommandButton.isEnabled = true
        } else {
            voiceCommandButton.isEnabled = false
        }
    }
}

extension DetailViewController {
    fileprivate func setupForceTouchButtonHandlers() {
        // movement forward/backward
        forwardButton.onForceTouchPressureChanged = { (force) in
            megaPiBot.moveForward(Int(255 * force))
        }
        
        backwardButton.onForceTouchPressureChanged = { (force) in
            megaPiBot.moveBackward(Int(255 * force))
        }
        
        // arm up/down
        armUpButton.onForceTouchPressureChanged = { (force) in
            megaPiBot.setEncoderMotorPWM(port: .port3, speed: Int(255 * force))
        }
        
        armDownButton.onForceTouchPressureChanged = { (force) in
            megaPiBot.setEncoderMotorPWM(port: .port3, speed: Int(-255 * force))
        }
        
        // clamp / unclamp
        unclampButton.onForceTouchPressureChanged = { (force) in
            let speed = force == 0 ? 0 : clamp(value: Int(force * -255), lower: -170, upper: -50)
            megaPiBot.setMotor(port: .port4B, speed: speed)
        }
        
        clampButton.onForceTouchPressureChanged = { (force) in
            let speed = force == 0 ? 0 : clamp(value: Int(force * 255), lower: 50, upper: 170)
            megaPiBot.setMotor(port: .port4B, speed: speed)
        }
    }
}

