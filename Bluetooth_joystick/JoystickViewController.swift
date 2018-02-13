//
//  JoystickViewController.swift
//  RCControl
//
//  Created by Hendra Wahyu on 2/19/17.
//  Copyright © 2017 Hendra Wahyu. All rights reserved.
//

import UIKit
import SpriteKit
import CoreBluetooth

class JoystickViewController: UIViewController {
    var parentView:MainViewController!
    var manager: CBCentralManager?
    var connectedPeripheral: CBPeripheral?
    var lastCommand:String = ""
    var commandArray: [String] = []
    
    @IBOutlet weak var lightButton: UIButton!
    
    @IBOutlet weak var joystickController: joystickController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commandArray = UserDefaults.standard.stringArray(forKey: "settingArray")!
        print(commandArray)
        if connectedPeripheral == nil {
            lightButton.isEnabled = false
        } else { lightButton.isEnabled = true }
        
        joystickCommand()
        //NOTE: Only if we want to add view programmatically
        //addProgrammatically()
    }
    
    func joystickCommand() {
        //this function require configuration
        joystickController.trackingHandler = { joystickData in
            let velocity = (joystickData.velocity.x, joystickData.velocity.y)
            print(joystickData.velocity)
            switch velocity {
            case (-0.2265625..<0.2265625 , -1.0):
                if self.lastCommand == self.commandArray[3] { break }
                self.parentView.writeValue(UInt8( self.commandArray[3] )!)             //straight
                self.lastCommand = self.commandArray[3]
            case (-1.0, -1.0):
                if self.lastCommand == self.commandArray[9] { break }
                self.parentView.writeValue(UInt8( self.commandArray[9] )!)             //right forward
                self.lastCommand = self.commandArray[9]
            case (1.0, -0.2265625..<0.2265625):
                if self.lastCommand == self.commandArray[8] { break }
                self.parentView.writeValue(UInt8( self.commandArray[8] )!)             //right
                self.lastCommand = self.commandArray[8]
            case (-1.0, 1.0):
                if self.lastCommand == self.commandArray[10] { break }
                self.parentView.writeValue(UInt8( self.commandArray[10] )!)             //right reverse
                self.lastCommand = self.commandArray[10]
            case (-0.2265625..<0.2265625 , 1.0):
                if self.lastCommand == self.commandArray[4] { break }
                self.parentView.writeValue(UInt8( self.commandArray[4] )!)             //reverse
                self.lastCommand = self.commandArray[4]
            case (1.0, 1.0):
                if self.lastCommand == self.commandArray[7] { break }
                self.parentView.writeValue(UInt8( self.commandArray[7] )!)             //left reverse
                self.lastCommand = self.commandArray[7]
            case (-1.0, -0.2265625..<0.2265625):
                if self.lastCommand == self.commandArray[5] { break }
                self.parentView.writeValue(UInt8( self.commandArray[5] )!)             //left
                self.lastCommand = self.commandArray[5]
            case (1.0, -1.0):
                if self.lastCommand == self.commandArray[6] { break }
                self.parentView.writeValue(UInt8( self.commandArray[6] )!)             //left forward
                self.lastCommand = self.commandArray[6]
            default:
                self.parentView.writeValue(UInt8( self.commandArray[0] )!)             //stop position
                self.lastCommand = ""
            }
        }
    }
    
//MARK: Programmatically add view in JoystickViewController
    /*private func addProgrammatically() {
        // 1. Initialize an instance of `CDJoystick` using the constructor:
        let joystick = joystickController()
        joystick.frame = CGRect(x: 0 , y: 0 , width: 100, height: 100)
        joystick.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        
        // 2. Customize the joystick.
        joystick.substrateColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        joystick.substrateBorderColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
        joystick.substrateBorderWidth = 1.0
        joystick.stickSize = CGSize(width: 50, height: 50)
        joystick.stickColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        joystick.stickBorderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        joystick.stickBorderWidth = 2.0
        joystick.fade = 0.5
        
        view.addSubview(joystick)
    }*/
    
//MARK: Button Pressed
    var lightOn = false {
        didSet{
            if lightOn == true {
                parentView.writeValue(UInt8(self.commandArray[1] )!)
                let image = UIImage(named: "lightOn.png")
                lightButton.setImage(image, for: .normal)
            } else {
                parentView.writeValue(UInt8(self.commandArray[2] )!)
                let image = UIImage(named: "lightOff.png")
                lightButton.setImage(image, for: .normal)
            }
        }
    }
    
    @IBAction func lightButton(_ sender: UIButton) {
        lightOn = !lightOn
    }

    @IBAction func stopButton(_ sender: UIButton) {
        parentView.writeValue(UInt8 (self.commandArray[0] )!)
    }
    
}

extension JoystickViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print(central.state)
    }
    
}

