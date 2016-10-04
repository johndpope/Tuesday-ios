//
//  AppSettingsViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class AppSettingsViewController: UITableViewController {
    
    @IBOutlet weak var switchMessageNotification: UISwitch!
    @IBOutlet weak var switchAnalytics: UISwitch!
    let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialisationNotification()
        initialisationAnalytics()
    }
    
    func isNotificationAuthorized() -> Bool{
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            return appDelegate.isNotificationAuthorized()
        }
        return false
    }
    
    func initialisationNotification(){
        if (isNotificationAuthorized()){
            AWSManager.sharedInstance.getUser({ (user, userProfile) -> Void in
                if let isMessageNotification = userProfile?.isMessageNotification{
                    if isMessageNotification.boolValue {
                        self.switchMessageNotification.setOn(true, animated: false)
                        return
                    }
                }
                
                self.switchMessageNotification.setOn(false, animated: false)
            })
        }
        else {
            self.switchMessageNotification.setOn(false, animated: false)
        }
    }
    
    func initialisationAnalytics(){
        self.switchAnalytics.setOn(!FBSDKSettings.limitEventAndDataUsage(), animated: false)
    }
    
    /* UISwitch
    ------------------------------------------*/
    @IBAction func switchMessageNotification(sender: AnyObject) {
        if(isNotificationAuthorized()){
            if (!switchMessageNotification.on){
                let alertView = UIAlertController(title: "Warning".localized, message: "If you turn that off, you won't receive any notification when we organize your evening".localized, preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                    self.switchMessageNotification.setOn(true, animated: true)
                })
                let doAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                    
                    self.saveUserProfile()
                    
                })
                
                alertView.addAction(cancelAction)
                alertView.addAction(doAction)
                
                self.presentViewController(alertView, animated: true, completion: nil)
            }
                
            else{
                
                saveUserProfile()
                
            }
            
            
        }else{
            self.switchMessageNotification.setOn(false, animated: true)
            let alertView = UIAlertController(title: nil, message: "You must allow notifications in your settings".localized, preferredStyle: UIAlertControllerStyle.Alert)
            
            switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
            case .OrderedSame, .OrderedDescending:
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                })
                
                let doAction = UIAlertAction(title: "Let's do it!".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
                })
                
                alertView.addAction(cancelAction)
                alertView.addAction(doAction)
                break;
                
            default:
                let okAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                    
                })
                alertView.addAction(okAction)
                break;
            }
            
            self.presentViewController(alertView, animated: true, completion: nil)
        }
    }
    
    @IBAction func switchAnalytics(sender: AnyObject) {
        print("switchAnalytics \(switchAnalytics.on)");
        FBSDKSettings.setLimitEventAndDataUsage(!switchAnalytics.on)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.selected=false;
        switch (indexPath.section, indexPath.row){
        case (1,0):
            let alertView = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                self.switchMessageNotification.setOn(true, animated: true)
            })
            alertView.addAction(cancelAction)
            
            let action1 = UIAlertAction(title: "Terms".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("WebVC", sender: urls.TermsOfUse)
            })
            alertView.addAction(action1)
            
            let action2 = UIAlertAction(title: "Privacy".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("WebVC", sender: urls.PrivacyPolicy)
            })
            alertView.addAction(action2)
            
            let action3 = UIAlertAction(title: "About".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("WebVC", sender: urls.About)
            })
            alertView.addAction(action3)
            
            self.presentViewController(alertView, animated: true, completion: nil)
            
            break;
            
            
        case (2,0):
            self.view.makeToastActivity()
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate;
            appDelegate?.logoutAWS(self.view)
            break;
            
        default:
            return
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* Navigation
    ------------------------------------------*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "WebVC" ){
            if let dest = segue.destinationViewController as? WebViewController, url = sender as? String{
                dest.url = url
            }
        }
    }
    
    func saveUserProfile(){
        AWSManager.sharedInstance.getUser({ (user, userProfile) -> Void in
            if let userProfile = userProfile{
                
                let isMessageNotificationBool = self.switchMessageNotification.on
                userProfile.isMessageNotification = isMessageNotificationBool ? 1 : 0
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                dynamoDBObjectMapper.saveUpdateSkipNullAttributes(userProfile).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        if (isMessageNotificationBool){
                            
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            if let _ = AWSManager.sharedInstance.idFacebook, _ = userDefaults.objectForKey(NSUserDefaultsKey.DEVICE_TOKEN_KEY) as? NSData{
                                AWSManager.sharedInstance.registerForRemoteNotifications()
                            }
                            else{
                                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate;
                                appDelegate?.registerForRemoteNotifications()
                            }
                            
                        }
                    }
                    
                    return nil
                })
            }
            
        })
    }
}
