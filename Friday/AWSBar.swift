//
//  AWSBar.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 01/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSBar: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idVenue:String?
    var latitude: NSNumber?
    var longitude: NSNumber?
    var address:String?
    var name: String?
    var idFoursquareClient: String?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSBar" }
    class func hashKeyAttribute() -> String! { return "idVenue" }
    //class func rangeKeyAttribute() -> String! { return "rangeKeyAtrribute" }

}
