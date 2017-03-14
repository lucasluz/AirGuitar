//
//  InstructionsViewController.swift
//  AirGuitar
//
//  Created by Lucas Luz on 03/03/17.
//  Copyright © 2017 Lucas Luz. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnOk(_ sender: UIButton) {
        performSegue(withIdentifier: "InfoToGuitarSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
