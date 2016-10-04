//
//  AWSButtonImage.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 01/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AWSButtonImage: UIButton {
    
    
    
    func setProfilePicture(user: AWSUser){
        if let photoKeys = user.photoKeys{
            if photoKeys.count > 0 {
                setPhotoPictureFromKey(PhotoManager.sharedInstance.getKey(user.idFacebook!, suffix: photoKeys[0]))
            }
        }
    }
    
    func setPhotoPictureFromKey(key: String){
        
        if let image = CachingManager.sharedInstance.keyImageDict[key] {
            self.setImage(image, forState: UIControlState.Normal)
        }
        else{
            
            let transferManager = AWSS3TransferUtility.defaultS3TransferUtility()
            transferManager.downloadDataFromBucket("tuesdayphotosbucket", key: key, expression: nil, completionHander: { (task:AWSS3TransferUtilityDownloadTask, url:NSURL?, data:NSData?, error:NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if (error != nil) {
                        print("Error: \(error)");
                    }
                    
                    
                    if let data = data {
                        self.setImage(UIImage(data: data), forState: UIControlState.Normal)
                    }
                    
                }
                
            })
        }
    }
    
}
