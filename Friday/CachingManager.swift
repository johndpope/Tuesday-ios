//
//  CachingManager.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 27/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class CachingManager{
    
    //Arguments
    var keyImageDict: [String: UIImage] = [:]
    
    //Singleton
    class var sharedInstance: CachingManager {
        struct Static {
            static var instance: CachingManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = CachingManager()
        }
        
        return Static.instance!
    }

}
