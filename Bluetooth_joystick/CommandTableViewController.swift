//
//  CommandTableViewController.swift
//  Bluetooth_joystick
//
//  Created by Hendra Wahyu on 5/2/17.
//  Copyright © 2017 Hendra Wahyu. All rights reserved.
//

import UIKit

class CommandTableViewController: UITableViewController, UITextFieldDelegate {
    
    //MARK: Text Field Properties
    @IBOutlet var textFieldCollection: [UITextField]!
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        //limit only characters 0 to 9
        let characterSetAllowed = CharacterSet(charactersIn: "0123456789").inverted
        
        //limit character count
        let newLength = text.characters.count + string.characters.count - range.length
        
        return newLength <= 3 && string.rangeOfCharacter(from: characterSetAllowed, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Saved Function
    //Set value text default into TextField
    let defaultArray = ["202", "201", "200", "203", "204", "205", "207", "208", "206", "209", "210"]
    var newArray = Array(repeating: "", count: 11)

    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Save", message: "Do you want to proceed?", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.saveTextField()
            self.performSegue(withIdentifier: "save-segue", sender: self)})
        let cancelAction = UIAlertAction(title: "Default", style: .cancel, handler: { (_) in
            self.defaultTextField()
            self.performSegue(withIdentifier: "save-segue", sender: self)})
        alert.addAction(OKAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveTextField(){
        let defaults = UserDefaults.standard
        
        for index in 0..<textFieldCollection.count {
            newArray[index] = textFieldCollection[index].text!
            defaults.set(newArray, forKey:"settingArray")
            textFieldCollection[index].resignFirstResponder()
        }
        defaults.synchronize()
        print(newArray)
    }
    
    func defaultTextField(){
        let defaults = UserDefaults.standard
        defaults.set(defaultArray, forKey: "settingArray")
        defaults.synchronize()
    }
    
    func addDoneOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        let flexspace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CommandTableViewController.doneButtonAction))
        var items = [UIBarButtonItem]()
        items.append(flexspace)
        items.append(done)
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        for textField in textFieldCollection {
            textField.inputAccessoryView = doneToolbar
        }
    }
    
    func doneButtonAction(){
        for textField in textFieldCollection {
            textField.resignFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addDoneOnKeyboard()
        
        for textField in textFieldCollection {
            textField.keyboardType = .numberPad         //set keyboard ONLY numpad
            textField.delegate = self                   //set each textfield to delegate update
        }
        
        let defaults = UserDefaults.standard
        let loadArray = defaults.stringArray(forKey: "settingArray")
        for index in 0..<textFieldCollection.count {
            textFieldCollection[index].text = loadArray?[index]
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Segue (
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save-segue" {
            let mainController: MainViewController = segue.destination as! MainViewController
            mainController.commandArray = UserDefaults.standard.stringArray(forKey: "settingArray")!
        }
    }
}
