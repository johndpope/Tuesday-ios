//
//  ThankReviewViewController.swift
//  Story
//
//  Created by Christopher Rydahl on 08/05/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ThankReviewViewController: UIViewController {
    
    var markReview: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @IBAction func buttonBackMenu(sender: AnyObject) {
        
        if markReview! >= 4{
            let alertView = UIAlertController(title: "We need you!".localized, message: "Would you like to support Tuesday on the App Store?".localized, preferredStyle: UIAlertControllerStyle.Alert)
            
            let laterAction = UIAlertAction(title: "Later".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
            
            let okAction = UIAlertAction(title: "Yeah, sure!".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                let urlAppStore = NSURL(string: "itms-apps://itunes.apple.com/app/id\(Params.APPLE_STORE_ID)")
                UIApplication.sharedApplication().openURL(urlAppStore!)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            })
            
            alertView.addAction(laterAction)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
            
        else{
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }

    }
    
}
