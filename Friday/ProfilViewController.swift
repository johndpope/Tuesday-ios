//
//  ProfilViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ProfilViewController: UITableViewController {
    
    @IBOutlet weak var profilImage: AWSImageView!
    @IBOutlet weak var profilLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let currentUser = user {
                
                self.profilImage.setProfilePicture(currentUser)
                
                var profilLabelText = ""
                if let firstName = currentUser.firstName{
                    
                    profilLabelText = firstName
                    if let birthdayString = currentUser.birthday{
                        let newDateFormat = NSDateFormatter()
                        newDateFormat.dateFormat = "yyyy-MM-dd"
                        
                        if let birthday = newDateFormat.dateFromString(birthdayString){
                            
                            let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                            let components = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: birthday, toDate: NSDate(), options: [])
                            profilLabelText = profilLabelText + ", " + String(components!.year)
                        }
                    }
                    
                    
                }else{
                    profilLabelText = "Your profile".localized
                }
                
                self.profilLabel.text = profilLabelText
                
            }
        }
        
        
        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0){
            return UIScreen.mainScreen().bounds.width
        }else{
            return 60
        }
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func editButton(sender: AnyObject) {
        self.performSegueWithIdentifier("EditPhotoVC", sender: self)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0){
            self.performSegueWithIdentifier("EditPhotoVC", sender: self)
        }
    }
}
