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
    var firstPairing: Bool = false
    
    let imgGuitarModeOn = UIImage(named: "switch-on")
    let imgGuiterModeOff = UIImage(named: "switch-off")
    
    let imgNotPaired = UIImage(named: "new-apple-watch-logoOFF")
    let imgPaired = UIImage(named: "new-apple-watch-logoON")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pairingSpin.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(GuitarViewController.initSessionProcedure(_:)), name: NSNotification.Name(rawValue: "InitPairing"), object: nil)
    }
    
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidComplete \(session.isPaired)")
        print("activationState \(activationState)")
        
        if(!UserDefaults.standard.bool(forKey: "HasPairedOnce")) {
            UserDefaults.standard.set(true, forKey: "HasPairedOnce")
            UserDefaults.standard.synchronize()
            firstPairing = true
        }

        initSessionProcedure(session);
    }
    
    func initSessionProcedure(_ session: WCSession) {
        DispatchQueue.main.async {
            self.pairingSpin.isHidden = false
            self.pairingSpin.startAnimating()
            
            if(session.isPaired) {
                // connected
                self.btnPairWatch.setImage(self.imgPaired, for: UIControlState())
                self.isConnectedToWatch =  true
                self.sendMessageToWatch()
                
                if(self.firstPairing) {
                    self.firstPairing = false;
                    self.performSegue(withIdentifier: "GuitarToInfoSegue", sender: self)
                }
                
            } else {
                // not connected
                let alert = UIAlertController(title: "Alert", message: "Apple Watch is not paired", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            self.pairingSpin.isHidden = true
            self.pairingSpin.stopAnimating()
        }
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
            sender.setImage(imgNotPaired, for: UIControlState())
            
            sendMessageToWatch()
            
            return
        }
        
        if (WCSession.isSupported()) {
            let session = WCSession.default();
            session.delegate = self
            
            if(session.activationState == WCSessionActivationState.notActivated) {
                session.activate()
            } else {
                initSessionProcedure(session)
            }
            
            
            
            // wait for asynchronous pair
        }
    }
    
    func sendMessageToWatch() {
        let message = ["sendMsg":isConnectedToWatch as Bool]
        WCSession.default().sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("message received \(message)")
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
            stwGuitarMode.setImage(imgGuitarModeOn, for: .normal)
        } else {
            btnMinorChord.isEnabled = true
            stwGuitarMode.setImage(imgGuiterModeOff, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
