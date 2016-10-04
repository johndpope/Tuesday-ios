//
//  RoutingApp.swift
//  Friday
//
//  Created by Christopher Rydahl on 17/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class RoutingApp: NSObject {

    var name:String
    var url:String
    var url2:String
    
    
    init(fromName name: String, fromUrl url: String, fromUrl2 url2: String) {
        self.name = name
        self.url = url
        self.url2 = url2
        super.init()
    }
    
    
    
}
