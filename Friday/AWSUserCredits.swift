//
//  AWSUserCredits.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 24/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSUserCredits: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idUser: String?
    var nbCredits: NSNumber?
    var dateLikeFacebookPage:String?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSUserCredits" }
    class func hashKeyAttribute() -> String! { return "idUser" }
    //class func rangeKeyAttribute() -> String! { return "promoCode" }
    
    
}