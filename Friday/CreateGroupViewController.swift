//
//  CreateFridayViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 10/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation
import GoogleMaps

class CreateGroupViewController: UITableViewController, WhenViewControllerProtocol, WhereViewControllerProtocol {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var goLabel: UILabel!
    
    @IBOutlet weak var whenTitleLabel: UILabel!
    @IBOutlet weak var whenSubitleLabel: UILabel!
    @IBOutlet weak var selectDateLabel: UILabel!
    @IBOutlet weak var selectCityLabel: UILabel!
    var date: NSDate?
    
    @IBOutlet weak var whereTitleLabel: UILabel!
    var placeID: String?
    var namePlaceID: String?
    
    var previousUserInGroup: AWSUser_in_Group?
    var previousGroup: AWSGroup?
    var user: AWSUser?
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var previousGroupMatchedButton: UIButton!
    
    var containerViewController: ContainerViewController?
    var placesClient: GMSPlacesClient?
    
    var userCredits: AWSUserCredits?
    
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        didSelectDate(nil)
        didSelectPlace(nil)
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            print("getUser \(user)")
            print("getUser userProfile \(userProfile)")
            if let currentUser = user{
                self.user = currentUser
                
                if let dashboardKey = user?.dashboardKey{
                    let dashboardKeyArray = dashboardKey.componentsSeparatedByString("//")
                    if (dashboardKeyArray.count > 0){
                        let placeID = dashboardKeyArray[0]
                        self.placeID = placeID
                        self.getPlaceById(placeID)
                        self.getDateFromPlaceID(placeID)
                    }
                }
            }
        }
        
        displayPreviousUserInGroup()
        
        infoLabel.hidden = true
        previousGroupMatchedButton.hidden = true
    }
    
    func displayPreviousUserInGroup(){
        print("previousUserInGroup \(previousUserInGroup)")
        if let previousUserInGroup = previousUserInGroup {
            
            if let groupPartitionKey = previousUserInGroup.groupPartitionKey, groupSortKey = previousUserInGroup.groupSortKey{
                
                print("previousUserInGroup2")
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                dynamoDBObjectMapper.load(AWSGroup.self, hashKey: groupPartitionKey, rangeKey: groupSortKey).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                    
                    if let previousGroup = task.result as? AWSGroup{
                        dispatch_async(dispatch_get_main_queue()) {
                            self.previousGroup = previousGroup
                            self.displayPreviousGroup();
                        }
                    }
                    
                    return nil
                })
                
            }
        }
    }
    
    func displayPreviousGroup(){
        
        print("displayPreviousGroup \(previousGroup)")
        
        //On gère si il y a un prevous Group
        //Si le groupe correspondant n'est pas matché, on le dit (2)
        //Si le groupe correspondant est matché et qu'on n'a pas de rateEvening,
        //on propose à l'utilisateur de noter sa soirée (1)
        //Sinon on passe certianes infos (3)
        
        if let previousGroup = previousGroup{
            
            //(1)
            if previousGroup.otherGroupSortKey != nil && previousGroup.otherGroupSortKey != "-1" {
                
                previousGroupMatchedButton.hidden = false
                
            }
                
            else{
                
                //(2)
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
                dateFormatter.locale = NSLocale.currentLocale()
                
                if let date = getDateFromGroup(previousGroup){
                    
                    infoLabel.text = "You wanted to hang out on %@. Unfortunately, we didn't find any group to hang out with you. We gave you your credits back and be sure we do everything we can to improve your experience.".localizedStringWithVariables(dateFormatter.stringFromDate(date))
                    infoLabel.hidden = false
                    
                }
                
            }
        }
        
        //(3)
        if (infoLabel.hidden && previousGroupMatchedButton.hidden){
            infoLabel.text = "".localized
            infoLabel.hidden = false
        }
    }
    
    func getPlaceById(placeID: String){
        placesClient = GMSPlacesClient()
        
        placesClient!.lookUpPlaceID(placeID, callback: { (place: GMSPlace?, error: NSError?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                print("Place name \(place.name)")
                print("Place address \(place.formattedAddress)")
                print("Place placeID \(place.placeID)")
                print("Place attributions \(place.attributions)")
                self.whereTitleLabel.text = "\(place.name)"
                self.namePlaceID = place.name
                self.selectCityLabel.text = "Select another city".localized
            } else {
                self.whereTitleLabel.text = "".localized
                self.selectCityLabel.text = "Select a city".localized
            }
        })
        
    }
    
    
    func getDateFromPlaceID(placeID: String){
        print("getDateFromPlaceID")
        
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.hashKeyAttribute = "placeID"
        queryExpression.hashKeyValues = placeID
        
        queryExpression.rangeKeyConditionExpression = "dateString > :dateString"
        var dateStringMin = NSDate()
        let daysToAdd = 2.0
        dateStringMin = dateStringMin.dateByAddingTimeInterval(60*60*24*daysToAdd)
        queryExpression.expressionAttributeValues = [":dateString":dateStringMin.toYYYYMMdd()]
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper.query(AWSDateInCityPlace.self, expression: queryExpression).continueWithBlock { (task:AWSTask) -> AnyObject? in
            print("task.result \(task.result)")
            print("exception \(task.exception)")
            print("error \(task.error)")
            if let dateInCityPlaces = task.result?.items as? [AWSDateInCityPlace]{
                print("dateInCityPlaces \(dateInCityPlaces)")
                
                let orderedDateInCityPlaces = dateInCityPlaces.sort({ (a:AWSDateInCityPlace, b:AWSDateInCityPlace) -> Bool in
                    if let aDate = a.dateString, bDate = b.dateString{
                        return aDate < bDate
                    }
                    return true
                })
                
                dispatch_async(dispatch_get_main_queue()) {
                    for i in 0 ..< orderedDateInCityPlaces.count {
                        let dateInCityPlace = orderedDateInCityPlaces[i]
                        
                        if let date = dateInCityPlace.dateString?.getDateYYYYMMdd(), nbGroupLimit = dateInCityPlace.nbGroupLimit, nbBoyGroup = dateInCityPlace.nbBoyGroup, nbGirlGroup = dateInCityPlace.nbGirlGroup, isBoy = self.user?.isBoy{
                            
                            if (nbGroupLimit.integerValue > (isBoy.boolValue ? nbBoyGroup.integerValue : nbGirlGroup.integerValue)){
                                self.didSelectDate(date)
                                break;
                            }
                        }
                    }
                }
            }
            
            return nil
        }
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 40, 0)
        
        
        if let idFacebook = AWSManager.sharedInstance.idFacebook {
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.load(AWSUserCredits.self, hashKey: idFacebook, rangeKey: nil).continueWithBlock { (task:AWSTask) -> AnyObject? in
                
                if let userCredits = task.result as? AWSUserCredits {
                    self.userCredits = userCredits
                }
                
                return nil
                
            }
        }
        
    }
    
    func getDateFromGroup(group: AWSGroup) -> NSDate?{
        print("getDateFromGroup")
        if let dashboardKey = group.dashboardKey{
            
            let dashboardKeyArray = dashboardKey.componentsSeparatedByString("//")
            let dateString = dashboardKeyArray[1]
            print("dateString \(dateString)")
            return dateString.getDateYYYYMMdd()
            
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch (indexPath.section, indexPath.row){
        case (0,1):
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let whereViewController = storyboard.instantiateViewControllerWithIdentifier("WhereViewController") as? WhereViewController{
                whereViewController.delegate = self
                self.navigationController?.pushViewController(whereViewController, animated: true)
            }
            
            break;
            
        case (1,1):
            
            if let placeID = placeID, namePlaceID = namePlaceID{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let whenViewController = storyboard.instantiateViewControllerWithIdentifier("WhenViewController") as? WhenViewController{
                    whenViewController.delegate = self
                    whenViewController.placeID = placeID
                    whenViewController.namePlaceID = namePlaceID
                    self.navigationController?.pushViewController(whenViewController, animated: true)
                }
            }
            else{
                self.tableView.makeToast("First select the city where you want to hang out".localized)
            }
            
            break;
            
        case (2,0):
            willCreateGroup()
            break;
            
        default:
            break;
        }
        
    }
    
    
    
    func displayStoreViewController(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let storeNavigationController = storyboard.instantiateViewControllerWithIdentifier("StoreNavigationController") as? UINavigationController{
            self.presentViewController(storeNavigationController, animated: true, completion: nil)
        }
    }
    
    func willCreateGroup(){
        if let nbCredits = AWSManager.sharedInstance.getNbCredits(self.userCredits){
            if (nbCredits >= 10){
                
                if let namePlaceID = namePlaceID, date = date{
                    let dateString = DateManager.getTitle(date, isTime: false)
                    
                    let alertView = UIAlertController(title: "Confirm Your Evening".localizedStringWithVariables() , message: "Do you want to hang out in %@ on %@ for 10 Credits?".localizedStringWithVariables(namePlaceID, dateString), preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                    })
                    
                    let okAction = UIAlertAction(title: "Sure".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                        self.createGroup()
                    })
                    
                    alertView.addAction(cancelAction)
                    alertView.addAction(okAction)
                    self.presentViewController(alertView, animated: true, completion: nil)
                    
                }
                
                else{
                    if (namePlaceID == nil){
                        self.tableView.makeToast("Select the city where you want to hang out".localized, duration: 2.0, position: "center");

                    }
                    else if (date == nil){
                        self.tableView.makeToast("Select the date when you want to hang out".localized, duration: 2.0, position: "center");
                    }
                }
            }
                
            else{
                let alertView = UIAlertController(title: "Oups".localizedStringWithVariables() , message: "You do not have enough Credits to hang out".localizedStringWithVariables(nbCredits) , preferredStyle: UIAlertControllerStyle.Alert)
                
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction!) -> Void in
                })
                
                let okAction = UIAlertAction(title: "Get more".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction) -> Void in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let storeNavigationController = storyboard.instantiateViewControllerWithIdentifier("StoreNavigationController") as? UINavigationController{
                        self.presentViewController(storeNavigationController, animated: true, completion: nil)
                    }
                })
                
                alertView.addAction(cancelAction)
                alertView.addAction(okAction)
                self.presentViewController(alertView, animated: true, completion: nil)
            }
        }
        else{
            print("1")
        }
    }
    
    
    func createGroup(){
        if let _ = self.user, userDashboardKey = user?.dashboardKey, dateYYYYMMdd = date?.toYYYYMMdd(), idFacebook = self.user?.idFacebook, birthday = user?.birthday{
            
            refreshActivity(true)
            
            var lastMeetingDate: String? = user?.lastMeetingDate
            if lastMeetingDate == nil {
                lastMeetingDate = NSDate().toYYYYMMdd()
                self.user!.lastMeetingDate = lastMeetingDate
            }
            
            let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
            let jsonObject: [String:String] = [
                "dateYYYYMMdd": dateYYYYMMdd,
                "userDashboardKey": userDashboardKey,
                "idFacebook": idFacebook,
                "lastMeetingDate": lastMeetingDate!,
                "birthday":birthday
            ]
            
            lambdaInvoker.invokeFunction("AWScreateGroup", JSONObject: jsonObject).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                
                print("task.result \(task.result)")
                print("exception \(task.exception)")
                print("error \(task.error)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let result = task.result as? NSDictionary {
                        if let isOk = result.objectForKey("isOk") as? Bool {
                            if isOk {
                                self.containerViewController?.updateCurrentViewController(nil);
                            }
                            else{
                                if let errorMessage = result.objectForKey("message") as? String{
                                    self.view.makeToast(errorMessage.localized, duration: 3.0, position: "center");

                                }
                            }
                        }
                    }
                    
                }
                return nil
                
            }).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                
                print("task.result \(task.result)")
                print("exception \(task.exception)")
                print("error \(task.error)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshActivity(false)
                }
                return nil
            })
            
        }
            
        else{
            print("createGroup 2")
            if (user?.dashboardKey == nil){
                self.tableView.makeToast("Select the city where you want to hang out".localized, duration: 2.0, position: "center");

            }
            else if (date?.toYYYYMMdd() == nil){
                self.tableView.makeToast("Select the date when you want to hang out".localized, duration: 2.0, position: "center");

            }
        }
        
    }
    
    // MARK: - refreshActivity
    func refreshActivity(isActivity: Bool){
        if (isActivity){
            goLabel.hidden = true
            activityIndicator.startAnimating()
            self.view.makeToastActivity()
        }else{
            goLabel.hidden = false
            activityIndicator.stopAnimating()
            self.view.hideToastActivity()
        }
    }
    
    @IBAction func previousGroupMatchedButton(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let rateEveningViewController = storyboard.instantiateViewControllerWithIdentifier("RateEveningViewController") as? RateEveningViewController{
            rateEveningViewController.previousGroup = previousGroup
            let navViewController = UINavigationController(rootViewController: rateEveningViewController)
            self.presentViewController(navViewController, animated: true, completion: { () -> Void in
                
            })
        }
    }
    
    
    //MARK - WhenViewControllerProtocol
    func didSelectDate(date: NSDate?){
        self.date = date
        if let date = date{
            whenTitleLabel.text = DateManager.getTitle(date, isTime: false)
            whenSubitleLabel.text = DateManager.getSubtitle(date)
            selectDateLabel.text = "Select another date".localized
        }
        else{
            whenTitleLabel.text = "No date".localized
            whenSubitleLabel.text = "has been set".localized
            selectDateLabel.text = "Select a date".localized
        }
    }
    
    //MARK - WhereViewControllerProtocol
    func didSelectPlace(cityPlace: AWSCityPlace?) {
        print("didSelectPlace \(cityPlace)")
        if let isBoy = self.user?.isBoy, cityPlace = cityPlace{
            
            whereTitleLabel.text = cityPlace.name
            self.namePlaceID = cityPlace.name
            self.placeID = cityPlace.placeID
            
            let isBoyDashboardKey = isBoy.boolValue ? "1" : "2"
            self.user?.dashboardKey = cityPlace.placeID! + "//\(isBoyDashboardKey)"
            self.dynamoDBObjectMapper?.saveUpdateSkipNullAttributes(self.user)
            
            selectCityLabel.text = "Select another city".localized
            
        }
            
        else{
            whereTitleLabel.text = "".localized
            selectCityLabel.text = "Select a city".localized
        }
    }
    
    
}
















