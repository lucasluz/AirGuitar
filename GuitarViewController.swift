//
//  GuitarViewController.swift
//  AirGuitar
//
//  Created by Lucas Luz on 03/03/17.
//  Copyright © 2017 Lucas Luz. All rights reserved.
//

import UIKit
import WatchConnectivity

class GuitarViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var btnMinorChord: UIButton!
    @IBOutlet weak var btnDChord: UIButton!
    @IBOutlet weak var btnCChord: UIButton!
    @IBOutlet weak var btnGChord: UIButton!
    @IBOutlet weak var btnBChord: UIButton!
    @IBOutlet weak var btnEChord: UIButton!
    @IBOutlet weak var btnAChord: UIButton!
    @IBOutlet weak var btnFChord: UIButton!
    @IBOutlet weak var btnPairWatch: UIButton!
    @IBOutlet weak var stwGuitarMode: UIButton!
    
    @IBOutlet weak var pairingSpin: UIActivityIndicatorView!
    
    var cp = ChordPlayer()
    var chordSelected : UIButton!
    var minorSelected : Bool = false
    var isConnectedToWatch: Bool = false
    var eletricGuitar: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(GuitarViewController.purchasedNotification(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
        
        if(UserDefaults.standard.bool(forKey: Products.AppleWatchConnectivity)) {
            stwGuitarMode.isHidden = false
        }
    }
    
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidComplete \(session.isPaired)")
        print("adc \(activationState)")

        initSessionProcedure(session);
    }
    
    func initSessionProcedure(_ session: WCSession) {
        pairingSpin.isHidden = false
        pairingSpin.startAnimating()
        
        if(session.isPaired) {
            
            if(UserDefaults.standard.bool(forKey: Products.AppleWatchConnectivity)) {
                // connected
                let image = UIImage(named: "new-apple-watch-logoON")
                btnPairWatch.setImage(image, for: UIControlState())
                
                isConnectedToWatch =  true
                stwGuitarMode.isHidden = false
                
            } else {
                self.performSegue(withIdentifier: "GuitarToBuySegue", sender: self)
            }
            
        } else {
            // not connected
            let alert = UIAlertController(title: "Alert", message: "Apple Watch is not paired", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        pairingSpin.isHidden = true
        pairingSpin.stopAnimating()
    }
    
    
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        print("didreceive")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        print("statedidchange")
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        print("didbecomeinactive")
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
        print("sessiondiddeactivate")
        session.activate()
    }
    
    @IBAction func btnChordSelect(_ sender: UIButton) {
        chordSelected = sender
        
        if(!isConnectedToWatch) { playCurrentChord() }
    }
    
    @IBAction func btnMinorChordSelect(_ sender: UIButton) {
        minorSelected = true
    }
    
    @IBAction func btnMinorChordDeselect(_ sender: UIButton) {
        minorSelected = false
    }
    
    @IBAction func btnChordUp(_ sender: UIButton) {
        chordSelected = nil
    }

    @IBAction func btnPairWatch(_ sender: UIButton) {
        // if it's paired, disconnect
        if(isConnectedToWatch) {
            isConnectedToWatch = false
            let image = UIImage(named: "new-apple-watch-logoOFF")
            sender.setImage(image, for: UIControlState())
            
            return
        }
        
        if (WCSession.isSupported()) {
            if(IAPHelper.canMakePayments()) {
                let session = WCSession.default();
                session.delegate = self
                
                if(session.activationState == WCSessionActivationState.notActivated) {
                    session.activate()
                } else {
                    initSessionProcedure(session)
                }
                
                // wait for asynchronous pair
                
            } else {
                let alert = UIAlertController(title: "Alert", message: "Feature not available", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("message received \(message)")
        playCurrentChord()
    }
    
    func playCurrentChord() {
        if(chordSelected != nil) {
            DispatchQueue.main.async {
                self.cp.playChord(self.chordSelected.titleLabel!.text! as String + (self.minorSelected ? "m" : ""), eletric: self.eletricGuitar)
            }
        }
    }
    
    @IBAction func btnSwitchGuitarMode(_ sender: UIButton) {
        eletricGuitar = !eletricGuitar
        
        if(eletricGuitar) {
            btnMinorChord.isEnabled = false
            
            let image = UIImage(named: "switch-on")
            stwGuitarMode.setImage(image, for: .normal)
        } else {
            btnMinorChord.isEnabled = true
            
            let image = UIImage(named: "switch-off")
            stwGuitarMode.setImage(image, for: .normal)
        }
    }


    func purchasedNotification(_ notification: Notification) {
        pairingSpin.isHidden = false
        pairingSpin.startAnimating()
        
        let value = notification.userInfo!["product"] as! String
        
        if(value == Products.AppleWatchConnectivity) {
            // connected
            let image = UIImage(named: "new-apple-watch-logoON")
            btnPairWatch.setImage(image, for: UIControlState())
            
            isConnectedToWatch =  true
            stwGuitarMode.isHidden = false
        } else {
            // not connected
            let image = UIImage(named: "new-apple-watch-logoOFF")
            btnPairWatch.setImage(image, for: UIControlState())
            
            isConnectedToWatch =  false
        }
        
        pairingSpin.isHidden = true
        pairingSpin.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
