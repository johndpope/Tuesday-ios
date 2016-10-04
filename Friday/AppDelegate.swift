//
//  AppDelegate.swift
//  Friday
//
//  Created by Christopher Rydahl on 07/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//  https://github.com/awslabs/aws-sdk-ios-samples/blob/master/CognitoSync-Sample/Objective-C/CognitoSyncDemo/AmazonClientManager.m


import UIKit
import CoreData
import GoogleMaps;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    let notificationViewHeight = CGFloat(65.0)
    var window: UIWindow?
    var meetingViewController:MeetingViewController?
    var tuesdayViewController:TuesdayViewController?
    
    let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.EUWest1,
        identityPoolId:"eu-west-1:7a9a8f62-2571-45eb-b6e4-6bb7c74811a4")
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        GMSServices.provideAPIKey(Params.GOOGLE_API_KEY)
        
        //Badge
        application.applicationIconBadgeNumber = 0;
        application.setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        
        //StoreManager
        StoreManager.sharedInstance.initialisation(nil)
        
        // AWS
        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Error
        
        let configuration = AWSServiceConfiguration(region:.EUWest1, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = configuration
        
        print("credentialsProvider.logins \(credentialsProvider.logins)")
        print("identityId \(credentialsProvider.identityId)")
        print("expiration \(credentialsProvider.expiration)")
        print("FBSDKAccessToken.currentAccessToken() \(FBSDKAccessToken.currentAccessToken())")
        
        let bool = FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions);
        
        if FBSDKAccessToken.currentAccessToken() != nil{
            var merge: [NSObject : AnyObject] = [:]
            merge[AWSCognitoLoginProviderKey.Facebook.rawValue] = FBSDKAccessToken.currentAccessToken().tokenString;
            self.credentialsProvider.logins = merge as [NSObject : AnyObject]
            self.credentialsProvider.refresh().continueWithBlock({ (task:AWSTask) -> AnyObject? in
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentRootViewController();
                }
                
                return nil
            })
        }
            
        else{
            displayLoginViewController()
        }
        
        return bool
    }
    
    
    func presentRootViewController(){
        self.presentRootViewController(shouldDisplayNewUser: false)
    }
    
    func presentRootViewController(shouldDisplayNewUser _shouldDisplayNewUser:Bool){
        print("appDelegate presentRootViewController")
        
        let dataset = AWSCognito.defaultCognito().openOrCreateDataset("identity")
        
        if let hasSignedIn = dataset.stringForKey("hasSignedIn") {
            if (hasSignedIn == "1"){
                self.displayRootViewController()
                return;
            }
        }
        
        dataset.synchronize().continueWithBlock { (task:AWSTask) -> AnyObject? in
            dispatch_async(dispatch_get_main_queue()) {
                if let hasSignedIn = dataset.stringForKey("hasSignedIn") {
                    if (hasSignedIn == "1"){
                        self.displayRootViewController()
                        return;
                    }
                }
                
                if (_shouldDisplayNewUser){
                    self.displayNewUserNavigationController()
                }
                else{
                    self.displayLoginViewController()
                }
                
            }
            return nil
        }
    }
    
    func displayRootViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let rootNavigationViewController = storyboard.instantiateViewControllerWithIdentifier("RootNavigationViewController") as? UINavigationController{
            self.window?.rootViewController = rootNavigationViewController
        }
    }
    
    func displayNewUserNavigationController(){
        //New User
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewControllerWithIdentifier("NewUserNavigationController")
        self.window?.rootViewController = rootViewController
    }
    
    func displayLoginViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginNavigationViewcontroller")
        self.window?.rootViewController = loginViewController
    }
    
    func logoutAWS(currentView: UIView){
        
        FBSDKLoginManager().logOut()
        
        // Wipe credentials
        self.credentialsProvider?.logins = nil
        AWSCognito.defaultCognito().wipe()
        self.credentialsProvider?.clearKeychain()
        
        currentView.hideToastActivity()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewControllerWithIdentifier("LoginNavigationViewcontroller")
        self.window?.rootViewController = loginViewController
        
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        //let alertView = UIAlertView(title: "Received link:", message: "\(url)", delegate: nil, cancelButtonTitle: "OK")
        //alertView.show()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // MARK: - Notification
    
    func isNotificationAuthorized() -> Bool{
        let application = UIApplication.sharedApplication()
        return application.isRegisteredForRemoteNotifications()
    }
    
    func shouldRegisterForRemoteNotifications(viewController: PresentAlertController){
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: NSUserDefaultsKey.HAS_ASKED_TO_ENABLE_NOTIFICATION_LOGIN)
        
        print("shouldRegisterForRemoteNotifications")
        
        var HAS_ASKED_TO_ENABLE_NOTIFICATION: String?
        if let _ = viewController as? LoginViewController{
            HAS_ASKED_TO_ENABLE_NOTIFICATION = NSUserDefaultsKey.HAS_ASKED_TO_ENABLE_NOTIFICATION_LOGIN
        }
            
        else if let _ = viewController as? SuggestionsViewController{
            HAS_ASKED_TO_ENABLE_NOTIFICATION = NSUserDefaultsKey.HAS_ASKED_TO_ENABLE_NOTIFICATION_DASHBOARD
        }
        
        if let HAS_ASKED_TO_ENABLE_NOTIFICATION = HAS_ASKED_TO_ENABLE_NOTIFICATION{
            if let hasAskedToEnableNotification = NSUserDefaults.standardUserDefaults().objectForKey(HAS_ASKED_TO_ENABLE_NOTIFICATION) as? Bool {
                if hasAskedToEnableNotification{
                    return
                }
            }
        }
        
        print("1")
        
        if let HAS_ASKED_TO_ENABLE_NOTIFICATION = HAS_ASKED_TO_ENABLE_NOTIFICATION{
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: HAS_ASKED_TO_ENABLE_NOTIFICATION)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if (!self.isNotificationAuthorized()){
            
            let alertController = UIAlertController(title: "We Would Like to Send You Notifications".localized, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Don't Allow".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
            })
            let doAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                self.registerForRemoteNotifications()
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(doAction)
            
            viewController.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func registerForRemoteNotifications(){
        print("registerForRemoteNotifications")
        let application = UIApplication.sharedApplication()
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            
            let receiveMatchCategory = UIMutableUserNotificationCategory()
            receiveMatchCategory.identifier = NotificationIdentifier.RECEIVE_MATCH;
            
            let categories = NSSet(objects: receiveMatchCategory) as! Set<UIUserNotificationCategory>;
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: categories)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        }
            
        else {
            application.registerForRemoteNotificationTypes(UIRemoteNotificationType.Alert)
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("didRegisterForRemoteNotificationsWithDeviceToken \(deviceToken)")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(deviceToken, forKey: NSUserDefaultsKey.DEVICE_TOKEN_KEY)
        userDefaults.synchronize()
        
        AWSManager.sharedInstance.registerForRemoteNotifications()
    }
    
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == UIApplicationState.Inactive {
            //PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        print("userInfo \(userInfo)")
        if let aps = userInfo["aps"] as? NSDictionary {
            
            if let category = aps["category"] as? String {
                if category == NotificationIdentifier.RECEIVE_MATCH {
                    tuesdayViewController?.updateCurrentViewController(nil)
                }
                    
                else if (category == NotificationIdentifier.RECEIVE_MESSAGE){
                    meetingViewController?.syncChatMeeting()
                }
                
                else if(category == NotificationIdentifier.IS_INVITED){
                    tuesdayViewController?.updateCurrentViewController(nil)
                }
                
                
            }
            
            
            if let alert = aps["alert"] as? String {
                self.displayNotificationView(alert);
            }
            
        }
        
    }
    
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func applicationDidReceiveMemoryWarning(application: UIApplication){
        
        print("applicationDidReceiveMemoryWarning")
    }
    
    //MARK - View Notification
    func displayNotificationView(title: String){
        
        let notificationView = NotificationView.loadFromNibNamed("NotificationView") as? NotificationView
        notificationView!.frame = CGRectMake(0, -notificationViewHeight, screenSize.width, notificationViewHeight);
        
        notificationView!.title.text = title
        UIApplication.sharedApplication().statusBarHidden = true
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            () -> Void in
            notificationView?.frame = CGRectMake(0, 0, self.screenSize.width, self.notificationViewHeight);
            }, completion: {
                _ in
                UIView.animateWithDuration(0.3, delay: 2.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    () -> Void in
                    notificationView?.frame = CGRectMake(0, -self.notificationViewHeight, self.screenSize.width, self.notificationViewHeight);
                    }, completion:{
                        _ in
                        notificationView?.removeFromSuperview()
                        UIApplication.sharedApplication().statusBarHidden = false
                })
        })
        self.window?.addSubview(notificationView!)
    }
    
    func displayErrorParse(error: NSError?){
        if error != nil{
            if let message = error!.userInfo["error"] as? String{
                let alertView = UIAlertView(title: "Warning".localized, message: message, delegate: self, cancelButtonTitle: "Ok".localized)
                alertView.show()
            }
        }
    }
}



extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
    
    func localizedStringWithVariables(vars: CVarArgType...) -> String {
        return String(format: NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: ""), arguments: vars)
    }
}
