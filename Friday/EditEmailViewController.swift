//
//  EditEmailViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 19/10/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class EditEmailViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    
    let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let email = dataset.stringForKey("email"){
            self.emailTextField.text = email
        }
        else{
            self.emailTextField.text = ""
        }
    }
    
    
    /* UITextFieldDelegate
    ------------------------------------------*/
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    

    
    /* scrollView Delegate
    ------------------------------------------*/
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.emailTextField.resignFirstResponder()
    }
    
    
    
    func setEmailInBDD(email: String){
        
        dataset.setString(email, forKey: "email")
        self.tableView.makeToastActivity()
        
        dataset.synchronize().continueWithBlock { (task:AWSTask) -> AnyObject? in
            self.tableView.hideToastActivity()
            if let _ = task.error {
                self.view.makeToast("An error occured".localized)
            }
            else{
                self.view.makeToast("A verification email was sent to your address".localized)
            }
            return nil
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    @IBAction func resendVerificationEmailButton(sender: AnyObject) {
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }


}
