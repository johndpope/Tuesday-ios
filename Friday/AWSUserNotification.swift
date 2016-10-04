//
//  UserNotification.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 16/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSUserNotification: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idFacebook: String?
    var endpointArn:String?
    
    override init!() { super.init() }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func dynamoDBTableName() -> String! { return "AWSUserNotification" }
    class func hashKeyAttribute() -> String! { return "idFacebook" }
    class func rangeKeyAttribute() -> String! { return "endpointArn" }
    
}
