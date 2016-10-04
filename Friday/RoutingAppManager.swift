//
//  RoutingAppManager.swift
//  Friday
//
//  Created by Christopher Rydahl on 17/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class RoutingAppManager: NSObject {

    var routingApps: [RoutingApp] = []
    
    class var sharedInstance: RoutingAppManager {
        struct Static {
            static var instance: RoutingAppManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = RoutingAppManager()
            Static.instance!.initialisation()
        }
        
        return Static.instance!
    }
    
    func initialisation(){
        
        routingApps = []
        routingApps.append(RoutingApp(fromName: "Maps", fromUrl: "http://maps.apple.com/", fromUrl2: "?ll=%alat,%along&q=%aname"))
        routingApps.append(RoutingApp(fromName: "Google Maps", fromUrl: "comgooglemaps://", fromUrl2: "?daddr=%alat,%along"))
        
    }
}
