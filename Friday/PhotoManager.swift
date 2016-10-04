//
//  PhotoManager.swift
//  Friday
//
//  Created by Christopher Rydahl on 01/07/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class PhotoManager {
    
    let maxNbPictures = 6
    
    class var sharedInstance: PhotoManager {
        struct Static {
            static var instance: PhotoManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = PhotoManager()
        }
        
        return Static.instance!
    }
    
    func uploadProfilePictures(completionBlock: (() -> Void)){
        
        AWSManager.sharedInstance.getUser({ (user, userProfile) -> Void in
            if let photoKeys = user?.photoKeys {
                if (photoKeys.count > 0){
                    completionBlock()
                    return
                }
            }
            
            let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/albums", parameters: ["fields":"id, type"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil)
                {
                    
                    print("result: \(result)")
                    if let data : NSArray = result["data"] as? NSArray{
                        
                        let count = data.count
                        for i in 0 ..< count {
                            let alb = data[i]
                            if let type = alb.objectForKey("type") as? String{
                                if type == "profile"{
                                    if let idAlbum = alb.objectForKey("id") as? String{
                                        self.getAllPictures(idAlbum, completionBlock: completionBlock)
                                        return;
                                    }
                                }
                            }
                        }
                        
                    }
                }
                
                self.uploadPhotoUtilisateurDefault(completionBlock)
                
            })
            
        })
        
    }
    
    func getAllPictures(idAlbum: String, completionBlock: (() -> Void)){
        let graphPath = "/" + idAlbum + "/photos?limit=200"
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: ["fields":"source"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if (error == nil)
            {
                
                print("result: \(result)")
                if let data : NSArray = result["data"] as? NSArray{
                    
                    let count = min(data.count, self.maxNbPictures)
                    for order in 0 ..< count {
                        let alb = data[order]
                        if let photoSource = alb.objectForKey("source") as? String{
                            if (order == 0){
                                self.uploadPhotoUtilisateur(order, photoSource: photoSource, completionBlock: completionBlock)
                            }else{
                                self.uploadPhotoUtilisateur(order, photoSource: photoSource)
                            }
                        }
                        
                    }
                    
                    
                    
                    //Si on a réussi à uploader au moins une photo,
                    //on n'a pas besoin d'uploader la photo par défaut
                    if (count > 0){
                        return;
                    }
                    
                }
            }
            
            self.uploadPhotoUtilisateurDefault(completionBlock)
            
        })
    }
    
    
    static func downloadImageWithURLData(url : NSURL, completionBlock: (succeeded: Bool, data: NSData?) -> Void){
        let request = NSMutableURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler:{(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            if (error == nil )
            {
                completionBlock(succeeded: true, data: data)
            } else{
                completionBlock(succeeded: false, data: nil)
            }
        })
    }
    
    static func downloadImageWithURL(url : NSURL, completionBlock: (succeeded: Bool, image: UIImage?) -> Void){
        
        PhotoManager.downloadImageWithURLData(url) { (succeeded, data) -> Void in
            if (data != nil){
                var image = UIImage(data: data!)
                if(image != nil){
                    completionBlock(succeeded: true, image: image)
                }else{
                    image=UIImage()
                    completionBlock(succeeded: true, image: image)
                }
            }
            else{
                completionBlock(succeeded: false, image: nil)
            }
        }
        
    }
    
    func uploadPhotoUtilisateur(order: Int, photoSource: String){
        uploadPhotoUtilisateur(order, photoSource: photoSource) { () -> Void in
            
        }
    }
    
    func uploadPhotoUtilisateur(order: Int, photoSource: String, completionBlock: (() -> Void)){
        let picture_url = NSURL(string: photoSource)
        
        // download the image asynchronously
        PhotoManager.downloadImageWithURLData(picture_url as NSURL! , completionBlock: {
            (succeeded: Bool, data: NSData?) -> Void in
            if let data = data {
                
                self.uploadDataPhoto(data, completionBlock: completionBlock)
                
            }
                
            else{
                
            }
        })
    }
    
    func uploadDataPhoto(data: NSData, completionBlock: (() -> Void)){
        
        let random = "\(NSDate.timeIntervalSinceReferenceDate())"
        
        let transferUtility = AWSS3TransferUtility.defaultS3TransferUtility()
        transferUtility.uploadData(data, bucket: "tuesdayphotosbucket", key: getKey(AWSManager.sharedInstance.getIdFacebook(), suffix: random), contentType: "image/jpg", expression: nil, completionHander: nil).continueWithBlock({ (task:AWSTask) -> AnyObject? in
            
            if (task.error != nil) {
                print("Error: \(task.error)");
            }
            
            if (task.exception != nil) {
                print("exception: \(task.exception)");
            }
            
            if (task.result != nil) {
                
                if let uploadOutput = task.result as? AWSS3TransferUtilityUploadTask{
                    print("uploadOutput \(uploadOutput)")
                    AWSManager.sharedInstance.getUser({ (user, userProfile) -> Void in
                        if let _ = user?.photoKeys {
                            user?.photoKeys?.append(random)
                        }
                        else{
                            user?.photoKeys = [random]
                        }
                        
                        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                        dynamoDBObjectMapper.saveUpdateSkipNullAttributes(user).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                
                                AWSManager.sharedInstance.user = user
                                completionBlock()
                                
                            }
                            return nil;
                        })
                    })
                };
            }
            return nil;
        })
        
    }
    
    //On upload une photo par défaut si l'utilisateur n'a pas de photo de profil
    func uploadPhotoUtilisateurDefault(completionBlock: (() -> Void)){
        completionBlock()
    }
    
    
    func getKey(idFacebook:String, suffix:String) -> String{
        return "\(idFacebook)_\(suffix).jpg"
    }
    
    
    
}
