//
//  EditProfilViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class EditProfilViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate{
    
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    var user: AWSUser?
    var userProfile: AWSUserProfile?
    var dynamoDBObjectMapper: AWSDynamoDBObjectMapper?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let currentUser = user, currentUserProfile = userProfile{
                self.user = currentUser
                self.userProfile = currentUserProfile
                self.initialisation()
            }
            else{
                self.view.makeToast("Could not refresh your data".localized)
            }
        }
    }
    
    
    func initialisation(){
        
        if let currentUser = self.user, userProfile = self.userProfile{
            if let isBoy = currentUser.isBoy{
                if (isBoy == 1){
                    self.genderLabel.text = "Male".localized
                }else{
                    self.genderLabel.text = "Female".localized
                }
            }
            
            if let birthday = currentUser.getDate(){
                
                let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let components = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: birthday, toDate: NSDate(), options: [])
                self.ageTextField.text = String(components!.year)
                
            }
            
            if let description = userProfile.desc {
                self.descriptionTextView.text = description
            }else{
                self.descriptionTextView.text = "No description yet".localized
            }
            
            let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
            
            if let email = dataset.stringForKey("email"){
                self.emailLabel.text = email
            }else{
                self.emailLabel.text = "No email yet".localized
            }
        }
    }
    
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.descriptionTextView.becomeFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
            let age = Int(ageTextField.text!)!
            var birthdayDate = NSDate()
            if let birthday = self.user?.getDate(){
                let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let components = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: birthday, toDate: NSDate(), options: [])
                let diffYear = age - components!.year;
                
                let componentsBirthday = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: birthday)
                componentsBirthday!.year = componentsBirthday!.year - diffYear
                birthdayDate = gregorianCalendar!.dateFromComponents(componentsBirthday!)!
                
                
            }else{
                
                let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                let components = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: NSDate())
                components!.year = components!.year - age;
                birthdayDate = gregorianCalendar!.dateFromComponents(components!)!
                
            }
            
            self.user?.birthday = birthdayDate.toYYYYMMddhhmm()
            self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(self.user)
        
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        self.userProfile?.desc = descriptionTextView.text
        self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(self.user)
        
    }
    
    /* scrollView Delegate
    ------------------------------------------*/
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.descriptionTextView.resignFirstResponder()
        self.ageTextField.resignFirstResponder()
    }
    
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
}
