//
//  ChatSettingsViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 22/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ChatSettingsViewController: UITableViewController {
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    @IBOutlet weak var switchMessageNotification: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialisationNotification()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
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
                if let isMessageNotificationChat = userProfile?.isMessageNotificationChat{
                    if isMessageNotificationChat.boolValue {
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
    
    /* UISwitch
    ------------------------------------------*/
    @IBAction func switchMessageNotification(sender: AnyObject) {
        
        if(isNotificationAuthorized()){
            if (!switchMessageNotification.on){
                let alertView = UIAlertController(title: "Warning".localized, message: "If you turn that off, you won't receive any notification when you receive a message".localized, preferredStyle: UIAlertControllerStyle.Alert)
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
    
    
    func saveUserProfile(){
        AWSManager.sharedInstance.getUser({ (user, userProfile) -> Void in
            if let userProfile = userProfile{
                
                let isMessageNotificationBool = self.switchMessageNotification.on
                userProfile.isMessageNotificationChat = isMessageNotificationBool ? 1 : 0
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
