//
//  ControllerModel.swift
//  Bluetooth_joystick
//
//  Created by Hendra Wahyu on 3/8/17.
//  Copyright © 2017 Hendra Wahyu. All rights reserved.
//

import Foundation
import UIKit

class controllerModel {
    var commandArray: [String] = []
    var symbolTable: [UIImage : String] = [:]
    let defaultArray = ["202", "201", "200", "203", "204", "205", "207", "208", "206", "209", "210"]
    
    func putIntoDictionary() -> [UIImage : String] {
        let defaults = UserDefaults.standard
        defaults.set(defaultArray, forKey: "settingArray")
        commandArray = UserDefaults.standard.stringArray(forKey: "settingArray")!
        //MARK: Bluetooth D-PAD
        let table: Dictionary<UIImage, String > = [
            UIImage(named: "red_button")!: commandArray[0],
            UIImage(named: "button_dir_up_0")!: commandArray[3],
            UIImage(named: "button_dir_down_0")!: commandArray[4],
            UIImage(named: "button_dir_left_0")!: commandArray[5],
            UIImage(named: "button_dir_right_0")!: commandArray[6]
        ]
        return table
    }
    
    func performAction(_ symbol: UIImage) -> String {
        symbolTable = putIntoDictionary()
        let action = symbolTable[symbol]
        return action!
    }
    
    //MARK: Raspberry D-PAD
    private var webTable: Dictionary<UIImage, String> = [
        UIImage(named: "blue_button")!: "remote=capture",
        UIImage(named: "record_button")!: "remote=video",
        UIImage(named: "up")!: "remote=forward",
        UIImage(named: "down")!: "remote=reverse",
        UIImage(named: "left")!: "remote=left",
        UIImage(named: "right")!: "remote=right",
        UIImage(named: "red_button")!: "remote=psdSensor"
    ]
    
    func performWeb(_ symbol: UIImage) -> String {
        let webAction = webTable[symbol]
        return webAction!
    }
    
    //MARK: Segueing Button
    private var segueTable: Dictionary<UIImage, String> = [
        UIImage(named: "raspberrypi")!: "raspberry-segue",
        UIImage(named: "joystick")!: "joystick-segue"
    ]
    
    func fireSegue(_ img: UIImage) -> String {
        let segueIdentifier = segueTable[img]
        return segueIdentifier!
    }
    
}
