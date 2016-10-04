//
//  EditGroupViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation
import MessageUI

class EditGroupViewController: UITableViewController, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, AddFriendViewControllerDelegate {
    
    var user_in_group : AWSUser_in_Group?
    var usersDict: [String:AWSUser] = [:]
    var idUsers: [String] = []
    let maxNbUsersInGroup: Int = 3
    var user: AWSUser?
    var otherGroupSortKey: String?
    
    var messageComposeViewController = MFMessageComposeViewController();
    
    @IBOutlet weak var infoDateLabel: UILabel!
    @IBOutlet weak var dateNextMeetingLabel: UILabel!
    
    var containerViewController: ContainerViewController?
    
    var nextDateMeeting: NSDate?
    var timer: NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoDateLabel.text = ""
        
        if let date = getDateFromGroup() {
            
            nextDateMeeting = date
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(EditGroupViewController.updateDateNextMeetingLabel), userInfo: nil, repeats: true)
            
        }
        
        self.refresh(self)
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            self.user = user
        }
        
    }
    
    func getDateFromGroup() -> NSDate?{
        return AWSManager.sharedInstance.getDateFromGroupPartitionKey(user_in_group?.groupPartitionKey)
    }
    
    
    // called every time interval from the timer
    func updateDateNextMeetingLabel() {
        var dateNextMeetingLabelText = ""
        
        if let otherGroupSortKey = otherGroupSortKey, nextDateMeeting = nextDateMeeting{
            
            if (otherGroupSortKey == "-1"){
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
                dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
                dateFormatter.locale = NSLocale.currentLocale()
                
                dateNextMeetingLabelText = "You wanted to hang out on %@. Unfortunately, we didn't find any group to hang out with you. We gave you your credits back and be sure we do everything we can to improve your experience.".localizedStringWithVariables(dateFormatter.stringFromDate(nextDateMeeting))
                
                dateNextMeetingLabel.text = dateNextMeetingLabelText
                dateNextMeetingLabel.hidden = false
                
                return
            }
        }
        
        
        
        dateNextMeetingLabelText = "You will be matched in less than".localized
        let now = NSDate()
        let components = nextDateMeeting!.componentsFrom(now)
        
        let days = components.day
        if (days <= 1){
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d day".localizedStringWithVariables(days)
        }
        else{
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d days".localizedStringWithVariables(days)
        }
        
        let hours = components.hour
        if (hours <= 1){
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d hour".localizedStringWithVariables(hours)
        }
        else{
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d hours".localizedStringWithVariables(hours)
        }
        
        let minutes = components.minute
        if (minutes <= 1){
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d minute".localizedStringWithVariables(minutes)
        }
        else{
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d minutes".localizedStringWithVariables(minutes)
        }
        
        let seconds = components.second
        if (seconds <= 1){
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d second".localizedStringWithVariables(seconds)
        }
        else{
            dateNextMeetingLabelText = dateNextMeetingLabelText + " " + "%d seconds".localizedStringWithVariables(seconds)
        }
        
        
        dateNextMeetingLabel.text = dateNextMeetingLabelText
        dateNextMeetingLabel.hidden = false
    }
    
    @IBAction func refresh(sender: AnyObject) {
        
        if let groupPartitionKey = user_in_group?.groupPartitionKey, groupSortKey = user_in_group?.groupSortKey{
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBQueryExpression()
            
            queryExpression.hashKeyAttribute = "groupPartitionKey"
            queryExpression.hashKeyValues = groupPartitionKey
            queryExpression.rangeKeyConditionExpression = "groupSortKey = :groupSortKey"
            queryExpression.expressionAttributeValues = [":groupSortKey":groupSortKey]
            
            queryExpression.limit = maxNbUsersInGroup
            queryExpression.indexName = "getUserFromGroupIndex"
            
            dynamoDBObjectMapper.query(AWSUser_in_Group.self, expression: queryExpression).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                
                print("taskerror \(task.error)")
                print("taskexception \(task.exception)")
                if task.error == nil{
                    let paginatedOutput = task.result;
                    if let user_in_Groups = paginatedOutput?.items as? [AWSUser_in_Group]{
                        print("paginatedOutput \(user_in_Groups)")
                        
                        if (user_in_Groups.count > 0){
                            self.idUsers = []
                            for i in 0 ..< user_in_Groups.count {
                                if let idFacebook = user_in_Groups[i].idUser{
                                    self.idUsers.append(idFacebook)
                                }
                            }
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableViewReloadData()
                            }
                            return nil
                        }
                    }
                }
                
                return nil
                
            }).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                dispatch_async(dispatch_get_main_queue()) {
                    self.refreshControl?.endRefreshing()
                }
                return nil
            })
        }
        
    }
    
    func tableViewReloadData(){
        self.tableView.reloadData()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 40, 0)
        
        if let date = getDateFromGroup() {
            //Initialisation du label date
            let fmt = NSDateFormatter()
            fmt.dateStyle = NSDateFormatterStyle.FullStyle
            fmt.timeStyle = NSDateFormatterStyle.NoStyle
            self.infoDateLabel.hidden = false
            self.infoDateLabel.text = fmt.stringFromDate(date)
        }
        else{
            self.infoDateLabel.hidden = true
        }
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return idUsers.count + 1
        }
        else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0){
            return "Your group".localized
        }
        else {
            return "The other group".localized
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            if (indexPath.row < idUsers.count){
                var cell:AlbumCell! = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath) as! AlbumCell
                if cell == nil {
                    tableView.registerNib(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
                    cell = tableView.dequeueReusableCellWithIdentifier("UserCell") as? AlbumCell
                }
                self.configureUserCell(cell, atIndexPath: indexPath)
                return cell
            }
            else {
                let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("NewBlockedCell", forIndexPath: indexPath)
                return cell
            }
        }
        else{
            let cell:UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("SuggestionsCell", forIndexPath: indexPath)
            return cell
        }
    }
    
    
    func configureUserCell(cell: AlbumCell, atIndexPath indexPath : NSIndexPath){
        
        let idUser = idUsers[indexPath.row]
        if idUser == AWSManager.sharedInstance.idFacebook {
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        if let user = usersDict[idUser]{
            configureUserCell(cell, withUser: user)
        }
        else{
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.load(AWSUser.self, hashKey: idUser, rangeKey: nil).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                if let user = task.result as? AWSUser{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.usersDict[idUser] = user;
                        self.configureUserCell(cell, withUser: user)
                    }
                }
                return nil
            })
        }
    }
    
    func configureUserCell(cell: AlbumCell, withUser user : AWSUser){
        if let firstName = user.firstName{
            cell.title.text = firstName
        }
        cell.illustrationView.setProfilePicture(user)
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if (section == 0){
            return "If you add a friend to your group, we will give you back 2 Credits".localized
        }
            
        else if (section == 1){
            //return "Help us choose the best group for your evening"
            return nil
        }
        else{
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0){
            if (indexPath.row < idUsers.count){
                let idUser = idUsers[indexPath.row]
                if idUser == AWSManager.sharedInstance.idFacebook {
                    
                    let alertView = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
                    let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                        
                    })
                    
                    let leaveGroupAction = UIAlertAction(title: "Leave group".localized, style: UIAlertActionStyle.Destructive, handler: {(action: UIAlertAction!) -> Void in
                        self.leaveGroup()
                    })
                    
                    alertView.addAction(cancelAction)
                    alertView.addAction(leaveGroupAction)
                    
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
                else{
                    if let user = usersDict[idUser]{
                        presentGalerieViewController(user)
                    }
                    else{
                        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                        dynamoDBObjectMapper.load(AWSUser.self, hashKey: idUser, rangeKey: nil).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            if let user = task.result as? AWSUser{
                                dispatch_async(dispatch_get_main_queue()) {
                                    self.usersDict[idUser] = user;
                                    self.presentGalerieViewController(user)
                                }
                            }
                            return nil
                        })
                    }
                }
            }
            else{
                
                if (self.idUsers.count < self.maxNbUsersInGroup && self.user_in_group != nil){
                    self.performSegueWithIdentifier("AddFriendVC", sender: self)
                }
                else{
                    self.view.makeToast("Groups are limited to 3 people max".localized)
                }
                
            }
        }
        else if (indexPath.section == 1){
            self.performSegueWithIdentifier("SuggestionsVC", sender: self)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func leaveGroup(){
        if let idUser = user_in_group?.idUser, dateString = user_in_group?.dateString, groupPartitionKey = user_in_group?.groupPartitionKey, groupSortKey = user_in_group?.groupSortKey{
            //if let _ = self.group!.otherGroupSortKey{
            if (false){
                
                let alertView = UIAlertController(title: "Your group is matched.".localized, message: "You cannot leave a matched group.".localized, preferredStyle: UIAlertControllerStyle.Alert)
                alertView.addAction(UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                }))
                self.presentViewController(alertView, animated: true, completion: nil)
                
            }
                
            else{
                
                let alertView = UIAlertController(title: "Leave group?".localized, message: "Are you sur you want to leave the group?".localized, preferredStyle: UIAlertControllerStyle.Alert)
                let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
                })
                let doAction = UIAlertAction(title: "Leave".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                    
                    self.tableView.makeToastActivity()
                    
                    let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                    let jsonObject = [
                        "idUser": idUser,
                        "dateString": dateString,
                        "groupSortKey":groupSortKey,
                        "groupPartitionKey":groupPartitionKey
                    ]
                    
                    lambdaInvoker.invokeFunction("AWSleaveGroup", JSONObject: jsonObject).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        dispatch_async(dispatch_get_main_queue()) {
                            self.tableView.hideToastActivity()
                            if let _ = task.error{
                                self.view.makeToast("An error occured".localized)
                            }
                            else{
                                if let _ = task.result as? NSDictionary{
                                    MeetingManager.sharedInstance.logOut()
                                    self.containerViewController?.updateCurrentViewController(nil)
                                }
                            }
                        }
                        return nil
                    })
                    
                })
                
                alertView.addAction(cancelAction)
                alertView.addAction(doAction)
                
                self.presentViewController(alertView, animated: true, completion: nil)
                
            }
        }
    }
    
    func presentGalerieViewController(user:AWSUser){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let utilisateurGalerieViewController = storyboard.instantiateViewControllerWithIdentifier("UtilisateurGalerieViewController") as! UtilisateurGalerieViewController
        utilisateurGalerieViewController.user = user
        self.presentViewController(utilisateurGalerieViewController, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 0 && indexPath.row < idUsers.count){
            return 80
        }
        else {
            return 40
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let addFriendViewController = segue.destinationViewController as? AddFriendViewController{
            addFriendViewController.idUsersInGroup = idUsers
            addFriendViewController.user_in_Group = user_in_group
            addFriendViewController.nbUserInGroup = idUsers.count
            addFriendViewController.bodyMessage = getBodyMessage()
            addFriendViewController.delegate = self
        }
            
        else if let dest = segue.destinationViewController as? SuggestionsViewController{
            dest.countUsersInGroup = idUsers.count
            if let date = getDateFromGroup() {
                dest.dateGroup = date.toYYYYMMdd()
            }
        }
        
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func shareButton(sender: AnyObject) {
        let bodyMessage = getBodyMessage()
        messageComposeViewController.body = bodyMessage;
        messageComposeViewController.recipients = []
        messageComposeViewController.messageComposeDelegate = self;
        self.presentViewController(messageComposeViewController, animated: true, completion: {() -> Void in
            self.tableView.hideToastActivity()
        });
        FBSDKAppEvents.logEvent(FBSDKAppEventsCustom.INVITE_FRIEND, parameters: [FBSDKAppEventParameterCustom.TYPE: FBSDKAppEventParameterCustom.SMS, FBSDKAppEventParameterCustom.WHERE_IN_APP: FBSDKAppEventParameterCustom.SHARE_EVENING_INFORMATION])
    }
    
    
    func getBodyMessage() -> String {
        
        var bodyMessage: String = urls.ContentURL
        
        if let myUser_in_group = self.user_in_group {
            //Initialisation du body message
            //Date
            
            if let date = myUser_in_group.dateString?.getDateYYYYMMdd(), isBoy = self.user?.isBoy {
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale.currentLocale()
                
                formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                formatter.timeStyle = NSDateFormatterStyle.NoStyle
                
                bodyMessage = "Let's go out on %@".localizedStringWithVariables(formatter.stringFromDate(date))
                bodyMessage = bodyMessage + " "
                
                if (isBoy.boolValue){
                    bodyMessage = bodyMessage + "with a group of girls".localized
                }
                else{
                    bodyMessage = bodyMessage + "with a group of guys".localized
                }
                
                bodyMessage = bodyMessage + " ? "
                
                //More info
                bodyMessage = bodyMessage + "\n\n" + "If you want to join us, download the app at http://www.youtuesday.com".localized
                
            }
            
        }
        
        return bodyMessage;
    }
    
    // MARK - MFMessageComposeViewControllerDelegate
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch(result.rawValue){
        case MessageComposeResultCancelled.rawValue:
            break;
        case MessageComposeResultSent.rawValue:
            self.tableView.makeToast("SMS successfully sent".localized, duration: 2.0, position: "center")
            break;
        case MessageComposeResultFailed.rawValue:
            self.tableView.makeToast("An error occured".localized, duration: 2.0, position: "center")
            break;
        default:
            break;
            
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //AddFriendViewControllerDelegate
    func didAddFriend(idUserNewMember:String){
        self.idUsers.append(idUserNewMember)
        self.tableViewReloadData()
    }
}