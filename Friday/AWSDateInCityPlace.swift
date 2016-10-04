//
//  AWSDateInCityPlace.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 19/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSDateInCityPlace: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var placeID: String?
    var dateString: String?
    var nbGroupLimit: NSNumber?
    var nbGirlGroup: NSNumber?
    var nbBoyGroup: NSNumber?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSDateInCityPlace" }
    class func hashKeyAttribute() -> String! { return "placeID" }
    class func rangeKeyAttribute() -> String! { return "dateString" }
    
    
}
