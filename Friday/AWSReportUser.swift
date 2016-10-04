//
//  AWSReportUser.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 12/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSReportUser: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idReportedUser: String?
    var idReportingUser: String?
    var whichReport:NSNumber?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSReportUser" }
    class func hashKeyAttribute() -> String! { return "idReportedUser" }
    class func rangeKeyAttribute() -> String! { return "idReportingUser" }
}

