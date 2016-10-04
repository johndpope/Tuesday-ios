//
//  Album.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 09/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class Album: NSObject {
    
     var idAlbum: String
     var name: String
     var count: Int
     var idCoverPhoto: String
     var picture: UIImage?
    
    init(_idAlbum:String, _name: String, _count: Int, _idCoverPhoto: String){
        idAlbum = _idAlbum;
        name = _name
        count = _count
        idCoverPhoto = _idCoverPhoto
    }
    
}
