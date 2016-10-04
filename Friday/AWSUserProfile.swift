//
//  UserProfile.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 10/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSUserProfile: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idFacebook: String?
    var ageMax: NSNumber?
    var ageMin: NSNumber?
    var desc:String?
    
    var truth1: String?
    var truth2: String?
    var lie: String?
    
    var isMessageNotification: NSNumber?
    var isMessageNotificationChat: NSNumber?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSUserProfile" }
    class func hashKeyAttribute() -> String! { return "idFacebook" }
    //class func rangeKeyAttribute() -> String! { return "rangeKeyAtrribute" }
    
}
