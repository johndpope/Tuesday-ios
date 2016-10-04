//
//  AWSGroup.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 13/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSGroup: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var dashboardKey: String? //"placeId" + "//" + "date" + "//" + isBoy ? "1" : "2"
    var sortKey: String? //"idCapitaine" + "//" + "dateCreation"
    
    var lastMeetingDateString: String?
    var otherGroupSortKey:String?
    
    var isParticipationConfirmed: NSNumber?
    
    var idUsers:[String]?
    var birthday:String?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSGroup" }
    class func hashKeyAttribute() -> String! { return "dashboardKey" }
    class func rangeKeyAttribute() -> String! { return "sortKey" }
    
    
}