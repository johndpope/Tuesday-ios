//
//  AddressBookContact.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 27/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class AddressBookContact: NSObject {
    
    var lastName:String
    var firstName:String
    var mobilePhone:String
    var email:String?
    var name:String{
        get{
            return firstName + " " + lastName
        }
        set{
            
        }
    }
    
    var casualName:String{
        get{
            if (firstName != ""){
                return firstName
            }
            else{
                return firstName + " " + lastName
            }
        }
        set{
            
        }
    }
    
    init(fromLastName lastName: String?, fromFirstName firstName: String?, fromMobilePhone mobilePhone: String, fromEmail email: String?) {
        self.lastName = (lastName != nil) ? lastName! : ""
        self.firstName = (firstName != nil) ? firstName! : ""
        self.mobilePhone = mobilePhone
        self.email = email
        super.init()
    }

    
}
