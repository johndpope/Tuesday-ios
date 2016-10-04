//
//  AWSUser.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 29/01/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idFacebook: String?
    var dashboardKey: String?
    var firstName: String?
    var birthday:String?
    var isBoy: NSNumber?
    var photoKeys:[String]?
    var lastMeetingDate: String?
    var nextMeetingDate: String?
    
    override init!() { super.init() }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(dictionary dictionaryValue: [NSObject : AnyObject]!, error: ()) throws {
        do {
            try super.init(dictionary: dictionaryValue, error: error)
        } catch _ {
        }
        
    }
    
    override func isEqual(anObject: AnyObject?) -> Bool {
        return super.isEqual(anObject)
    }
    
    class func dynamoDBTableName() -> String! { return "AWSUser" }
    class func hashKeyAttribute() -> String! { return "idFacebook" }
    //class func rangeKeyAttribute() -> String! { return "rangeKeyAtrribute" }
    
    func getDate() -> NSDate? {
        
        if let birthdayString = self.birthday{
            
            let newDateFormat = NSDateFormatter()
            newDateFormat.dateFormat = "yyyy-MM-dd"
            
            if let birthday = newDateFormat.dateFromString(birthdayString){
                return birthday
            }
        }
        
        return nil
    }
}
