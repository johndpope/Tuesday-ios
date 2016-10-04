//
//  SuggestionsViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 13/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

struct IdentifierDashboardCell {
    static let DashboardButtonCell = "DashboardButtonCell";
    static let DashboardButtonDiscoveryCell = "DashboardButtonDiscoveryCell";
    static let DashboardButtonRefreshCell = "DashboardButtonRefreshCell";
}

class SuggestionsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PopUpControllerDelegate, DashboardCellDelegate, ExplicationViewControllerDelegate, PresentAlertController {
    
    var countUsersInGroup: Int = 1
    var dateGroup: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var labelHeader: UILabel!
    
    let refreshControl = UIRefreshControl()
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    var idFacebookUsers : [String] = []
    var usersDict: [String:AWSUser] = [:]
    let nbCellPerRow: CGFloat = 2.0
    let heightButtonsDashboardCell: CGFloat = 40.0
    let minimumInteritemSpacing:  CGFloat = 8.0
    let heightHeader:  CGFloat = 60.0
    
    var moreSuggestionsController: MoreSuggestionsViewController?
    var discoveryPreferencesNavigationController:UINavigationController?
    var utilisateurGalerieViewController: UtilisateurGalerieViewController?
    var welcomeViewController: WelcomeViewController?
    var explicationViewController: ExplicationViewController?
    
    var isRefreshed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //On le met là au cas où
        //Dans un premier temps le user refuse les notifications
        //Dans un second temps le user autorise les notifications dans les settings
        AWSManager.sharedInstance.registerForRemoteNotifications()
        
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        refreshControl.tintColor = UIColor.lightGrayColor()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localized)
        refreshControl.addTarget(self, action: #selector(SuggestionsViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(refreshControl)
        
        let screenWidth = self.view.frame.size.width
        let widthItem = (screenWidth - minimumInteritemSpacing * (nbCellPerRow + 1)) / nbCellPerRow
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: heightHeader + minimumInteritemSpacing, left: minimumInteritemSpacing, bottom: 10, right: minimumInteritemSpacing)
        layout.itemSize = CGSize(width: widthItem, height: widthItem + heightButtonsDashboardCell)
        layout.minimumInteritemSpacing = minimumInteritemSpacing
        layout.minimumLineSpacing = minimumInteritemSpacing
        self.collectionView.collectionViewLayout = layout
        
        displayWelcomeViewController()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!isRefreshed){
            isRefreshed = true
            self.refresh(self)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        moreSuggestionsController = storyboard.instantiateViewControllerWithIdentifier("MoreSuggestionsViewController") as? MoreSuggestionsViewController
        moreSuggestionsController?.countUsersInGroup = self.countUsersInGroup
        discoveryPreferencesNavigationController = storyboard.instantiateViewControllerWithIdentifier("DiscoveryPreferencesNavigationController") as? UINavigationController
        utilisateurGalerieViewController = storyboard.instantiateViewControllerWithIdentifier("UtilisateurGalerieViewController") as? UtilisateurGalerieViewController
    }
    
    
    func getDashboardUsers(){
        print("getDashboardUsers")
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let user = user {
                
                if let idFacebook = user.idFacebook, dashboardKey = user.dashboardKey, dateGroup = self.dateGroup{
                    
                    self.labelHeader.text = "Looking for users..".localized
                    let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                    let jsonObject = [
                        "idFacebook":idFacebook,
                        "dashboardKey": dashboardKey,
                        "countUsersInGroup": self.countUsersInGroup,
                        "dateGroup":dateGroup
                    ]
                    lambdaInvoker.invokeFunction("AWSgetDashboardUsers", JSONObject: jsonObject).continueWithBlock { (task:AWSTask) -> AnyObject? in
                        
                        print("lambdaInvoker result: \(task.result)");
                        print("lambdaInvoker exception: \(task.exception)");
                        print("lambdaInvoker error: \(task.error)");
                        dispatch_async(dispatch_get_main_queue()) {
                            if let result = task.result as? NSDictionary {
                                if let notSeenDailySuggestions = result.objectForKey("notSeenDailySuggestions") as? [String] {
                                    print("Result: \(notSeenDailySuggestions)");
                                    self.idFacebookUsers = notSeenDailySuggestions
                                    self.reloadCollectionView()
                                }
                                else{
                                    self.labelHeader.text = "No new users. Come back tomorrow.".localized
                                }
                            }
                            self.refreshControl.endRefreshing()
                            self.collectionView.hideToastActivity()
                        }
                        return nil
                    }
                    
                }
            }
        }
    }
    
    
    func refresh(sender: AnyObject) {
        self.collectionView.makeToastActivity()
        getDashboardUsers()
    }
    
    func updateLabelHeader(){
        let nbSuggestions = idFacebookUsers.count
        if (nbSuggestions == 0){
            self.labelHeader.text = "That's all for today: come back tomorrow!".localized
        }
        else if (nbSuggestions == 1){
            self.labelHeader.text = "%d suggestion".localizedStringWithVariables(nbSuggestions)
        }
        else{
            self.labelHeader.text = "%d suggestions".localizedStringWithVariables(nbSuggestions)
        }
    }
    
    func reloadCollectionView(){
        updateLabelHeader()
        self.collectionView.reloadData()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return idFacebookUsers.count + 3
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if (indexPath.row < idFacebookUsers.count){
            var cell:DashboardCell! = collectionView.dequeueReusableCellWithReuseIdentifier("DashboardCell", forIndexPath: indexPath) as! DashboardCell
            if cell == nil {
                collectionView.registerNib(UINib(nibName: "DashboardCell", bundle: nil), forCellWithReuseIdentifier: "DashboardCell")
                cell = collectionView.dequeueReusableCellWithReuseIdentifier("DashboardCell", forIndexPath: indexPath) as? DashboardCell
            }
            self.configureDashboardCell(cell, atIndexPath: indexPath)
            return cell
        }
        else{
            let identifier = self.getIdentifier(indexPath)
            var cell:DashboardButtonCell! = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as! DashboardButtonCell
            if cell == nil {
                collectionView.registerNib(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
                cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier, forIndexPath: indexPath) as? DashboardButtonCell
            }
            return cell
        }
        
    }
    
    func getIdentifier(indexPath:NSIndexPath)->String{
        if (indexPath.row == idFacebookUsers.count){
            return IdentifierDashboardCell.DashboardButtonCell
        }
        else if (indexPath.row == idFacebookUsers.count + 1){
            return IdentifierDashboardCell.DashboardButtonDiscoveryCell
        }
        else {
            return IdentifierDashboardCell.DashboardButtonRefreshCell
        }
    }
    
    func configureDashboardCell(cell:DashboardCell, atIndexPath indexPath: NSIndexPath){
        
        let idFacebookUser = idFacebookUsers[indexPath.row]
        
        if let user = self.usersDict[idFacebookUser]{
            self.configureDashboardCell(cell, withUser: user)
        }
        else{
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.load(AWSUser.self, hashKey: idFacebookUser, rangeKey: nil).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                
                print(" dynamoDBObjectMapper.load(User exception: \(task.exception)");
                print(" dynamoDBObjectMapper.load(User error: \(task.error)");
                
                if let user = task.result as? AWSUser {
                    
                    print(" dynamoDBObjectMapper.load(User result: \(task.result)");
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.usersDict[idFacebookUser] = user
                        self.configureDashboardCell(cell, withUser: user)
                        
                    }
                }
                
                
                return nil
            })
            
        }
        
    }
    
    func configureDashboardCell(cell:DashboardCell, withUser user: AWSUser){
        
        cell.delegate = self
        
        var profilLabelText = ""
        if let firstName = user.firstName{
            
            profilLabelText = firstName
            if let birthdayString = user.birthday{
                
                let newDateFormat = NSDateFormatter()
                newDateFormat.dateFormat = "yyyy-MM-dd"
                
                if let birthday = newDateFormat.dateFromString(birthdayString){
                    
                    let gregorianCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
                    let components = gregorianCalendar?.components(NSCalendarUnit.Year, fromDate: birthday, toDate: NSDate(), options: [])
                    profilLabelText = profilLabelText + ", " + String(components!.year)
                }
            }
        }
        
        cell.profilImageView.setProfilePicture(user)
        
        if (profilLabelText == ""){
            cell.viewLabel.hidden = true
        }else{
            cell.viewLabel.hidden = false
            cell.label.text = profilLabelText
        }
    }
    
    func crossButton(cell: UICollectionViewCell) {
        print("crossButtoncrossButton")
        willDeleteCell(false, cell: cell)
    }
    
    
    func checkButton(cell: UICollectionViewCell) {
        print("checkButtoncheckButton")
        willDeleteCell(true, cell: cell)
    }
    
    func presentAlertController(alertController: UIAlertController){
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func willDeleteCell(isLiked: Bool, cell: UICollectionViewCell){
        self.displayExplicationViewController(isLiked)
        if let indexPath = self.collectionView.indexPathForCell(cell){
            if indexPath.row < self.idFacebookUsers.count {
                let idOtherUser = idFacebookUsers[indexPath.row]
                self.idFacebookUsers.removeAtIndex(indexPath.row)
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
                self.updateLabelHeader()
                self.saveUserLikesUser(isLiked, idOtherUser: idOtherUser)
            }
        }
    }
    
    func saveUserLikesUser(isLiked: Bool, idOtherUser: String){
        
        print("sendUserLikesUser")
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let user = user {
                
                print("sendUserLikesUser")
                if let isBoy = user.isBoy, idFacebook = user.idFacebook{
                    
                    let user_likes_User = AWSUser_likes_User()
                    user_likes_User.idUserBoy = isBoy.boolValue ? idFacebook : idOtherUser
                    user_likes_User.idUserGirl = isBoy.boolValue ? idOtherUser : idFacebook
                    if (isBoy.boolValue){
                        user_likes_User.isBoyLikingGirl = isLiked ? NSNumber(integer: 1) : NSNumber(integer: -1)
                    }
                    else{
                        user_likes_User.isGirlLikingBoy = isLiked ? NSNumber(integer: 1) : NSNumber(integer: -1)
                    }
                    
                    
                    self.dynamoDBObjectMapper.saveUpdateSkipNullAttributes(user_likes_User).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        print("task.result \(task.result)")
                        print("exception \(task.exception)")
                        print("error \(task.error)")
                        return nil
                    })
                    
                }
                
            }
        }
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < idFacebookUsers.count){
            if let utilisateurGalerieViewController = utilisateurGalerieViewController, user = usersDict[self.idFacebookUsers[indexPath.row]] {
                utilisateurGalerieViewController.user = user
                self.presentViewController(utilisateurGalerieViewController, animated: true, completion: nil)
            }
        }
        else{
            let identifier = self.getIdentifier(indexPath)
            switch(identifier){
            case IdentifierDashboardCell.DashboardButtonCell:
                if let moreSuggestionsController = moreSuggestionsController{
                    
                    let navigationController = UINavigationController()
                    navigationController.navigationBar.tintColor = UIColor(red: 108/255.0, green: 3/255.0, blue: 169/255.0, alpha: 1.0)
                    navigationController.viewControllers = [moreSuggestionsController]
                    self.presentViewController(navigationController, animated: true, completion: nil)
                }
                break;
                
            case IdentifierDashboardCell.DashboardButtonDiscoveryCell:
                if let discoveryPreferencesNavigationController = discoveryPreferencesNavigationController{
                    self.presentViewController(discoveryPreferencesNavigationController, animated: true, completion: nil)
                }
                break;
                
            case IdentifierDashboardCell.DashboardButtonRefreshCell:
                self.refresh(self)
                break;
            default:
                break;
            }
        }
        
    }
    
    
    
    func displayWelcomeViewController(){
        
        if let isNewOnTuesday = NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaultsKey.IS_NEW_ON_TUESDAY) as? Bool {
            if isNewOnTuesday{
                
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: NSUserDefaultsKey.IS_NEW_ON_TUESDAY)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                welcomeViewController = storyboard.instantiateViewControllerWithIdentifier("WelcomeViewController") as? WelcomeViewController
                
                welcomeViewController?.view.alpha = 0
                welcomeViewController?.view.frame = UIScreen.mainScreen().bounds
                welcomeViewController?.delegate = self
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
                appDelegate.window?.addSubview(welcomeViewController!.view)
                
                UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.welcomeViewController!.view.alpha = 1.0
                    }) { (success: Bool) -> Void in
                        
                }
                
                return
            }
        }
        
    }
    
    //MARK - PopUpControllerDelegate
    func popUpControllerDelegateViewControllerdidFinish(willDoIt: Bool){
        UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.welcomeViewController?.view.alpha = 0.0
            }) { (success: Bool) -> Void in
                
                self.welcomeViewController?.view.removeFromSuperview()
                self.welcomeViewController?.view.alpha = 1.0
                
        }
    }
    
    func displayExplicationViewController(didLikeOtherGroup: Bool){
        if let isNewOnDashboard = NSUserDefaults.standardUserDefaults().objectForKey(NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_EXPLICATION) as? Bool{
            if isNewOnDashboard {
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: NSUserDefaultsKey.IS_NEW_ON_DASHBOARD_EXPLICATION)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.explicationViewController = storyboard.instantiateViewControllerWithIdentifier("ExplicationViewController") as? ExplicationViewController
                self.explicationViewController?.delegate = self
                self.explicationViewController?.didLikeOtherGroup = didLikeOtherGroup
                explicationViewController!.view.frame = UIScreen.mainScreen().bounds
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
                explicationViewController!.view.alpha = 0
                appDelegate.window?.addSubview(explicationViewController!.view)
                
                UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.explicationViewController!.view.alpha = 1.0
                    }) { (success: Bool) -> Void in
                }
            }
        }
    }
    
    //Mark - ExplicationViewControllerDelegate
    func explicationViewControllerdidFinish() {
        
        UIView.animateWithDuration(1.0, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.explicationViewController!.view.alpha = 0.0
            }) { (success: Bool) -> Void in
                
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                    appDelegate.shouldRegisterForRemoteNotifications(self)
                }
                
                AnalyticsManager.logEvent(AnalyticsManager.AMAZON_AppEventNameCompletedTutorial, facebookEventName: AnalyticsManager.FACEBOOK_AppEventNameCompletedTutorial)
                
                self.explicationViewController!.view.removeFromSuperview()
                self.explicationViewController!.view.alpha = 1.0
                
                
        }
        
    }
    
    
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }


}
