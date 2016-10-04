//
//  WelcomeViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 14/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class WelcomeViewController: PopUpViewController {
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func doneButton(sender: AnyObject) {
        
        delegate?.popUpControllerDelegateViewControllerdidFinish(true)
        
    }
}