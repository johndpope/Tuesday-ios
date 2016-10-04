//
//  AWSUser_likes_User.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 30/01/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSUser_likes_User: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var idUserBoy: String?
    var idUserGirl: String?
    var isBoyLikingGirl: NSNumber?
    var isGirlLikingBoy: NSNumber?
    /*
    
    nbLikes = 3 * a + b
    
    où 
    a = 1 si isGirlLikingBoy = true
    a = -1 si isGirlLikingBoy = false
    a = 0 si isGirlLikingBoy = null
    
    b = 1 si isBoyLikingGirl = true
    b = -1 si isBoyLikingGirl = false
    b = 0 si isBoyLikingGirl = null
    
    */
    
    var nbLikes: Bool?
    
    override init!() { super.init() }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func dynamoDBTableName() -> String! { return "AWSUser_likes_User" }
    class func hashKeyAttribute() -> String! { return "idUserGirl" }
    class func rangeKeyAttribute() -> String! { return "idUserBoy" }
}
