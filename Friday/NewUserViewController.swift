//
//  NewUserViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 13/08/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit
import GoogleMaps

class NewUserViewController: UITableViewController, WhereViewControllerProtocol {
    
    private struct IndexIsBoy{
        static let MALE = 1;
        static let FEMALE = 0;
        static let UNKNOWN = -1;
    }
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    
    var isBoyIndex: Int = -1
    var cityPlace: AWSCityPlace?
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    var user: AWSUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
        
        if let isBoy = dataset.stringForKey("isBoy"){
            if (isBoy == "1"){
                isBoyIndex = 1
            }else{
                isBoyIndex = 0
            }
        }
        else{
            isBoyIndex = -1
        }
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            print("NewUserViewController getUser user \(user)")
            self.user = user
        }
        
        updateGenderLabel()
        updateCityLabel()
    }
    
    func updateCityLabel(){
        if let cityPlace = self.cityPlace {
            cityLabel.text = cityPlace.name
        }
        else{
            cityLabel.text = "???".localized
        }
    }
    
    func updateGenderLabel(){
        switch(isBoyIndex){
        case IndexIsBoy.FEMALE:
            self.genderLabel.text = "I am a woman".localized
            break;
            
        case IndexIsBoy.MALE:
            self.genderLabel.text = "I am a man".localized
            break;
            
        default:
            self.genderLabel.text = "I am ?".localized
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section, indexPath.row){
        case (0,0):
            switch (isBoyIndex){
            case IndexIsBoy.FEMALE:
                isBoyIndex = IndexIsBoy.MALE
                break;
                
            case IndexIsBoy.MALE:
                isBoyIndex = IndexIsBoy.FEMALE
                break;
                
            default:
                isBoyIndex = IndexIsBoy.FEMALE
                break;
            }
            
            self.updateGenderLabel()
            break;
            
        case (1,0):
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let whereViewController = storyboard.instantiateViewControllerWithIdentifier("WhereViewController") as? WhereViewController{
                whereViewController.delegate = self;
                self.navigationController?.pushViewController(whereViewController, animated: true)
            }
            
            break;
            
        default:
            break;
        }
        
        self.tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }
    
    
    @IBAction func signUpButton(sender: AnyObject) {
        if isBoyIndex == IndexIsBoy.UNKNOWN{
            return
        }
        
        if self.cityPlace == nil {
            return
        }
        
        if self.user == nil{
            return
        }
        
        print("NewUserViewController signUpButton")
        self.view.makeToastActivity()
        PhotoManager.sharedInstance.uploadProfilePictures { () -> Void in
            print("NewUserViewController yolo - 1")
            var isBoy: Bool
            if self.isBoyIndex == IndexIsBoy.FEMALE {
                isBoy = false
            }else{
                isBoy = true
            }
            
            AWSManager.sharedInstance.getUser({ (user, userProfile) -> Void in
                if let user = user {
                    user.isBoy = isBoy ? 1 : 0
                    let isBoyDashboardKey = isBoy ? "1" : "2"
                    user.dashboardKey = self.cityPlace!.placeID! + "//\(isBoyDashboardKey)"
                    user.lastMeetingDate = NSDate().toYYYYMMddhhmm()
                    user.nextMeetingDate = NSDate().toYYYYMMddhhmm()
                    
                    self.dynamoDBObjectMapper.saveUpdateSkipNullAttributes(user).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                        print("NewUserViewController yolo 1")
                        
                        print("task.result \(task.result)")
                        print("error \(task.error)")
                        print("exception \(task.exception)")
                        
                        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
                        dataset.setString("1", forKey: "hasSignedIn")
                        return dataset.synchronize()
                        
                    }).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                        
                        print("NewUserViewController yolo 2")
                        dispatch_async(dispatch_get_main_queue()) {
                            
                            self.setStandardUserDefaults()
                            
                            AWSManager.sharedInstance.user = user
                            
                            AnalyticsManager.logEvent(AnalyticsManager.AMAZON_AppEventNameCompletedRegistration, facebookEventName: AnalyticsManager.FACEBOOK_AppEventNameCompletedRegistration)
                            
                            self.view.hideToastActivity()
                            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate;
                            appDelegate?.presentRootViewController()
                            print("NewUserViewController yolo 3")
                        }
                        
                        return nil
                    }).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        print("NewUserViewController yolo 4")
                        self.view.hideToastActivity()
                        
                        print("task.result \(task.result)")
                        print("error \(task.error)")
                        print("exception \(task.exception)")
                        
                        if let _ = task.error{
                            self.view.makeToast("An error occured".localized)
                        }
                        else if let _ = task.exception{
                            self.view.makeToast("An error occured".localized)
                        }
                        return nil
                        
                    })
                }
            })
            
            
        }
        
    }
    
    @IBAction func termsButton(sender: AnyObject) {
        let url = NSURL(string: urls.TermsOfUse);
        if !UIApplication.sharedApplication().openURL(url!){
            self.view.makeToast("An error occured".localized);
        }
        
    }
    
    @IBAction func crossButton(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate;
        appDelegate?.logoutAWS(self.view)
    }
    
    func setStandardUserDefaults(){
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSUserDefaultsKey.IS_NEW_ON_TUESDAY)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_LIKE)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_NOPE)
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_EXPLICATION)
        NSUserDefaults.standardUserDefaults().synchronize();
    }
    
    
    //MARK - WhereViewControllerProtocol
    func didSelectPlace(cityPlace: AWSCityPlace?) {
        if let cityPlace = cityPlace {
            self.cityPlace = cityPlace
            self.updateCityLabel()
        }
    }
}
