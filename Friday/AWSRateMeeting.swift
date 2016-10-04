//
//  AWSRateMeeting.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 14/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSRateMeeting: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idUser: String?
    var dateString: String?
    var groupPartitionKey: String?
    var groupSortKey:String?
    
    var markEvening: NSNumber?
    var markOtherGroup: NSNumber?
    var markBar: NSNumber?
    var comment:String?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSRateMeeting" }
    class func hashKeyAttribute() -> String! { return "idUser" }
    class func rangeKeyAttribute() -> String! { return "dateString" }
}
