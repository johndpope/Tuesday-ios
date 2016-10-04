//
//  FacebookLike.swift
//  Friday
//
//  Created by Christopher Rydahl on 21/10/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//


import Foundation

class FacebookLike: NSObject {
    
    var idFacebook: String
    var name: String
    var picture: UIImage?
    
    
    init(_idFacebook:String, _name: String){
        idFacebook = _idFacebook;
        name = _name
    }
    
}
