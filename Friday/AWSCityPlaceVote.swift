//
//  AWSCityPlaceVote.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 21/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSCityPlaceVote: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {

    var placeID: String?
    var idUser: String?
    var dateString: String?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSCityPlaceVote" }
    class func hashKeyAttribute() -> String! { return "placeID" }
    class func rangeKeyAttribute() -> String! { return "idUser" }
    
    
}