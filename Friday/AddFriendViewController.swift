//
//  AddFriendViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 08/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation
import MessageUI
import AddressBook


class AddFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FBSDKAppInviteDialogDelegate, MFMessageComposeViewControllerDelegate, FBSDKSharingDelegate, MFMailComposeViewControllerDelegate, UIPopoverPresentationControllerDelegate {
    
    let LETTER_INVITE_TO_APP: String = "Invite to Tuesday App"
    let appLinkURL: String = "https://fb.me/1618300485088522"
    
    var friends : [FacebookFriend] = []
    var group : AWSGroup?
    var nbUserInGroup: Int = 1
    let maxNbUsersInGroup: Int = 3
    var userSelected:FacebookFriend?
    var user: AWSUser?
    
    var user_in_Group: AWSUser_in_Group?
    
    var bodyMessage: String = "Join me on Tuesday"
    var idUsersInGroup: [String] = []
    
    @IBOutlet weak var recapSendViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var noFriendView: UIView!
    @IBOutlet weak var recapSendView: RecapSendView!
    @IBOutlet weak var viewActivityIndicator: UIView!
    @IBOutlet weak var inviteFriendView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl:UIRefreshControl = UIRefreshControl()
    
    var filteredTableData : NSMutableDictionary = NSMutableDictionary()
    var letters : NSMutableArray = []
    
    var messageComposeViewController = MFMessageComposeViewController();
    var mailComposeViewController = MFMailComposeViewController();
    
    var addressBookContacts : [AddressBookContact] = []
    
    var delegate: AddFriendViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let currentUser = user{
                self.user = currentUser
            }
        }
        
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        refreshControl.tintColor = UIColor.lightGrayColor()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localized)
        refreshControl.addTarget(self, action: #selector(AddFriendViewController.refreshFriends(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
        getFriendsOnParse();
        
        getAddressBook();
    }
    
    
    func getFriendsOnParse(){
        
        FacebookManager.sharedInstance.refreshFriend { (previousCountFriends) -> Void in
            
            self.friends = FacebookManager.sharedInstance.friends
            self.updateTable("")
            self.viewActivityIndicator.hidden = true
            
        }
        
    }
    
    func refreshFriends(sender: AnyObject) {
        if let refreshControl = sender as? UIRefreshControl{
            
            FacebookManager.sharedInstance.refreshFriend({ (previousCountFriends) -> Void in
                self.getFriendsOnParse()
                refreshControl.endRefreshing()
                
                /*let countFriends = FacebookManager.sharedInstance.idFacebookFriends.count
                let diff = countFriends - previousCountFriends;
                if (diff <= 0){
                self.view.makeToast("We didn't find any new friend on Tuesday".localized)
                }else if (diff == 1){
                self.view.makeToast("1 new friend on Tuesday".localized)
                }else{
                self.view.makeToast("%d new friends on Tuesday".localizedStringWithVariables(countFriends - previousCountFriends))
                }*/
                
            })
            
            
        }
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.registerForKeyboardNotifications()
    }
    
    
    func registerForKeyboardNotifications(){
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFriendViewController.keyboardWasShown(_:)), name: UIKeyboardDidShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(AddFriendViewController.keyboardWillBeHidden(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardWasShown (notification: NSNotification) {
        
        let info : NSDictionary = notification.userInfo!
        let keyboardSize = info.objectForKey(UIKeyboardFrameBeginUserInfoKey)?.CGRectValue
        
        recapSendViewBottomLayout.constant = keyboardSize!.height
        recapSendView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.recapSendView.layoutIfNeeded()
        }
    }
    
    func keyboardWillBeHidden (notification: NSNotification) {
        
        recapSendViewBottomLayout.constant = 0
        recapSendView.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(0.5) { () -> Void in
            self.recapSendView.layoutIfNeeded()
        }
        
    }
    
    
    func getAddressBook(){
        swiftAddressBook?.requestAccessWithCompletion({ (success, error) -> Void in
            if success {
                //do something with swiftAddressBook
                if let people = swiftAddressBook?.allPeople {
                    for person in people {
                        if let labelPhoneNumbers = person.phoneNumbers?.map( {$0.label} ), let valuePhoneNumbers = person.phoneNumbers?.map( {$0.value}){
                            
                            let count = labelPhoneNumbers.count
                            
                            let lastName = person.lastName
                            let firstName = person.firstName
                            
                            if (firstName == nil || firstName == ""){
                                continue;
                            }
                            
                            var email :String? = nil
                            if let valueEmails = person.emails?.map( {$0.value} ){
                                if (valueEmails.count > 0){
                                    email = valueEmails[0]
                                }
                            }
                            
                            for i in 0 ..< count {
                                
                                if (labelPhoneNumbers[i] == "_$!<Mobile>!$_"){
                                    
                                    let mobilePhone = valuePhoneNumbers[i]
                                    let contact = AddressBookContact(fromLastName: lastName, fromFirstName: firstName, fromMobilePhone: mobilePhone, fromEmail: email)
                                    self.addressBookContacts.append(contact)
                                    break;
                                }
                                
                            }
                            
                        }
                        
                    }
                    print("addressBookContacts \(self.addressBookContacts.count)")
                }
            }
            else {
                //no success. Optionally evaluate error
                print("error requestAccessWithCompletion \(error)")
            }
        })
    }
    
    
    
    // MARK: - TableView
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return letters.count
        
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(letters.count > 0){
            let str = letters[section] as! String
            return String(str)
        }else{
            return nil
        }
    }
    
    //Pour ajouter une index list
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        let count = letters.count
        if(count > 0){
            var indexes :[String] = []
            
            for i in 0 ..< count {
                let letter = letters[i] as! String
                if (letter != LETTER_INVITE_TO_APP){
                    indexes.append(letter)
                }
            }
            return indexes
        }else{
            return nil
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if let letter : NSString = self.letters[section] as? NSString{
            if let f :NSMutableArray = filteredTableData[letter] as? NSMutableArray{
                return f.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let letter : NSString = self.letters[indexPath.section] as? NSString{
            if let f :NSMutableArray = filteredTableData[letter] as? NSMutableArray{
                
                if let facebookFriend: FacebookFriend = f[indexPath.row] as? FacebookFriend{
                    var cell:AddFriendCell! = tableView.dequeueReusableCellWithIdentifier("AddFriendCell", forIndexPath: indexPath) as! AddFriendCell
                    if cell == nil {
                        tableView.registerNib(UINib(nibName: "AddFriendCell", bundle: nil), forCellReuseIdentifier: "AddFriendCell")
                        cell = tableView.dequeueReusableCellWithIdentifier("AddFriendCell") as? AddFriendCell
                    }
                    self.configureAddFriendCell(cell, withFacebookFriend: facebookFriend)
                    return cell
                }
                    
                else if let contact = f[indexPath.row] as? AddressBookContact{
                    var cell:InviteFriendCell! = tableView.dequeueReusableCellWithIdentifier("InviteFriendCell", forIndexPath: indexPath) as! InviteFriendCell
                    if cell == nil {
                        tableView.registerNib(UINib(nibName: "InviteFriendCell", bundle: nil), forCellReuseIdentifier: "InviteFriendCell")
                        cell = tableView.dequeueReusableCellWithIdentifier("InviteFriendCell") as? InviteFriendCell
                    }
                    configureInviteFriendCell(cell, withContact: contact)
                    
                    return cell
                }
                
            }
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(letters.count > 0){
            return 60
        }else{
            return UIScreen.mainScreen().bounds.size.height - self.navigationController!.navigationBar.frame.height*3
        }
    }
    
    func configureAddFriendCell(cell: AddFriendCell, withFacebookFriend facebookFriend: FacebookFriend) {
        
        cell.facebookFriend = facebookFriend
        cell.label.text = facebookFriend.name
        cell.isCellSelected = (facebookFriend.idFacebook == userSelected?.idFacebook)
        cell.setUp()
        
    }
    
    func configureInviteFriendCell(cell: InviteFriendCell, withContact contact: AddressBookContact) {
        
        cell.addressBookContact = contact
        cell.label.text = contact.name
        
    }
    
    func updateTable(searchText: String){
        filteredTableData = NSMutableDictionary()
        
        for user in self.friends {
            
            let name = user.name as NSString
            
            if (isMatchSearchText(searchText, name: name)){
                // Find the first letter of the food's name. This will be its gropu
                let firstLetter = name.substringToIndex(1);
                
                // Check to see if we already have an array for this group
                if let arrayForLetter : NSMutableArray = self.filteredTableData.objectForKey(firstLetter) as? NSMutableArray{
                    arrayForLetter.addObject(user)
                }else{
                    let arrayForLetter = NSMutableArray()
                    arrayForLetter.addObject(user)
                    self.filteredTableData.setObject(arrayForLetter, forKey: firstLetter)
                }
            }
        }
        
        //On trie les lettres dans l'ordre alphabétique
        if let allKeys:[NSString] = self.filteredTableData.allKeys as? [NSString]{
            letters = NSMutableArray(array: allKeys.sort{ $0.localizedCaseInsensitiveCompare($1 as String) == NSComparisonResult.OrderedAscending })
        }
        
        
        //Si il n'y a pas d'amis facebook on présente les amis du répertoire
        //if (self.filteredTableData.count == 0){
        for contact in self.addressBookContacts {
            
            if (isMatchSearchText(searchText, name: contact.name)){
                
                // Find the first letter of the food's name. This will be its gropu
                let firstLetter = LETTER_INVITE_TO_APP;
                
                // Check to see if we already have an array for this group
                if let arrayForLetter : NSMutableArray = self.filteredTableData.objectForKey(firstLetter) as? NSMutableArray{
                    arrayForLetter.addObject(contact)
                }else{
                    let arrayForLetter = NSMutableArray()
                    arrayForLetter.addObject(contact)
                    self.filteredTableData.setObject(arrayForLetter, forKey: firstLetter)
                }
            }
        }
        
        if (self.filteredTableData.objectForKey(LETTER_INVITE_TO_APP)?.count > 0){
            letters.addObject(LETTER_INVITE_TO_APP)
        }
        //}
        
        //On trie les personnes dans chaque section dans l'ordre alphabétique
        let count = letters.count
        for i in 0 ..< count {
            let letter = letters[i]
            if let array = self.filteredTableData.objectForKey(letter) as? NSMutableArray{
                array.sortUsingComparator({ (a:AnyObject, b: AnyObject) -> NSComparisonResult in
                    if let a = a as? FacebookFriend, let b = b as? FacebookFriend{
                        let nameA = a.name
                        let nameB = b.name
                        return nameA.compare(nameB)
                    }
                    
                    if let a = a as? AddressBookContact, let b = b as? AddressBookContact{
                        let nameA = a.name
                        let nameB = b.name
                        return nameA.compare(nameB)
                    }
                    
                    return NSComparisonResult.OrderedSame
                })
            }
        }
        
        
        self.tableView.reloadData()
        self.inviteFriendView.hidden = (self.letters.count == 0) || (userSelected != nil)
        self.tableView.hidden = (self.letters.count == 0)
    }
    
    func isMatchSearchText(searchString: String,name: NSString) -> Bool{
        var isMatch = false;
        if(searchString.characters.count == 0)
        {
            // If our search string is empty, everything is a match
            isMatch = true;
        }
        else
        {
            // If we have a search string, check to see if it matches the food's name or description
            let nameRange = name.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch)
            if(nameRange.location != NSNotFound){
                isMatch = true;
            }
        }
        
        // If we have a match...
        return isMatch
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.searchBar.resignFirstResponder()
        
        if let addFriendCell = tableView.cellForRowAtIndexPath(indexPath) as? AddFriendCell{
            
            if (!addFriendCell.isCellSelected){
                
                if (self.nbUserInGroup + (userSelected != nil ? 1 : 0) >= maxNbUsersInGroup){
                    let messageAlertView = "Groups are limited to 3 people max. You cannot invite more than %@ people".localizedStringWithVariables(String(maxNbUsersInGroup - nbUserInGroup))
                    let alertView = UIAlertView(title: "Warning".localized, message: messageAlertView, delegate: self, cancelButtonTitle: "Ok".localized)
                    alertView.show()
                    return;
                }
            }
            
            if addFriendCell.facebookFriend != nil{
                
                if let isBoy = addFriendCell.facebookFriend?.isBoy, isBoySelf = self.user?.isBoy?.boolValue{
                    if ((isBoy && !isBoySelf) || (!isBoy && isBoySelf)){
                        if let name = addFriendCell.facebookFriend?.name{
                            var messageAlertView = "You can only invite boys and %@ is a girl.".localizedStringWithVariables(name)
                            if (!isBoySelf){
                                messageAlertView = "You can only invite girls and %@ is a boy.".localizedStringWithVariables(name)
                            }
                            
                            let alertView = UIAlertView(title: "Warning".localized, message: messageAlertView, delegate: self, cancelButtonTitle: "Ok".localized)
                            alertView.show()
                            return;
                        }
                    }
                }
                
                
                
            }
            
            
            addFriendCell.isCellSelected = !addFriendCell.isCellSelected
            
            if addFriendCell.facebookFriend != nil{
                if(addFriendCell.isCellSelected){
                    userSelected = addFriendCell.facebookFriend
                }else{
                    userSelected = nil
                }
            }
            
            self.tableView.reloadData()
            self.setUpRecapCell()
        }
            
        else if let inviteFriendCell = tableView.cellForRowAtIndexPath(indexPath) as? InviteFriendCell{
            
            var title:String;
            if let casualName = inviteFriendCell.addressBookContact?.casualName{
                title = "%@ is not on Tuesday".localizedStringWithVariables(casualName)
            }else{
                title = "This user is not on Tuesday".localized
            }
            
            var recipientsEmail: [String] = []
            if let email = inviteFriendCell.addressBookContact?.email {
                recipientsEmail.append(email)
            }
            
            var recipientsSMS: [String] = []
            if let mobilePhone = inviteFriendCell.addressBookContact?.mobilePhone {
                recipientsSMS.append(mobilePhone)
            }
            
            displayActionSheetInviteFriend(title, message: "Your friends are not on Tuesday but you want to hang out with them. As soon as they sign in, they will appear here. Invite them to download the app.".localized, recipientsSMS: recipientsSMS, recipientsEmail: recipientsEmail);
            
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.setSelected(false, animated: true)
    }
    
    func setUpRecapCell(){
        self.inviteFriendView.hidden = (self.letters.count == 0) || (self.userSelected != nil)
        let strings : NSMutableArray = []
        
        if let userSelected = self.userSelected{
            strings.addObject(userSelected.name)
        }
        
        if(strings.count == 0){
            recapSendView.hidden = true
        }
        else{
            recapSendView.hidden = false
            let joinedString = strings.componentsJoinedByString(", ")
            recapSendView.label.text = joinedString;
        }
    }
    
    //Mark - UIScrollViewDelegate
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
    
    @IBAction func addFriendButton(sender: AnyObject) {
        print("addFriendButtonaddFriendButton")
        
        if let idOtherUser = userSelected?.idFacebook, idFacebook = user?.idFacebook, firstName = user?.firstName, groupPartitionKey = user_in_Group?.groupPartitionKey, groupSortKey = user_in_Group?.groupSortKey {
            
            if !idUsersInGroup.contains(idOtherUser){
                
                self.view.makeToastActivity()
                
                let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                let jsonObject = [
                    "idUser": idFacebook,
                    "firstNameUser": firstName,
                    "idOtherUser": idOtherUser,
                    "groupPartitionKey": groupPartitionKey,
                    "groupSortKey": groupSortKey
                ]
                
                print("jsonObject \(jsonObject)")
                
                lambdaInvoker.invokeFunction("AWSinviteUser", JSONObject: jsonObject).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                    dispatch_async(dispatch_get_main_queue()) {
                        print("taskerror \(task.error)")
                        print("taskexception \(task.exception)")
                        print("result \(task.result)")
                        if let _ = task.error{
                            self.view.makeToast("An error occured".localized)
                        }
                        else{
                            if let result = task.result as? NSDictionary{
                                if let isOk = result["isOk"] as? NSNumber{
                                    if (isOk.boolValue){
                                        self.delegate?.didAddFriend(idOtherUser)
                                        self.navigationController?.popViewControllerAnimated(true)
                                    }
                                    else{
                                        if let message = result["message"] as? String{
                                            self.view.makeToast(message.localized)
                                        }
                                    }
                                }
                            }
                        }
                        self.view.hideToastActivity()
                    }
                    return nil
                })

                
            }
            else{
                
                var message = "This user is already a member of your group".localized
                if let firstName = userSelected?.firstName{
                    message = "%@ is already a member of your group".localizedStringWithVariables(firstName)
                }
                let alertView = UIAlertView(title: "Warning".localized, message: message, delegate: self, cancelButtonTitle: "Ok".localized)
                alertView.show()
                
            }
        }
        
        
    }
    
    @IBAction func inviteFriendButton(sender: AnyObject) {
        self.searchBar.resignFirstResponder()
        displayActionSheetInviteFriendDefault();
    }
    
    func displayActionSheetInviteFriendDefault(){
        displayActionSheetInviteFriend("Invite your friends".localized, message: "Your friends are not on Tuesday but you want to hang out with them. As soon as they sign in, they will appear here. Invite them to download the app.".localized, recipientsSMS: [], recipientsEmail: [])
    }
    
    func displayActionSheetInviteFriend(title: String, message: String, recipientsSMS: [String], recipientsEmail: [String]){
        let actionSheetInviteFriend = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet);
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (action) in
        }
        actionSheetInviteFriend.addAction(cancelAction)
        
        
        let textMessageAction = UIAlertAction(title: "Text messages".localized, style: .Default) { (action) in
            FBSDKAppEvents.logEvent(FBSDKAppEventsCustom.INVITE_FRIEND, parameters: [FBSDKAppEventParameterCustom.TYPE: FBSDKAppEventParameterCustom.EMAIL, FBSDKAppEventParameterCustom.WHERE_IN_APP: FBSDKAppEventParameterCustom.CONTACT_IN_PARTICULAR])
            self.buttonSMS(self.bodyMessage, recipients: recipientsSMS)
        }
        actionSheetInviteFriend.addAction(textMessageAction)
        
        let messengerAction = UIAlertAction(title: "Messenger".localized, style: .Default) { (action) in
            self.buttonMessenger()
        }
        actionSheetInviteFriend.addAction(messengerAction)
        
        let emailAction = UIAlertAction(title: "Email".localized, style: .Default) { (action) in
            FBSDKAppEvents.logEvent(FBSDKAppEventsCustom.INVITE_FRIEND, parameters: [FBSDKAppEventParameterCustom.TYPE: FBSDKAppEventParameterCustom.EMAIL, FBSDKAppEventParameterCustom.WHERE_IN_APP: FBSDKAppEventParameterCustom.CONTACT_IN_PARTICULAR])
            self.buttonEmail(self.bodyMessage, recipients: recipientsEmail)
        }
        actionSheetInviteFriend.addAction(emailAction)
        self.presentViewController(actionSheetInviteFriend, animated: true, completion: nil)
    }
    
    //Mark - UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        print("textDidChange \(searchText)")
        updateTable(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
    
    // MARK: - Navigation
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    // MARK: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        // Return no adaptive presentation style, use default presentation behaviour
        return UIModalPresentationStyle.None
    }
    
    
    func buttonMessenger() {
        let dialog = FBSDKMessageDialog()
        if dialog.canShow(){
            let content = FBSDKShareLinkContent()
            content.contentURL = NSURL(string: urls.ContentURL)
            FBSDKMessageDialog.showWithContent(content, delegate: self)
        }
        else{
            self.tableView.makeToast("You cannot invite friends via Messenger".localized, duration: 2.0, position: "center")
        }
    }
    
    func buttonSMS(body: String, recipients: [String]?) {
        if (MFMessageComposeViewController.canSendText()) {
            //self.tableView.makeToastActivity()
            messageComposeViewController = MFMessageComposeViewController()
            
            messageComposeViewController.recipients = recipients
            messageComposeViewController.body = body;
            messageComposeViewController.subject = "Invitation".localized
            messageComposeViewController.messageComposeDelegate = self;
            
            self.presentViewController(messageComposeViewController, animated: true, completion:nil);
        }
        else{
            self.tableView.makeToast("Your device cannot send SMS".localized, duration: 2.0, position: "center")
        }
    }
    
    func buttonEmail(body: String, recipients: [String]?) {
        if (MFMailComposeViewController.canSendMail()) {
            //self.tableView.makeToastActivity()
            mailComposeViewController = MFMailComposeViewController()
            
            mailComposeViewController.setMessageBody(body, isHTML: false)
            mailComposeViewController.setToRecipients(recipients)
            mailComposeViewController.setSubject("Invitation".localized)
            mailComposeViewController.mailComposeDelegate = self;
            
            self.presentViewController(mailComposeViewController, animated: true, completion:nil);
        }
        else{
            self.tableView.makeToast("Your device cannot send email".localized, duration: 2.0, position: "center")
        }
    }
    
    func buttonFacebook() {
        let dialog = FBSDKAppInviteDialog()
        if dialog.canShow(){
            let content = FBSDKAppInviteContent()
            content.appLinkURL = NSURL(string: self.appLinkURL)
            content.appInvitePreviewImageURL = NSURL(string: urls.PreviewImageURL)
            FBSDKAppInviteDialog.showFromViewController(self, withContent: content, delegate: self)
        }
        else{
            self.tableView.makeToast("You cannot invite friends via Facebook".localized, duration: 2.0, position: "center")
        }
        
    }
    
    // MARK - FBSDKAppInviteDialogDelegate
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
        self.tableView.makeToast("Invitation successfully sent".localized, duration: 2.0, position: "center")
    }
    
    func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        print(error)
        self.tableView.makeToast("An error occured".localized, duration: 2.0, position: "center")
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
    
    // MARK - MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch(result.rawValue){
        case MFMailComposeResultCancelled.rawValue:
            break;
        case MFMailComposeResultSent.rawValue:
            self.tableView.makeToast("Email successfully sent".localized, duration: 2.0, position: "center")
            break;
        case MFMailComposeResultSaved.rawValue:
            self.tableView.makeToast("Email successfully saved".localized, duration: 2.0, position: "center")
            break;
        case MFMailComposeResultFailed.rawValue:
            self.tableView.makeToast("An error occured".localized, duration: 2.0, position: "center")
            break;
        default:
            break;
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //MARK - FBSDKSharingDelegate
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        self.tableView.makeToast("Message successfully sent".localized, duration: 2.0, position: "center")
    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        self.tableView.makeToast("An error occured".localized, duration: 2.0, position: "center")
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        
    }
    
}

protocol AddFriendViewControllerDelegate{
    func didAddFriend(idUserNewMember:String)
}
