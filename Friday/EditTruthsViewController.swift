//
//  EditTruthsViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 24/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class EditTruthsViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet weak var truth1TextView: UITextView!
    @IBOutlet weak var truth2TextView: UITextView!
    @IBOutlet weak var lieTextView: UITextView!
    var userProfile: AWSUserProfile?
    var dynamoDBObjectMapper: AWSDynamoDBObjectMapper?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let userProfile = userProfile {
                self.userProfile = userProfile
                self.initialisation()
            }
            else{
                self.view.makeToast("Could not refresh your data".localized)
            }
        }
    }
    
    func initialisation(){
        
        if let truth1 = self.userProfile?.truth1{
            self.truth1TextView.text = truth1
        }
        
        if let truth2 = self.userProfile?.truth2{
            self.truth2TextView.text = truth2
        }
        
        if let lie = self.userProfile?.lie{
            self.lieTextView.text = lie
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.truth1TextView.becomeFirstResponder()
        return true
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
        
        self.userProfile?.truth1 = truth1TextView.text
        self.userProfile?.truth2 = truth2TextView.text
        self.userProfile?.lie = lieTextView.text
        
        self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(self.userProfile)
    }
    
    /* scrollView Delegate
    ------------------------------------------*/
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.truth1TextView.resignFirstResponder()
        self.truth2TextView.resignFirstResponder()
        self.lieTextView.resignFirstResponder()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
