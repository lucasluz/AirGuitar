//
//  BuyPairingViewController.swift
//  AirGuitar
//
//  Created by Lucas Luz on 03/03/17.
//  Copyright © 2017 Lucas Luz. All rights reserved.
//

import UIKit
import StoreKit
import AVKit
import AVFoundation

class BuyPairingViewController: UIViewController {
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // This list of available in-app purchases
    var products = [SKProduct]()
    
    @IBOutlet weak var iapTitle: UILabel!
    @IBOutlet weak var iapDescription: UILabel!
    @IBOutlet weak var iapBuyPrice: UIButton!
    @IBOutlet weak var iapRestore: UIButton!
    
    @IBOutlet weak var iapNotNow: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var watchVideo: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(BuyPairingViewController.purchasedNotification(_:)), name: NSNotification.Name(rawValue: IAPHelperProductPurchasedNotification), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BuyPairingViewController.btNotNow(_:)), name: NSNotification.Name(rawValue: "dismissView"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BuyPairingViewController.cancelPurchase(_:)), name: NSNotification.Name(rawValue: "cancelPurchase"), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        activityIndicator.startAnimating()
        self.iapBuyPrice.isHidden = true
        self.iapRestore.isHidden = true
        self.watchVideo.isHidden = true
        
        if(IAPHelper.canMakePayments()) {
            products = []
            Products.store.requestProductsWithCompletionHandler { success, products in
                if success {
                    self.products = products
                    self.iapTitle.text = products.first?.localizedTitle
                    self.iapDescription.text = products.first?.localizedDescription
                    self.iapBuyPrice.setTitle("Buy it for $\(products.first!.price.floatValue)", for: UIControlState())
                    
                    self.iapBuyPrice.isHidden = false
                    self.iapRestore.isHidden = false
                    self.watchVideo.isHidden = false
                    self.enableDisableButtons(true)

                } else {
                    let alert = UIAlertController(title: "Alert", message: "Request failed. Try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.dismiss(animated: true, completion: nil)}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            let alert = UIAlertController(title: "Alert", message: "Not available.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.dismiss(animated: true, completion: nil)}))
            self.present(alert, animated: true, completion: nil)
        }
        self.activityIndicator.stopAnimating()
        
    }
    
    @IBAction func btnBuyProduct(_ sender: UIButton) {
        self.enableDisableButtons(false)
        Products.store.purchaseProduct(products.first!)
    }
    
    @IBAction func btnRestoreProduct(_ sender: UIButton) {
        self.enableDisableButtons(false)
        Products.store.restoreCompletedTransactions()
    }
    
    func purchasedNotification(_ notification: Notification) {
        enableDisableButtons(true)
        
        let value = notification.userInfo!["product"] as! String
        
        if(value == Products.AppleWatchConnectivity) {
            performSegue(withIdentifier: "BuyToInfoSegue", sender: self)
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func cancelPurchase(_ notification: Notification) {
        let msg = notification.userInfo!["message"] as! String
        
        if(msg != "") {
            let alert = UIAlertController(title: "Alert", message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        enableDisableButtons(true)
    }
    
    @IBAction func playVideo(_ sender: UIButton) {
        let path = Bundle.main.path(forResource: "airguitarIPhone480", ofType:"mp4", inDirectory:"video")
        let player = AVPlayer(url: URL(fileURLWithPath: path!))
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        self.present(playerController, animated: true) {
            player.play()
        }
    }

    @IBAction func btNotNow(_ sender: UIButton) {
        enableDisableButtons(false)
        self.dismiss(animated: true, completion: nil)
    }
    
    func enableDisableButtons(_ enable : Bool) {
        self.iapBuyPrice.isEnabled = enable
        self.iapRestore.isEnabled = enable
        self.watchVideo.isEnabled = enable
        self.iapNotNow.isEnabled = enable
        
        if(enable) {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
