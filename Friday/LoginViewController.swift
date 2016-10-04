//
//  LoginViewController.swift
//  Story
//
//  Created by Christopher Rydahl on 30/03/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import UIKit


class LoginViewController: UIViewController, UIPageViewControllerDelegate, PresentAlertController {
    
    let loginSubviewHeight = CGFloat(110)
    let marginTop = CGFloat(10)
    var pageViewController: UIPageViewController?
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var dynamoDBObjectMapper: AWSDynamoDBObjectMapper?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        self.pageViewController!.delegate = self
        
        let startingViewController: UIViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        
        self.pageViewController!.dataSource = self.modelController
        
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview(self.pageViewController!.view)
        
        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        let pageViewRect = CGRectMake(0, marginTop, self.view.bounds.size.width, self.view.bounds.size.height - loginSubviewHeight)
        
        self.pageViewController!.view.frame = pageViewRect
        
        self.pageViewController!.didMoveToParentViewController(self)
        
        // Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
        self.view.gestureRecognizers = self.pageViewController!.gestureRecognizers
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
            appDelegate.shouldRegisterForRemoteNotifications(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var modelController: LoginModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = LoginModelController()
        }
        return _modelController!
    }
    
    var _modelController: LoginModelController? = nil
    
    // MARK: - UIPageViewController delegate methods
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentViewController = self.pageViewController!.viewControllers![0]
        self.pageControl.currentPage = self.modelController.indexOfViewController(currentViewController)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    @IBAction func buttonFacebookLogin(sender: AnyObject) {
        
        AnalyticsManager.logEvent(AnalyticsManager.AppEventNameBeginRegistration, facebookEventName: AnalyticsManager.AppEventNameBeginRegistration)
        
        dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        
        self.view.makeToastActivity()
        
        // Set permissions required from the facebook user account
        let permissionsArray: [String] = ["user_friends", "user_likes", "user_photos", "user_birthday", "user_hometown", "user_education_history", "user_work_history", "email"]
        
        let loginManager = FBSDKLoginManager()
        loginManager.logInWithReadPermissions(permissionsArray, fromViewController: self) { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            print("error \(error)")
            print("result \(result)")
            
            let user = AWSUser()
            let userProfile = AWSUserProfile()
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, gender, birthday, hometown, education, work, email"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                print("startWithCompletionHandler")
                
                if ((error) != nil)
                {
                    // Process error
                    print("Error: \(error)")
                    self.view.hideToastActivity()
                }
                else
                {
                    print("login: \(result)")
                    
                    var isBoy = true
                    if let gender = result["gender"] as? String {
                        isBoy = (gender == "male")
                    }
                    
                    let dateFormat = NSDateFormatter()
                    dateFormat.dateFormat = "MM/dd/yyyy"
                    
                    var ageMin = 20
                    var ageMax = 30
                    var birthdayDate = dateFormat.dateFromString("08/01/1991")
                    if let birthday = result["birthday"] as? String {
                        birthdayDate = dateFormat.dateFromString("\(birthday)")
                        if let birthdayDate = birthdayDate{
                            let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                            let components = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: birthdayDate, toDate: NSDate(), options: [])
                            ageMin = max(components!.year - 4, 18);
                            ageMax = max(components!.year + 4, 22);
                        }
                    }
                    
                    var description:String = ""
                    if let hometown = result["hometown"] as? NSDictionary {
                        if let nameHometown = hometown["name"] as? String{
                            description = "I'm from " + nameHometown + ". ";
                        }
                    }
                    
                    if let education = result["education"] as? NSArray {
                        if education.count > 0{
                            if let lastEducation = education[education.count - 1] as? NSDictionary{
                                if let school = lastEducation["school"] as? NSDictionary{
                                    if let nameSchool = school["name"] as? String{
                                        description += "I studied at " + nameSchool + ". ";
                                    }
                                }
                            }
                        }
                    }
                    
                    if let work = result["work"] as? NSArray {
                        if work.count > 0{
                            if let lastWork = work[work.count - 1] as? NSDictionary{
                                if let employer = lastWork["employer"] as? NSDictionary{
                                    if let nameEmployer = employer["name"] as? String{
                                        description += "I worked at " + nameEmployer + ". ";
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    /* AWSManager
                    **************************************************/
                    AWSManager.sharedInstance.idFacebook = result["id"] as? String
                    
                    /* user
                    **************************************************/
                    user.idFacebook = result["id"] as? String
                    user.firstName = result["first_name"] as? String
                    
                    user.birthday = birthdayDate!.toYYYYMMdd()
                    user.isBoy = isBoy ? 1 : 0
                    
                    /* userProfile
                    **************************************************/
                    userProfile.idFacebook = result["id"] as? String
                    userProfile.ageMax = ageMax
                    userProfile.ageMin = ageMin
                    if (description != ""){
                        userProfile.desc = description
                    }
                    userProfile.isMessageNotification = 1
                    userProfile.isMessageNotificationChat = 1
                    
                    print("userProfile \(userProfile)")
                    
                    print("1")
                    var logins: [NSObject:AnyObject] = [NSObject:AnyObject]();
                    logins[AWSCognitoLoginProviderKey.Facebook.rawValue] = FBSDKAccessToken.currentAccessToken().tokenString;
                    var task: AWSTask?
                    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                        appDelegate.credentialsProvider.logins = logins;
                        task = appDelegate.credentialsProvider.refresh()
                    }
                    print("2")
                    task?.continueWithBlock {
                        (task: AWSTask!) -> AnyObject! in
                        
                        print("3")
                        if (task.error != nil) {
                            let userDefaults = NSUserDefaults.standardUserDefaults()
                            let currentDeviceToken: NSData? = userDefaults.objectForKey(NSUserDefaultsKey.DEVICE_TOKEN_KEY) as? NSData
                            var currentDeviceTokenString : String
                            
                            if currentDeviceToken != nil {
                                currentDeviceTokenString = currentDeviceToken!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                            } else {
                                currentDeviceTokenString = ""
                            }
                            
                            if currentDeviceToken != nil && currentDeviceTokenString != userDefaults.stringForKey(NSUserDefaultsKey.COGNITO_DEVICE_TOKEN_KEY) {
                                
                                AWSCognito.defaultCognito().registerDevice(currentDeviceToken).continueWithBlock { (task: AWSTask!) -> AnyObject! in
                                    if (task.error == nil) {
                                        userDefaults.setObject(currentDeviceTokenString, forKey: NSUserDefaultsKey.COGNITO_DEVICE_TOKEN_KEY)
                                        userDefaults.synchronize()
                                    }
                                    return nil
                                }
                            }
                        }
                        return task
                        
                        }.continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            print("4")
                            
                            //On check si le user est completement new ou pas
                            return self.dynamoDBObjectMapper!.load(AWSUser.self, hashKey: user.idFacebook, rangeKey: nil)
                            
                        }).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            print("41")
                            print("task.result \(task.result)")
                            print("exception \(task.exception)")
                            print("error \(task.error)")
                            
                            //Si le user existe déjà
                            if let result = task.result as? AWSUser{
                                if let _ = result.idFacebook, _ = result.firstName{
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.presentRootViewController(shouldDisplayNewUser: true);
                                    }
                                    print("41 bis")
                                    return AWSTask(error: NSError(domain: "", code: 1, userInfo: nil))
                                }
                            }
                            
                            print("41 ter \(userProfile)")
                            return self.dynamoDBObjectMapper!.saveUpdateSkipNullAttributes(userProfile)
                            
                            
                        }).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                            
                            print("4 bis")
                            print("task.result \(task.result)")
                            print("exception \(task.exception)")
                            print("error \(task.error)")
                            let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
                            
                            dataset.setString("0", forKey: "hasSignedIn")
                            
                            if let email = result["email"] as? String {
                                if dataset.stringForKey("email") == nil{
                                    dataset.setString(email, forKey: "email")
                                }
                            }
                            
                            if let name = result["name"] as? String {
                                dataset.setString(name, forKey: "name")
                            }
                            
                            if let idFacebook = result["id"] as? String {
                                dataset.setString(idFacebook, forKey: "idFacebook")
                            }
                            
                            return dataset.synchronizeOnConnectivity()
                            
                        }).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                            print("555555555555")
                            print("task.result \(task.result)")
                            print("exception \(task.exception)")
                            print("error \(task.error)")
                            return self.dynamoDBObjectMapper!.saveUpdateSkipNullAttributes(user)
                            
                        }).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                            if (task.error == nil){
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.presentRootViewController(shouldDisplayNewUser: true);
                                }
                            }
                            else{
                                print("taskerror \(task.error)")
                            }
                            return nil
                        }).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            print("6")
                            print("task.result \(task.result)")
                            print("exception \(task.exception)")
                            print("error \(task.error)")
                            return nil
                        })
                    
                }
            })
            
        }
        
    }
    
    func presentRootViewController(shouldDisplayNewUser _shouldDisplayNewUser:Bool){
        print("presentRootViewController")
        self.view.hideToastActivity()
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate;
        appDelegate?.presentRootViewController(shouldDisplayNewUser: _shouldDisplayNewUser)
        AWSManager.sharedInstance.registerForRemoteNotifications()
    }
    
}

protocol PresentAlertController{
    func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}

