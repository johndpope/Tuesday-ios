//
//  SettingsViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 07/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var profilImage: AWSImageView!
    @IBOutlet weak var profilLabel: UILabel!
    
    var mailComposeViewController = MFMailComposeViewController();
    
    @IBOutlet weak var nbCreditsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
                                        if let nbCredits = userCredits.objectForKey("nbCredits")?.integerValue{
                                            self.nbCreditsLabel.text = "\(nbCredits + nbCreditsLiked)"
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
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let currentUser = user {
                
                self.profilImage.setProfilePicture(currentUser)
                
                var profilLabelText = ""
                if let firstName = currentUser.firstName{
                    profilLabelText = firstName
                }
                self.profilLabel.text = profilLabelText
            }
        }
        
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        
        switch (indexPath.section, indexPath.row){
        case (1,2):
            self.buttonEmail("I am really motivated to become an ambassador and I think I can bring a lot of new members because...".localized, subject: "I want to become an ambassador".localized, recipients: [Params.EMAIL_AMBASSADOR])
            break;
            
        case (2,0):
            contactUsButton(self)
            break;
        default:
            break;
        }
    }
    
    func contactUsButton(sender: AnyObject) {
        let alertView = UIAlertController(title: "Contact us".localized, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
        })
        
        let action1 = UIAlertAction(title: "Partnership".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
            self.buttonEmail("", subject: "Partnership".localized, recipients: [Params.EMAIL_PARTNERSHIP])
        })
        
        let action2 = UIAlertAction(title: "Bug".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
            self.buttonEmail("", subject: "Bug iOS".localized, recipients: [Params.EMAIL_BUG_IOS])
        })
        
        alertView.addAction(cancelAction)
        alertView.addAction(action1)
        alertView.addAction(action2)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func buttonEmail(body: String, subject:String, recipients: [String]?) {
        if (MFMailComposeViewController.canSendMail()) {
            //self.tableView.makeToastActivity()
            mailComposeViewController = MFMailComposeViewController()
            
            mailComposeViewController.setMessageBody(body, isHTML: false)
            mailComposeViewController.setToRecipients(recipients)
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.mailComposeDelegate = self;
            
            self.presentViewController(mailComposeViewController, animated: true, completion:nil);
        }
        else{
            self.view.makeToast("Your device cannot send email".localized, duration: 2.0, position: "center")
        }
    }
    
    // MARK - MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch(result.rawValue){
        case MFMailComposeResultCancelled.rawValue:
            break;
        case MFMailComposeResultSent.rawValue:
            self.view.makeToast("Email successfully sent".localized, duration: 2.0, position: "center")
            break;
        case MFMailComposeResultSaved.rawValue:
            self.view.makeToast("Email successfully saved".localized, duration: 2.0, position: "center")
            break;
        case MFMailComposeResultFailed.rawValue:
            self.view.makeToast("An error occured".localized, duration: 2.0, position: "center")
            break;
        default:
            break;
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
