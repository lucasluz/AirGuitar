//
//  VideoViewController.swift
//  AirGuitar
//
//  Created by Lucas Luz on 03/03/17.
//  Copyright © 2017 Lucas Luz. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class VideoViewController: UIViewController {
    
    fileprivate var firstAppear = false
    var window: UIWindow?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstAppear {
            do {
                try playVideo()
                firstAppear = false
            } catch {
                print("Could not find resource")
            }
        }
        
        self.performSegue(withIdentifier: "VideoToGuitarSegue", sender: self)
    }
    
    fileprivate func playVideo() throws {
        let path = Bundle.main.path(forResource: "airguitarIPhone480", ofType:"mp4", inDirectory:"video")
        let player = AVPlayer(url: URL(fileURLWithPath: path!))
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        self.present(playerController, animated: true) {
            player.play()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.isHidden = true
        
        if(!UserDefaults.standard.bool(forKey: "HasLaunchedOnce")) {
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            firstAppear = true
            self.view.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
