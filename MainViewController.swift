//
//  MainViewController.swift
//  Bluetooth_joystick
//
//  Created by Hendra Wahyu on 3/5/17.
//  Copyright © 2017 Hendra Wahyu. All rights reserved.
//
import UIKit
import CoreBluetooth

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    //initialise bluetooth and display table View outlet
    var manager: CBCentralManager? = nil
    var connectedPeripheral: CBPeripheral? = nil
    var writeData: CBCharacteristic? = nil
    var commandArray: [String] = []
    private var controller = controllerModel()
    
    //unwind from Command Table setting
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    //return information speed and angle in percentage
    @IBOutlet weak var speedField: UILabel!
    @IBOutlet weak var angleField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager = CBCentralManager(delegate: self, queue: nil)
        customiseNavigationBar()
        lightButton.isEnabled = false
        if commandArray.isEmpty {
            savedArray()
            commandArray = UserDefaults.standard.stringArray(forKey: "settingArray")!
            print(commandArray)
        } else {
            commandArray = UserDefaults.standard.stringArray(forKey: "settingArray")!
            print(commandArray)
        }
    }
    
    func savedArray(){
        let commandArray = ["202", "201", "200", "203","204", "205", "207", "208", "206", "209", "210"]
        let defaults = UserDefaults.standard
        defaults.set(commandArray, forKey: "settingArray")
    }
    
    //prepare function for segueing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "scan-segue"{
            let scanController : ScanTableViewController = segue.destination as! ScanTableViewController
            
            //set the manager's delegate to the scan view so it can call relevant connection methods
            manager?.delegate = scanController
            scanController.manager = manager
            scanController.parentView = self
        }
        if segue.identifier == "joystick-segue"{
            let joystickController : JoystickViewController = segue.destination as! JoystickViewController
            
            //set the manager's delegate to the scan view so it can call relevant connection methods
            manager?.delegate = joystickController
            joystickController.manager = manager
            joystickController.connectedPeripheral = connectedPeripheral
            joystickController.parentView = self
            joystickController.commandArray = commandArray
        }
    }
    
    
//MARK: Action and Outlet Button
    //MARK: LIGHT
    @IBOutlet weak var lightButton: UIButton!
    
    var lightOn = false {
        didSet {
            if lightOn == false {
                let image = UIImage(named: "lightOff.png")
                lightButton.setImage(image, for: .normal)
                writeValue(UInt8( commandArray[2] )!)
            } else {
                let image = UIImage(named: "lightOn.png")
                lightButton.setImage(image, for: .normal)
                writeValue(UInt8( commandArray[1] )!)
            }
        }
    }
    
    //send action to connected bluetooth
    @IBAction func lightButton(_ sender: UIButton) {
            lightOn = !lightOn
    }
    
    //MARK: ACTION BUTTON
    //send action to action button in view controller
    //variable of each button is assigned to dictionary Controller Model
    
    @IBAction func actionButton(_ sender: UIButton) {
        if connectedPeripheral != nil {
            if let image = sender.currentImage {
                let actionInteger = controller.performAction(image)
                writeValue(UInt8(actionInteger)!)
                if image.isEqual(UIImage(named: "button_dir_up_0")){
                    if speedValue < 80 {
                        speedValue += 30
                    }
                } else if image.isEqual(UIImage(named: "button_dir_down_0")){
                    if speedValue > -80 {
                        speedValue -= 30
                    }
                }
                if image.isEqual(UIImage(named: "button_dir_left_0")){
                    if angleValue > -80 {
                        angleValue -= 30
                    }
                } else if image.isEqual(UIImage(named: "button_dir_right_0")){
                    if angleValue < 80 {
                        angleValue += 30
                    }
                }
                if image.isEqual(UIImage(named: "red_button")) || image.isEqual(UIImage(named: "blue_button")) {
                    speedValue = 0
                    angleValue = 0
                }
            }
        }
        else {
            speedValue = 0
            angleValue = 0
        }
    }
    
//MARK: display speed and angle rotation
    var speedValue: Int {
        get {
            return Int(speedField.text!)!
        }
        set {
            speedField.text = String(newValue)
        }
    }
    
    var angleValue: Int {
        get {
            return Int(angleField.text!)!
        }
        set {
            angleField.text = String(newValue)
        }
    }
    
//MARK: Segueing buttons
    @IBAction func segueButton(_ sender: UIButton) {
        if let image = sender.currentImage {
            let segueIdentifier = controller.fireSegue(image)
            if segueIdentifier == "joystick-segue" {
                performSegue(withIdentifier: "joystick-segue", sender: nil)
            }
            if segueIdentifier == "raspberry-segue" {
                performSegue(withIdentifier: "raspberry-segue", sender: nil)
            }
        }
    }
    
//MARK: Navigation button bar
    func customiseNavigationBar () {
        
        self.navigationItem.rightBarButtonItem = nil            //right button
        self.navigationItem.leftBarButtonItem = nil
        let rightButton = UIButton()
        let leftButton = UIButton()
        
        //right button
        if (connectedPeripheral == nil) {
            rightButton.setTitle("Scan", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 60, height: 30))
            rightButton.addTarget(self, action: #selector(self.scanButtonPressed), for: .touchUpInside)
        } else {
            rightButton.setTitle("Disconnect", for: [])
            rightButton.setTitleColor(UIColor.blue, for: [])
            rightButton.frame = CGRect(origin: CGPoint(x: 0,y :0), size: CGSize(width: 100, height: 30))
            rightButton.addTarget(self, action: #selector(self.disconnectButtonPressed), for: .touchUpInside)
        }
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = rightButton
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        //left button
        leftButton.setImage(UIImage(named: "gear"), for: .normal)
        leftButton.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 32, height: 32))
        leftButton.addTarget(self, action: #selector(self.settingCommand), for: .touchUpInside)
        
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = leftButton
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
// MARK: Navigation Bar Button
    func scanButtonPressed() {
        performSegue(withIdentifier: "scan-segue", sender: nil)
    }

    func disconnectButtonPressed() {
        //this will call didDisconnectPeripheral, but if any other apps are using the device it will not immediately disconnect
        manager?.cancelPeripheralConnection(connectedPeripheral!)
    }
    
    func settingCommand(){
        performSegue(withIdentifier: "gear-segue", sender: nil)
    }
    
    
//MARK: CBCentralManagerDelegate
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        customiseNavigationBar()
        lightButton.isEnabled = false
        print("Disconnected" + peripheral.name!)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
//MARK: CBPeripheralDelegate
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripherals = peripheral.services as [CBService]!{
            for service in servicePeripherals{
                peripheral.discoverCharacteristics(nil, for: service)
                print("Discovered service: \(service.uuid)")
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characterArray = service.characteristics as [CBCharacteristic]!{
            for cc in characterArray {
                if cc.uuid.uuidString == "FFE1" || cc.uuid.uuidString == "180A" {
                    //retrieves the value of a specified characteristic descriptor
                    //of peripheral and when it is successfully retrieved, user can
                    //access through characteristic descriptor's value property
                    peripheral.readValue(for: cc)
                    print("Discovered characteristic: \(cc.uuid)")
                }
                if cc.properties.contains(.write) || cc.properties.contains(.writeWithoutResponse){
                    writeData = cc
                }
                peripheral.setNotifyValue(true, for: cc)
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid.uuidString == "FFE1" || characteristic.uuid.uuidString == "180A" {
            if characteristic.value != nil {
                self.writeData = characteristic
                connectedPeripheral?.setNotifyValue(true, for: characteristic)
            }
        }
    }

//MARK: Write Data to connected Peripheral / Time Delay
    func writeValue(_ value: UInt8) {
        guard let peripheral = connectedPeripheral else { return }
        if let data = self.writeData {
            let write = Data(bytes: [value])
            peripheral.writeValue(write, for: data, type: .withoutResponse)
        }
    }
    
}


