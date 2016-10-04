//
//  LikeUsOnFacebookViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 23/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class LikeUsOnFacebookViewController: UITableViewController {
    
    @IBOutlet weak var supportSwitch: UISwitch!
    var hasGrantedUserLikes = false
    var titleFooter: String?
    
    var userCredits: AWSUserCredits?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (FBSDKAccessToken.currentAccessToken().hasGranted("user_likes")){
            hasGrantedUserLikes = true
        }
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateDisplay()
    }
    
    func updateDisplay(){
        if let idFacebook = AWSManager.sharedInstance.idFacebook {
            
            let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
            let jsonObject: [String:String] = [
                "idUser": idFacebook
            ]
            
            lambdaInvoker.invokeFunction("AWSgetNbCredits", JSONObject: jsonObject).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                
                print("task.result \(task.result)")
                print("exception \(task.exception)")
                print("error \(task.error)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let result = task.result as? NSDictionary {
                        if let isOk = result.objectForKey("isOk") as? Bool {
                            if isOk {
                                dispatch_async(dispatch_get_main_queue()) {
                                    if let userCredits = result.objectForKey("userCredits") as? NSDictionary, nbCreditsLiked = result.objectForKey("nbCreditsLiked") as? Int{
                                        
                                        if let dateLikeFacebookPage = userCredits.objectForKey("dateLikeFacebookPage") as? String{
                                            
                                            self.supportSwitch.on = true
                                            
                                            if let date = dateLikeFacebookPage.getDateYYYYMMdd(){
                                                
                                                let fmt = NSDateFormatter()
                                                fmt.dateStyle = NSDateFormatterStyle.FullStyle
                                                fmt.timeStyle = NSDateFormatterStyle.NoStyle
                                                self.titleFooter = "You have been supporting us since %@ and have won %d Credit(s).".localizedStringWithVariables(fmt.stringFromDate(date), nbCreditsLiked)
                                                self.tableView.reloadData()
                                                
                                            }
                                        }
                                            
                                        else{
                                            self.supportSwitch.on = false
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                }
                return nil
                
            })
            
            
        }
    }
    
    
    @IBAction func detailButton(sender: AnyObject) {
        let alertView = UIAlertController(title: nil, message: "If you like our page on Facebook, you will be given 1 free credit each week.".localized, preferredStyle: UIAlertControllerStyle.Alert)
        let doAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
        })
        
        alertView.addAction(doAction)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func supportSwitch(sender: AnyObject) {
        if (self.supportSwitch.on){
            
            self.view.makeToastActivity()
            FacebookManager.sharedInstance.refreshLike { (error) -> Void in
                self.view.hideToastActivity()
                
                if (!FacebookManager.sharedInstance.isLikingFacebookPage){
                    
                    self.supportSwitch.on = false
                    
                    let alertView = UIAlertController(title: nil, message: "You didn't like our page on Facebook. Would you like to support us now?".localized, preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let cancelAction = UIAlertAction(title: "Not now".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                        
                    })
                    alertView.addAction(cancelAction)
                    
                    let doAction = UIAlertAction(title: "Sure".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                        
                        self.openFacebookPage()
                        
                    })
                    alertView.addAction(doAction)
                    self.presentViewController(alertView, animated: true, completion: nil)
                    
                }
                    
                else{
                    self.didLikeUsOnFacebook(true)
                }
            }
            
        }
        
        else{
            
            let alertView = UIAlertController(title: "".localized, message: "Are you sure you don't want to support us anymore ?".localized, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                self.supportSwitch.setOn(true, animated: true)
            })
            let doAction = UIAlertAction(title: "I am sure".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                self.didLikeUsOnFacebook(false)
            })
            
            alertView.addAction(cancelAction)
            alertView.addAction(doAction)
            
            self.presentViewController(alertView, animated: true, completion: nil)
            
        }
    }
    
    func didLikeUsOnFacebook(isPageLiked: Bool){
        if let idFacebook = AWSManager.sharedInstance.idFacebook {
            
            let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
            let jsonObject = [
                "idUser": idFacebook,
                "isPageLiked": isPageLiked
            ]
            lambdaInvoker.invokeFunction("AWSdidLikeUsOnFacebook", JSONObject: jsonObject).continueWithBlock { (task:AWSTask) -> AnyObject? in
                
                print("lambdaInvoker result: \(task.result)");
                print("lambdaInvoker exception: \(task.exception)");
                print("lambdaInvoker error: \(task.error)");
                dispatch_async(dispatch_get_main_queue()) {
                    if let _ = task.result as? NSDictionary {
                        self.updateDisplay()
                    }
                }
                return nil
            }
        }
    }
    
    
    func openFacebookPage() {
        if let facebookURL = NSURL(string: "fb://profile/\(Params.FACEBOOK_PAGE_ID)"){
            print("facebookURL \(facebookURL)")
            if (UIApplication.sharedApplication().canOpenURL(facebookURL)) {
                UIApplication.sharedApplication().openURL(facebookURL);
                return;
            }
        }
        
        UIApplication.sharedApplication().openURL(NSURL(string: "http://facebook.com")!);
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == 0){
            return titleFooter
        }else{
            return nil
        }
    }
    
}
