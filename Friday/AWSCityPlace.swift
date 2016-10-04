//
//  AWSCityPlace.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 14/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSCityPlace: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var tz: NSNumber?
    var placeID: String?
    var name: String?
    var latitude: NSNumber?
    var longitude:NSNumber?
    
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
    
    init(fromPlaceID placeID: String, fromName name: String, fromLatitude latitude: NSNumber, fromLongitude longitude: NSNumber) {
        self.placeID = placeID
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        
        var multiplier = 1.0
        var longitudeParam = longitude.doubleValue
        if (longitudeParam < 0){
            longitudeParam = -1 * longitudeParam
            multiplier = -1.0
        }
        self.tz = NSNumber(double: floor(longitudeParam / 7.5) * multiplier)
        super.init()
    }
    
    class func dynamoDBTableName() -> String! { return "AWSCityPlace" }
    class func hashKeyAttribute() -> String! { return "tz" }
    class func rangeKeyAttribute() -> String! { return "placeID" }
    
    
}
