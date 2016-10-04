//
//  ChatViewController.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 24/12/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!
    let appDelegate = UIApplication.sharedApplication()
    
    var notSentMessageChats: [AWSMessageChat] = []
    
    var chatDateFormatter: ChatDateFormatter = ChatDateFormatter()
    
    var tuesday: AWSTuesday?
    
    var messageChats : [AWSMessageChat] = []
    
    var messageViewController: MessageViewController?
    var shouldCreateChat: Bool = false
    
    let maxWidthLabel = CGFloat(UIScreen.mainScreen().bounds.width/2 + 100 - 24) // calcul en fonction du storyboard
    let systemFont = UIFont.systemFontOfSize(15)
    
    var idOtherUsers: [String] = []
    var usersDict: [String:AWSUser] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        messageViewController = storyboard.instantiateViewControllerWithIdentifier("MessageViewController") as? MessageViewController
        self.addChildViewController(messageViewController!)
        messageViewController!.view.frame = self.view.frame
        self.view.addSubview(messageViewController!.view)
        messageViewController!.didMoveToParentViewController(self)
        messageViewController!.delegate = self
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        messageViewController?.textView.becomeFirstResponder()
        refresh()
        updateDateChatAllSeen()
    }
    
    override func viewWillDisappear(animated: Bool) {
        messageViewController?.textView.resignFirstResponder()
        super.viewWillDisappear(animated)
        updateDateChatAllSeen()
    }
    
    func updateDateChatAllSeen(){
        
        var dateChatAllSeenString = NSDate().toYYYYMMddhhmmssInUTC()
        
        let count = messageChats.count
        if (count > 0){
            if let createdAtString = messageChats[count - 1].createdAtString {
                if (createdAtString > dateChatAllSeenString){
                    dateChatAllSeenString = createdAtString
                }
            }
        }
        
        /*tuesday?.dateChatAllSeenString = dateChatAllSeenString
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
        dynamoDBObjectMapper!.saveUpdateSkipNullAttributes(meeting)*/
    }
    
    
    func refresh(){
        
        if let idChat = MeetingManager.sharedInstance.getIdChat(tuesday){
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            let queryExpression = AWSDynamoDBQueryExpression()
            
            queryExpression.hashKeyAttribute = "idChat"
            queryExpression.hashKeyValues = idChat
            
            //dans l'ordre croissant de dateString
            queryExpression.scanIndexForward = false
            queryExpression.limit = 20
            
            dynamoDBObjectMapper.query(AWSMessageChat.self, expression: queryExpression).continueWithBlock { (task:AWSTask) -> AnyObject? in
                print("AWSManager getAWSMessageChat")
                print("task.result \(task.result)")
                print("error \(task.error)")
                print("exception \(task.exception)")
                
                dispatch_async(dispatch_get_main_queue()) {
                    if let paginatedOutput = task.result as? AWSDynamoDBPaginatedOutput {
                        if let newMessageChats = paginatedOutput.items as? [AWSMessageChat] {
                            self.updateMessageChats(newMessageChats)
                        }
                    }
                }
                
                return nil
            }
        }
        
        
    }
    
    func updateMessageChats(newMessageChats: [AWSMessageChat]){
        print("newMessageChats \(newMessageChats)")
        print("oldMessageChats \(messageChats)")
        if newMessageChats.count == self.messageChats.count {
            if (newMessageChats.count > 0){
                if (newMessageChats[newMessageChats.count - 1].isEqual(self.messageChats[self.messageChats.count - 1])){
                    return
                }
            }
            else{
                return
            }
        }
        
        self.messageChats = newMessageChats.sort({ (a:AWSMessageChat, b:AWSMessageChat) -> Bool in
            if let aCreatedAt = a.createdAtString, bCreatedAt = b.createdAtString{
                return aCreatedAt < bCreatedAt
            }
            return true
        })
        
        if let tableView = tableView{
            tableView.reloadData()
        }
        self.scrollToBottom()
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // Mark - UITableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageChats.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = getIdentifier(indexPath)
        let cell:MessageChatCell! = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! MessageChatCell
        
        switch (identifier){
        case "MyMessageChatCell":
            cell.typeMessageChatCell = TypeMessageChatCell.MyMessageChatCell
            break;
        case "OtherMessageChatCell":
            cell.typeMessageChatCell = TypeMessageChatCell.OtherMessageChatCell
            break;
        default:
            break;
        }
        
        self.configureMessageChatCell(cell, atIndexPath: indexPath, withIdentifier:identifier)
        return cell
    }
    
    func getIdentifier(indexPath: NSIndexPath) -> String{
        let messageChat = self.messageChats[indexPath.row]
        var identifier : String
        if (messageChat.idUser == AWSManager.sharedInstance.idFacebook!){
            identifier = "MyMessageChatCell"
        }else{
            identifier = "OtherMessageChatCell"
        }
        return identifier;
    }
    
    func configureMessageChatCell(cell :MessageChatCell, atIndexPath indexPath: NSIndexPath, withIdentifier identifier: String){
        if (indexPath.row < self.messageChats.count){
            let messageChat = self.messageChats[indexPath.row]
            
            //label
            cell.chatLabel.text = messageChat.text
            
            //date
            if (self.getCreatedAtLabelText(indexPath) == ""){
                cell.topLayoutConstraint.constant = 8
                cell.timeLabel.hidden = true
            }
            else{
                cell.topLayoutConstraint.constant = 29
                cell.timeLabel.hidden = false
            }
            
            cell.timeLabel.text = self.getCreatedAtLabelText(indexPath)
            
            if (identifier == "MyMessageChatCell"){
                if (notSentMessageChats.contains(messageChat)){
                    cell.sentImageView.image = UIImage(named: "ChatCheck.png")
                }
                else{
                    cell.sentImageView.image = UIImage(named: "ChatCheckFilled.png")
                }
            }
            else{
                
                if let idUserMessageChat = messageChat.idUser{
                    setProfilePicture(idUserMessageChat, imageView: cell.sentImageView)
                }
                else{
                    cell.sentImageView.image = nil
                }
            }
            
            cell.layoutIfNeeded()
            cell.setNeedsLayout()
        }
        
    }
    
    func setProfilePicture(idUser: String, imageView: AWSImageView){
        if let user = usersDict[idUser]{
            imageView.setProfilePicture(user)
        }
        else{
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
            dynamoDBObjectMapper.load(AWSUser.self, hashKey: idUser, rangeKey: nil).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                if let user = task.result as? AWSUser{
                    dispatch_async(dispatch_get_main_queue()) {
                        self.usersDict[idUser] = user;
                        imageView.setProfilePicture(user)
                    }
                }
                return nil
            })
        }
    }
    
    func getCreatedAtLabelText(indexPath: NSIndexPath) -> String{
        let messageChat = self.messageChats[indexPath.row]
        if let createdAt = messageChat.createdAtString!.getDateYYYYMMddHHmmssInUTC(){
            if (indexPath.row > 0){
                let previousMessageChat = self.messageChats[indexPath.row - 1]
                if let previousCreatedAt = previousMessageChat.createdAtString!.getDateYYYYMMddHHmmssInUTC(){
                    let interval = createdAt.timeIntervalSinceDate(previousCreatedAt)
                    if (interval < 1800){
                        return ""
                    }
                }
            }
            
            return chatDateFormatter.stringFromDate(createdAt)
        }
        
        return ""
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row < self.messageChats.count){
            let messageChat = self.messageChats[indexPath.row]
            
            var fixedWidth = widthForView(messageChat.text!, font: systemFont, height: 18)
            fixedWidth = fixedWidth + 8 + 8
            if (fixedWidth > maxWidthLabel){
                fixedWidth = maxWidthLabel
            }
            let height = heightForView(messageChat.text!, font: systemFont, width: fixedWidth)
            if (self.getCreatedAtLabelText(indexPath) == ""){
                print("self.getCreatedAtLabelText(indexPath) ==")
                return height + 40
            }
            else{
                print("self.getCreatedAtLabelText(indexPath) !=")
                return height + 61
            }
            
            
        }
        
        return 100;
        
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    func widthForView(text:String, font:UIFont, height:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.width
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        messageViewController!.textView.resignFirstResponder()
    }
    
    //Mark - MessageViewControllerDelegate
    func textViewDidChange(newHeight: CGFloat){
        print("textViewDidChange \(newHeight) ")
        let frameMVC = messageViewController!.view.frame
        let diffHeight = newHeight - frameMVC.size.height
        let newFrameVC = CGRectMake(0, frameMVC.origin.y - diffHeight, frameMVC.size.width, newHeight)
        print("newFrameVC \(newFrameVC)")
        messageViewController?.view.frame = newFrameVC
        messageViewController?.didMoveToParentViewController(self)
        
        tableBottomConstraint.constant = view.frame.size.height - messageViewController!.view.frame.origin.y;
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
    }
    
    func scrollToBottom(){
        if let tableView = self.tableView{
            let numberOfSections = tableView.numberOfSections
            let numberOfRows = tableView.numberOfRowsInSection(numberOfSections-1)
            
            if numberOfRows > 0 {
                let indexPath = NSIndexPath(forRow: numberOfRows-1, inSection: (numberOfSections-1))
                tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
            }
        }
    }
    
    func sendButton(){
        
        if let text = messageViewController?.textView.text, idChat = MeetingManager.sharedInstance.getIdChat(tuesday), user = AWSManager.sharedInstance.user {
            
            let messageChat = AWSMessageChat()
            messageChat.idUser = AWSManager.sharedInstance.idFacebook!
            messageChat.text = text
            messageChat.idChat = idChat
            messageChat.createdAtString = NSDate().toYYYYMMddhhmmssInUTC()
            
            if let text = messageChat.text, idUser = AWSManager.sharedInstance.idFacebook, firstName = user.firstName {
                
                self.messageChats.append(messageChat)
                self.notSentMessageChats.append(messageChat)
                self.tableView.reloadData()
                self.scrollToBottom()
                
                let lambdaInvoker = AWSLambdaInvoker.defaultLambdaInvoker()
                let jsonObject = [
                    "idChat": idChat,
                    "idUser": idUser,
                    "text": text,
                    "idOtherUsers": idOtherUsers,
                    "firstNameUser": firstName
                ]
                
                print("jsonObject \(jsonObject)")
                
                lambdaInvoker.invokeFunction("AWSsaveMessageChat", JSONObject: jsonObject).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                    print("messageChat.saveInBackgroundWithBlock")
                    print("task.result \(task.result)")
                    print("exception \(task.exception)")
                    print("error \(task.error)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.removeMessageChatInNotSentMessageChats(messageChat)
                        self.tableView.reloadData()
                    }
                    return nil
                })
                
            }
            
        }
        
    }
    
    func removeMessageChatInNotSentMessageChats(messageChat: AWSMessageChat){
        for i in 0 ..< notSentMessageChats.count {
            if (messageChat.isEqual(notSentMessageChats[i]) ){
                notSentMessageChats.removeAtIndex(i)
                break;
            }
        }
    }
    
    func keyboardDidShow(keyboardHeight: CGFloat){
        scrollToBottom()
    }
    
    
    func didScrollNewMessageViewController(){
        self.messageViewController?.textView.resignFirstResponder()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let dest = segue.destinationViewController as? ChatSettingsViewController{
            //dest.meeting = self.meeting
        }
        
    }
    
}
