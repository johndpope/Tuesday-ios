
//
//  PhotoAlbum.swift
//  Friday
//
//  Created by Christopher Rydahl on 09/06/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class PhotoAlbum: NSObject {

    var idPhotoAlbum: String
    var sourceString: String
    var pictureString: String
    var picture: UIImage?
    
    init(_idPhotoAlbum:String, _sourceString: String, _pictureString: String){
        idPhotoAlbum = _idPhotoAlbum;
        sourceString = _sourceString
        pictureString = _pictureString
    }
}
