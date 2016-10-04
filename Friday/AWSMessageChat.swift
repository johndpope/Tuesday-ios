//
//  AWSChat.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 02/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSMessageChat: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idChat:String?//tuesdaysortKey
    var createdAtString: String?
    var idUser:String?
    var text: String?
    
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
        if let otherMessagechat = anObject as? AWSMessageChat{
            if (otherMessagechat.idChat == self.idChat && otherMessagechat.createdAtString == self.createdAtString && otherMessagechat.idUser == self.idUser && otherMessagechat.text == self.text){
                return true
            }
        }
        return false
    }
    
    class func dynamoDBTableName() -> String! { return "AWSMessageChat" }
    class func hashKeyAttribute() -> String! { return "idChat" }
    class func rangeKeyAttribute() -> String! { return "createdAtString" }
    
}
