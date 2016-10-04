//
//  AWSTuesday.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 13/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSTuesday: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var dashboardKey: String? //"placeId" + "//" + "date"
    var sortKey: String? //"sortKeyGroup1" + "//" + "sortKeyGroup2"
    
    var dateString: String?
    var idBar: String?
    
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
    
    class func dynamoDBTableName() -> String! { return "AWSTuesday" }
    class func hashKeyAttribute() -> String! { return "dashboardKey" }
    class func rangeKeyAttribute() -> String! { return "sortKey" }
    
    
}