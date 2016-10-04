//
//  AWSReview.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 01/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSReview: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idSender: String?
    var createdAt:String?
    var title:String?
    var review: String?
    var mark: NSNumber?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSReview" }
    class func hashKeyAttribute() -> String! { return "idSender" }
    class func rangeKeyAttribute() -> String! { return "createdAt" }
}
