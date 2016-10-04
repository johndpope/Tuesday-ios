//
//  FacebookFriend.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 13/03/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class FacebookFriend: NSObject {

    var idFacebook:String
    var lastName:String
    var firstName:String
    var isBoy:Bool?
    
    var name:String{
        get{
            return firstName + " " + lastName
        }
        set{
            
        }
    }
    
    init(fromLastName lastName: String?, fromFirstName firstName: String?, fromIdFacebook idFacebook: String, fromIsBoy isBoy: Bool?) {
        self.lastName = (lastName != nil) ? lastName! : ""
        self.firstName = (firstName != nil) ? firstName! : ""
        self.idFacebook = idFacebook
        self.isBoy = isBoy
        super.init()
    }}
