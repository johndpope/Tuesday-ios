//
//  ProblemLocationViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 18/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ProblemLocationViewController: PopUpViewController {
    
    @IBOutlet weak var doneButton: UIButton!
        
    
    @IBAction func doneButton(sender: AnyObject) {
        delegate?.popUpControllerDelegateViewControllerdidFinish(true)
        let authorizationStatus = CLLocationManager.authorizationStatus()
        print("authorizationStatus \(authorizationStatus)")
        if (isLocationAuthorized()){
            
        }else{
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
    }

    
    
    func isLocationAuthorized() -> Bool {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        print("authorizationStatus \(authorizationStatus)")
        if (authorizationStatus == CLAuthorizationStatus.Authorized || authorizationStatus == CLAuthorizationStatus.AuthorizedAlways || authorizationStatus == CLAuthorizationStatus.AuthorizedWhenInUse){
            return true
        }else{
            return false
        }
    }
}
