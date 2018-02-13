//
//  WebViewController.swift
//  RCControl
//
//  Created by Hendra Wahyu on 2/20/17.
//  Copyright © 2017 Hendra Wahyu. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class WebViewController: UIViewController {
//MARK: POST Request to a PHP Script
    var controller = controllerModel()
    let url: URL = URL(string:"http://10.1.1.1/remote_1.php")!
    let urlString = "http://10.1.1.1/download.php"
    
    @IBOutlet weak var videoContainer: UIView!
    
    
    //MARK: To get PSD Values
    @IBOutlet weak var psdValue: UILabel!
    
    
    @IBAction func segmentedControlView(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.5, animations: {
                self.imageView.alpha = 1
                self.videoContainer.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.imageView.alpha = 0
                self.videoContainer.alpha = 1
                let videoURL = URL(string: "http://10.1.1.1/myvid.mp4")
                if (videoURL != nil) {
                    let player = AVPlayer(url: videoURL!)
                    let playerLayer = AVPlayerLayer(player: player)
                    playerLayer.frame = self.videoContainer.bounds
                    self.videoContainer.layer.addSublayer(playerLayer)
                    player.play()
                    if sender.selectedSegmentIndex == 0 {
                        player.pause()
                    }
                }
            })
        }
    }
    
    @IBAction func webAction(_ sender: UIButton) {
        var request = URLRequest(url: url as URL)
        request.httpMethod =  "POST"            //GET can only be used once
        if let image = sender.currentImage {
            let action = controller.performWeb(image)
            request.httpBody = action.data(using: .utf8)
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(String(describing: error))")
                    return
                }
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode: \(httpStatus.statusCode)")
                    print("response: \(String(describing: response))")
                }
                let responseString = String(data: data, encoding: .utf8)
                print("responseString: \(String(describing: responseString))")
                if image.isEqual(UIImage(named: "blue_button")){
                    let imgURL = URL(string: "http://10.1.1.1/eye.jpg")
                    
                    //NOTE: Both working except with synchronous method, the loading is slow
                    //MARK: Synchronous Capture (alternative 2)
                    //let data = try? Data(contentsOf: imgURL!)
                    //self.imageView.image = UIImage(data: data!)
                    
                    //MARK: Asynchronous Capture
                    self.imageView.contentMode = .scaleAspectFit
                    self.downloadImage(url: imgURL!)
                }
                if image.isEqual(UIImage(named: "red_button")) {
                    do {
                        let displayPSD = try String(contentsOf: URL(string: self.urlString)!)
                        self.psdValue.text = displayPSD
                    } catch let error {
                        //error handling
                        print(error)
                    }
                }
            }
            task.resume()
        }
    }
    
//MARK: IMAGE upload and update from PHP
    @IBOutlet weak var imageView: UIImageView!

    func getDataFromURL(url: URL, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void){
        URLSession.shared.dataTask(with: url) {
            (data,response, error) in completion(data,response, error)
        }.resume()
    }
    
    func downloadImage(url: URL){
        print("Download image starting")
        getDataFromURL(url: url) { (data, response, error) in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() { () -> Void in
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
//MARK:
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = UIImage(named: "apple-logo")
    }
}

