//
//  EveningViewController.swift
//  Friday
//
//  Created by Christopher Rydahl on 13/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation
import MessageUI

class MeetingViewController: UITableViewController, UIActionSheetDelegate, UIAlertViewDelegate, MFMessageComposeViewControllerDelegate, AddFriendViewControllerDelegate {
    
    var actionSheetAddress: UIActionSheet?
    var actionSheetBar: UIActionSheet?
    
    var bar: AWSBar?
    
    var idUsers: [String] = []
    var otherGroupIdUsers: [String] = []
    var usersDict: [String:AWSUser] = [:]
    
    var chatViewController : ChatViewController?
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTimeSubtitle: UILabel!
    @IBOutlet weak var labelBarName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var infoDateLabel: UILabel!
    
    @IBOutlet weak var myGroupImageView1: AWSButtonImage!
    @IBOutlet weak var myGroupImageView2: AWSButtonImage!
    @IBOutlet weak var myGroupImageView3: AWSButtonImage!
    @IBOutlet weak var otherGroupImageView1: AWSButtonImage!
    @IBOutlet weak var otherGroupImageView2: AWSButtonImage!
    @IBOutlet weak var otherGroupImageView3: AWSButtonImage!
    
    var myGroupImageViews: [AWSButtonImage] = []
    var otherGroupImageViews: [AWSButtonImage] = []
    
    @IBOutlet weak var labelMyUserConfirmation: UILabel!
    @IBOutlet weak var labelOtherUserConfirmation: UILabel!
    
    @IBOutlet weak var myUserConfirmationCell: UITableViewCell!
    @IBOutlet weak var newMessageChatLabel2: UILabel!
    @IBOutlet weak var sendMessageLabel: UILabel!
    
    
    var myGroup: AWSGroup?
    var otherGroup:AWSGroup?
    var user_in_group: AWSUser_in_Group?
    var tuesday:AWSTuesday?
    var user: AWSUser?
    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
    
    let redColor = UIColor(red: 255/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    let greenColor = UIColor(red: 0/255.0, green: 155/255.0, blue: 0/255.0, alpha: 1.0)
    
    var containerViewController: ContainerViewController?
    var messageComposeViewController = MFMessageComposeViewController();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(60, 0, 40, 0)
        
        myGroupImageViews = [myGroupImageView1, myGroupImageView2, myGroupImageView3]
        otherGroupImageViews = [otherGroupImageView1, otherGroupImageView2, otherGroupImageView3]
        
        actionSheetAddress = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel".localized, destructiveButtonTitle: nil, otherButtonTitles: "Copy the address".localized)
        for routingApp in RoutingAppManager.sharedInstance.routingApps{
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: routingApp.url)!){
                actionSheetAddress?.addButtonWithTitle(routingApp.name)
            }
        }
        
        actionSheetBar = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel".localized, destructiveButtonTitle: nil, otherButtonTitles: "Foursquare".localized)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        chatViewController = storyboard.instantiateViewControllerWithIdentifier("ChatViewController") as? ChatViewController
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.meetingViewController = self
        
        initialisation()
        setIsConfirmedMyGroup()
        
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            self.user = user
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //updateChat()
    }
    
    func initialisation(){
        if let dashboardKey = myGroup?.dashboardKey, otherGroupSortKey = myGroup?.otherGroupSortKey, sortKey = myGroup?.sortKey{
            getOtherGroup()
            getTuesday()
            getUserInGroup(dashboardKey, groupSortKey: sortKey, isMyGroup: true)
            if let otherGroupDashboardKey = getOtherGroupDashboardKey(){
                getUserInGroup(otherGroupDashboardKey, groupSortKey: otherGroupSortKey, isMyGroup: false)
            }
        }
    }
    
    func getOtherGroup(){
        if let otherGroupDashboardKey = getOtherGroupDashboardKey(), otherGroupSortKey = myGroup?.otherGroupSortKey{
            
            dynamoDBObjectMapper.load(AWSGroup.self, hashKey: otherGroupDashboardKey, rangeKey: otherGroupSortKey).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                
                if let otherGroup = task.result as? AWSGroup{
                    
                    self.otherGroup = otherGroup
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.setIsConfirmedOtherGroup()
                    }
                    
                }
                
                return nil
            })
        }
    }
    
    func getOtherGroupDashboardKey() -> String?{
        if let dashboardKey = myGroup?.dashboardKey{
            
            let dashboardKeyArr = dashboardKey.componentsSeparatedByString("//")
            var otherGroupDashboardKey = dashboardKeyArr[0] + "//" + dashboardKeyArr[1] + "//"
            otherGroupDashboardKey = otherGroupDashboardKey + (dashboardKeyArr[2] == "1" ? "2" : "1")
            return otherGroupDashboardKey
            
        }
        return nil
    }
    
    func getTuesday(){
        print("getTuesday")
        if let dashboardKeyGroup = myGroup?.dashboardKey, otherGroupSortKey = myGroup?.otherGroupSortKey, sortKey = myGroup?.sortKey{
            let tuesdaySortKey = MeetingManager.sharedInstance.getTuesdaySortKey(sortKey, otherGroupSortKey: otherGroupSortKey)
            let dashboardKeyGroupArray = dashboardKeyGroup.componentsSeparatedByString("//")
            let dashboardKeyTuesday = dashboardKeyGroupArray[0] + "//" + dashboardKeyGroupArray[1]
            dynamoDBObjectMapper.load(AWSTuesday.self, hashKey: dashboardKeyTuesday, rangeKey: tuesdaySortKey).continueWithSuccessBlock({ (task:AWSTask) -> AnyObject? in
                
                if let tuesday = task.result as? AWSTuesday{
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tuesday = tuesday
                        if let idBar = tuesday.idBar{
                            self.getBar(idBar)
                        }
                        
                        let formatter = NSDateFormatter()
                        formatter.locale = NSLocale.currentLocale()
                        
                        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
                        //formatter.timeZone = NSTimeZone(name: "UTC")
                        
                        if let date = self.tuesday?.dateString?.getDateYYYYMMddHHmm() {
                            let (title, subtitle) = DateManager.getTitleSubtitleFromDate(date)
                            self.labelTime.text = title
                            self.labelTimeSubtitle.text = subtitle
                            
                            let fmt = NSDateFormatter()
                            fmt.dateStyle = NSDateFormatterStyle.MediumStyle
                            fmt.timeStyle = NSDateFormatterStyle.ShortStyle
                            
                            self.infoDateLabel.hidden = false
                            self.infoDateLabel.text = fmt.stringFromDate(date)
                        }
                        
                    }
                    
                }
                
                return nil
            })
        }
    }
    
    func getUserInGroup(groupPartitionKey:String, groupSortKey:String, isMyGroup:Bool){
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.hashKeyAttribute = "groupPartitionKey"
        queryExpression.hashKeyValues = groupPartitionKey
        queryExpression.rangeKeyConditionExpression = "groupSortKey = :groupSortKey"
        queryExpression.expressionAttributeValues = [":groupSortKey":groupSortKey]
        
        queryExpression.limit = 3
        queryExpression.indexName = "getUserFromGroupIndex"
        
        dynamoDBObjectMapper.query(AWSUser_in_Group.self, expression: queryExpression).continueWithBlock({ (task:AWSTask) -> AnyObject? in
            
            print("taskerror \(task.error)")
            print("taskexception \(task.exception)")
            if task.error == nil{
                let paginatedOutput = task.result;
                if let user_in_Groups = paginatedOutput?.items as? [AWSUser_in_Group]{
                    print("paginatedOutput \(user_in_Groups)")
                    
                    if (user_in_Groups.count > 0){
                        
                        if isMyGroup {
                            
                            self.idUsers = []
                            for i in 0 ..< user_in_Groups.count {
                                if let idFacebook = user_in_Groups[i].idUser{
                                    self.idUsers.append(idFacebook)
                                }
                            }
                        }
                        else{
                            self.otherGroupIdUsers = []
                            for i in 0 ..< user_in_Groups.count {
                                if let idFacebook = user_in_Groups[i].idUser{
                                    self.otherGroupIdUsers.append(idFacebook)
                                }
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
    
    func tableViewReloadData(){
        for (var i = 0; i < idUsers.count; i++){
            setProfilePicture(idUsers[i], buttonImage: myGroupImageViews[i])
        }
        for (var i = 0; i < otherGroupIdUsers.count; i++){
            setProfilePicture(otherGroupIdUsers[i], buttonImage: otherGroupImageViews[i])
        }
    }
    
    func setProfilePicture(idUser: String, buttonImage: AWSButtonImage){
        if let user = usersDict[idUser]{
            buttonImage.setProfilePicture(user)
        }
        else{
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.load(AWSUser.self, hashKey: idUser, rangeKey: nil).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                if let user = task.result as? AWSUser{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.usersDict[idUser] = user;
                        buttonImage.setProfilePicture(user)
                    }
                }
                return nil
            })
        }
    }
    
    func getBar(idVenue: String){
        print("getBar \(idVenue)")
        
        dynamoDBObjectMapper.load(AWSBar.self, hashKey: idVenue, rangeKey: nil).continueWithBlock { (task:AWSTask) -> AnyObject? in
            print("task.result \(task.result)")
            print("exception \(task.exception)")
            print("error \(task.error)")
            
            if let bar = task.result as? AWSBar {
                
                print("getBar \(bar)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.bar = bar
                    
                    self.labelBarName.text = bar.name
                    self.labelAddress.text = bar.address
                }
                
            }
            
            return nil
        }
    }
    
    
    
    
    func syncChatMeeting(){
        
        if let chatViewController = self.chatViewController{
            chatViewController.refresh()
        }
        
        //self.updateChat(isAllSeen: false)
        
    }
    
    
    func updateChat(){
        
        /*if let idChat = AWSManager.sharedInstance.getIdChat(meeting){
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        let queryExpression = AWSDynamoDBQueryExpression()
        
        queryExpression.hashKeyAttribute = "idChat"
        queryExpression.hashKeyValues = idChat
        
        //dans l'ordre décroissant de dateString
        queryExpression.scanIndexForward = false
        queryExpression.limit = 1
        
        dynamoDBObjectMapper.query(AWSMessageChat.self, expression: queryExpression).continueWithBlock { (task:AWSTask) -> AnyObject? in
        
        dispatch_async(dispatch_get_main_queue()) {
        
        print("updateChatupdateChat 2")
        
        if let paginatedOutput = task.result as? AWSDynamoDBPaginatedOutput {
        if let messageChats = paginatedOutput.items as? [AWSMessageChat] {
        
        if messageChats.count > 0 {
        
        let messageChat = messageChats[0]
        print("updateChatupdateChat messageChat: \(messageChat)")
        if let messageChatCreatedAt = messageChat.createdAtString?.getDateYYYYMMddHHmmssInUTC(){
        if let dateChatAllSeen = self.meeting?.dateChatAllSeenString?.getDateYYYYMMddHHmmssInUTC(){
        self.updateChat(isAllSeen: !dateChatAllSeen.isLess(messageChatCreatedAt))
        }
        else{
        self.updateChat(isAllSeen: false)
        }
        }
        
        }
        
        else{
        
        self.updateChat(isAllSeen: true)
        
        }
        
        }
        }
        
        }
        return nil
        }
        
        }
        
        else{
        self.updateChat(isAllSeen: true)
        }*/
        
    }
    
    func updateChat(isAllSeen _isAllSeen: Bool){
        if (_isAllSeen){
            self.sendMessageLabel.font = UIFont(name:"HelveticaNeue", size: 17.0)
            self.newMessageChatLabel2.hidden = true
        }
        else{
            self.sendMessageLabel.font = UIFont(name:"HelveticaNeue-Medium", size: 17.0)
            self.newMessageChatLabel2.hidden = false
        }
    }
    
    
    
    func setIsConfirmedMyGroup(){
        if let isParticipationConfirmed = self.myGroup?.isParticipationConfirmed {
            
            if isParticipationConfirmed.boolValue {
                labelMyUserConfirmation.textColor = greenColor
                labelMyUserConfirmation.text = "Participation confirmed".localized
                self.myUserConfirmationCell.accessoryType = UITableViewCellAccessoryType.None
                return
            }
            
        }
        
        labelMyUserConfirmation.textColor = redColor
        labelMyUserConfirmation.text = "Participation non confirmed".localized
        self.myUserConfirmationCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
    }
    
    func setIsConfirmedOtherGroup(){
        if let isParticipationConfirmed = self.otherGroup?.isParticipationConfirmed {
            
            if isParticipationConfirmed.boolValue {
                self.labelOtherUserConfirmation.textColor = self.greenColor
                self.labelOtherUserConfirmation.text = "Participation confirmed".localized
                return
            }
        }
        
        self.labelOtherUserConfirmation.textColor = self.redColor
        self.labelOtherUserConfirmation.text = "Participation non confirmed".localized
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row){
            
        case (0, 0):
            self.chatButton()
            break;
            
        case (1,1):
            actionSheetBar!.showInView(self.tableView)
            break;
            
        case (1,2):
            actionSheetAddress!.showInView(self.tableView)
            break;
            
        case (2,1):
            if let isParticipationConfirmed = self.myGroup?.isParticipationConfirmed {
                if isParticipationConfirmed.boolValue {
                    return
                }
            }
            
            let alertView = UIAlertController(title: "Confirm your participation".localized, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: UIAlertActionStyle.Cancel, handler: {(action: UIAlertAction) -> Void in
            })
            let doAction = UIAlertAction(title: "OK".localized, style: UIAlertActionStyle.Default, handler: {(action: UIAlertAction!) -> Void in
                
                if let dashboardKey = self.myGroup?.dashboardKey, sortKey = self.myGroup?.sortKey{
                    let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                    let jsonObject = [
                        "dashboardKey": dashboardKey,
                        "sortKey": sortKey,
                        "idOtherUsers": self.otherGroupIdUsers
                    ]
                    
                    lambdaInvoker.invokeFunction("AWSsetIsConfirmed", JSONObject: jsonObject).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        dispatch_async(dispatch_get_main_queue()) {
                            print("taskerror \(task.error)")
                            print("taskexception \(task.exception)")
                            if let error = task.error{
                                print("taskerror \(error)")
                                self.view.makeToast("An error occured".localized)
                            }
                            else{
                                if let result = task.result as? NSDictionary{
                                    if let isOk = result["isOk"] as? Bool{
                                        if (isOk){
                                            self.myGroup?.isParticipationConfirmed = NSNumber(bool:true)
                                            self.setIsConfirmedMyGroup()
                                        }
                                    }
                                }
                            }
                        }
                        return nil
                    })
                    
                }
                
                
            })
            
            alertView.addAction(cancelAction)
            alertView.addAction(doAction)
            
            self.presentViewController(alertView, animated: true, completion: nil)
            break;
            
        default:
            break;
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func chatButton() {
        
        var idOtherUsers: [String] = []
        for (var i = 0; i < idUsers.count; i++){
            if (idUsers[i] != AWSManager.sharedInstance.idFacebook){
                idOtherUsers.append(idUsers[i])
            }
        }
        for (var i = 0; i < otherGroupIdUsers.count; i++){
            idOtherUsers.append(otherGroupIdUsers[i])
        }
        chatViewController?.idOtherUsers = idOtherUsers
        chatViewController?.usersDict = self.usersDict
        chatViewController?.tuesday = self.tuesday
        if let chatViewController = chatViewController{
            self.navigationController?.pushViewController(chatViewController, animated: true)
            self.updateChat(isAllSeen: true)
        }
    }
    
    
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if (actionSheet.isEqual(self.actionSheetBar)){
            if (buttonIndex == 0){
                return;
            }
            else if (buttonIndex == 1){
                self.performSegueWithIdentifier("FoursquareVC", sender: self)
            }
        }
        else if (actionSheet.isEqual(self.actionSheetAddress)){
            //cancel
            if (buttonIndex == 0){
                return;
            }
                
                //copy
            else if (buttonIndex == 1){
                if let bar = self.bar {
                    let pb = UIPasteboard.generalPasteboard()
                    pb.string = bar.address
                    self.view.makeToast("Address copied".localized, duration: 2.0, position: "center")
                }
                return;
            }
            
            
            let index = buttonIndex - 2
            if (index < RoutingAppManager.sharedInstance.routingApps.count){
                let routingApp = RoutingAppManager.sharedInstance.routingApps[index]
                var url2 = routingApp.url2
                
                if let latitudeBar = bar?.latitude, longitureBar = bar?.longitude, name = bar?.name{
                    
                    url2 = url2.stringByReplacingOccurrencesOfString("%alat", withString: latitudeBar.stringValue, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    url2 = url2.stringByReplacingOccurrencesOfString("%along", withString: longitureBar.stringValue, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    url2 = url2.stringByReplacingOccurrencesOfString("%aname", withString: name, options: NSStringCompareOptions.LiteralSearch, range: nil)
                    print(url2)
                    print(routingApp.url)
                    url2 = routingApp.url + url2
                    url2 = url2.stringByReplacingOccurrencesOfString(" ", withString: "+")
                    if let nsurl = NSURL(string: url2){
                        UIApplication.sharedApplication().openURL(nsurl)
                    }
                    
                }
            }
        }
        
        
    }
    
    
    // Mark - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let foursquareViewController = segue.destinationViewController as? FoursquareViewController{
            if let bar = bar{
                foursquareViewController.idVenue = bar.idVenue
                foursquareViewController.idClient = bar.idFoursquareClient
            }
        }
            
        else if let addFriendViewController = segue.destinationViewController as? AddFriendViewController{
            addFriendViewController.idUsersInGroup = idUsers
            addFriendViewController.user_in_Group = user_in_group
            addFriendViewController.nbUserInGroup = idUsers.count
            addFriendViewController.bodyMessage = getBodyMessage()
            addFriendViewController.delegate = self
        }
    }
    
    @IBAction func myGroupImageView(sender: AnyObject) {
        if let tag = sender.tag{
            if tag < idUsers.count{
                self.clickOnImageView(sender, idUsers: self.idUsers)
            }
            else{
                self.performSegueWithIdentifier("AddFriendVC2", sender: self)
            }
        }
    }
    
    @IBAction func otherGroupImageView(sender: AnyObject) {
        self.clickOnImageView(sender, idUsers: self.otherGroupIdUsers)
    }
    
    func clickOnImageView(sender: AnyObject, idUsers: [String]){
        if let tag = sender.tag{
            if tag < idUsers.count{
                let idUser = idUsers[tag]
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
    }
    
    
    
    func presentGalerieViewController(user:AWSUser){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let utilisateurGalerieViewController = storyboard.instantiateViewControllerWithIdentifier("UtilisateurGalerieViewController") as! UtilisateurGalerieViewController
        utilisateurGalerieViewController.user = user
        self.presentViewController(utilisateurGalerieViewController, animated: true, completion: nil)
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
        
        if let tuesday = self.tuesday {
            //Initialisation du body message
            //Date
            
            if let date = tuesday.dateString?.getDateYYYYMMddHHmm(), isBoy = self.user?.isBoy {
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale.currentLocale()
                
                formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle

                bodyMessage = "Let's go out on %@".localizedStringWithVariables(formatter.stringFromDate(date))
                bodyMessage = bodyMessage + " "
            
                if (isBoy.boolValue){
                    bodyMessage = bodyMessage + "with a group of girls".localized
                }
                else{
                    bodyMessage = bodyMessage + "with a group of guys".localized
                }
                
                bodyMessage = bodyMessage + " ? "
            
                if let barName = self.bar?.name, barAddress = self.bar?.address {
                    bodyMessage = bodyMessage + "We will meet at %@ (%@).".localizedStringWithVariables(barName, barAddress)
                }
                
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

extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
}

