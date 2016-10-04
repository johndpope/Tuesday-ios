//
//  FacebookManager.swift
//  Story
//
//  Created by Christopher Rydahl on 31/03/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class FacebookManager{
    var friends : [FacebookFriend] = []
    
    var isLikingFacebookPage = false
    
    class var sharedInstance: FacebookManager {
        struct Static {
            static var instance: FacebookManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = FacebookManager()
        }
        
        return Static.instance!
    }
    
    
    func setDefaultAWC(dataset:AWSCognitoDataset, key: String, value: AnyObject){
        dataset.setValue(value, forKey: key)
    }
    
    /* Facebook Friends
    ******************************************************************************/
    
    func refreshFriend(){
        refreshFriend { (error) -> Void in}
    }
    
    func refreshFriend(completionBlock : ((error: NSError?) -> Void)){
        self.friends = []
        getFriend("me/friends", completionBlock: completionBlock)
    }
    
    func getFriend(graphPath: String, completionBlock : ((error: NSError?) -> Void)){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: ["fields":"first_name,last_name,id,gender"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                //print("Data \(result)")
                if let data : NSArray = result["data"] as? NSArray{
                    
                    for friend in data{
                        if let friend = friend as? NSDictionary{
                            if let idFacebook = friend.objectForKey("id") as? String, firstName = friend.objectForKey("first_name") as? String, lastName = friend.objectForKey("last_name") as? String{
                                var isBoy: Bool? = nil
                                if let gender = friend.objectForKey("gender") as? String{
                                    isBoy = (gender == "male")
                                }
                                self.friends.append(FacebookFriend(fromLastName: lastName, fromFirstName: firstName, fromIdFacebook: idFacebook, fromIsBoy: isBoy))
                            }
                        }
                    }
                    
                }
                
                if let paging = result["paging"] as? NSDictionary{
                    if let next = paging["next"] as? String{
                        let text1 = "/friends";
                        var postTel: String;
                        
                        let scanner = NSScanner(string: next);
                        var preTel:NSString?
                        scanner.scanUpToString(text1, intoString:&preTel)
                        scanner.scanString(text1, intoString:nil)
                        
                        postTel = (next as NSString).substringFromIndex(scanner.scanLocation)
                        self.getFriend("me" + text1 + postTel, completionBlock: completionBlock)
                        return;
                    }
                }
            }
            
            completionBlock(error: nil)
        })
    }

    /* Facebook Likes
    ******************************************************************************/
    
    func refreshLike(){
        refreshFriend { (error) -> Void in}
    }
    
    func refreshLike(completionBlock : ((error: NSError?) -> Void)){
        getLikes("me/likes", completionBlock: completionBlock)
    }
    
    func getLikes(graphPath: String, completionBlock : ((error: NSError?) -> Void)){
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: ["fields":""])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                //print("Data \(result)")
                if let data : NSArray = result["data"] as? NSArray{
                    
                    for like in data{
                        if let like = like as? NSDictionary{
                            if let idFacebook = like.objectForKey("id") as? String{
                                if (idFacebook == Params.FACEBOOK_PAGE_ID){
                                    self.isLikingFacebookPage = true;
                                    break;
                                }
                            }
                        }
                    }
                    
                }
                
                if let paging = result["paging"] as? NSDictionary{
                    if let next = paging["next"] as? String{
                        let text1 = "/likes";
                        var postTel: String;
                        
                        let scanner = NSScanner(string: next);
                        var preTel:NSString?
                        scanner.scanUpToString(text1, intoString:&preTel)
                        scanner.scanString(text1, intoString:nil)
                        
                        postTel = (next as NSString).substringFromIndex(scanner.scanLocation)
                        print("link: \("me" + text1 + postTel)")
                        self.getLikes("me" + text1 + postTel, completionBlock: completionBlock)
                        return;
                    }
                }
            }
            
            completionBlock(error: nil)
        })
    }

    
    /* Get Mutual Facebook Likes
    ******************************************************************************/
    func getMutualLikesWithOtherUser(idOtherUser: String, completionBlock : ((mutualLikes: [FacebookLike], error: NSError?) -> Void)){
        var mutualLikes: [FacebookLike] = []
        getMutualLikes("\(idOtherUser)", parameters:["fields":"context.fields(mutual_likes)"], completionBlock: completionBlock,  mutualLikes: &mutualLikes)
    }
    
    func getMutualLikes(graphPath: String, parameters: [NSObject: AnyObject], completionBlock : ((mutualLikes: [FacebookLike], error: NSError?) -> Void), inout mutualLikes: [FacebookLike]){
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: graphPath, parameters: parameters)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error FacebookManager getLikes: \(error)")
            }
            else
            {
                print("FacebookManagerData \(result)")
                
                if let context = result["context"] as? NSDictionary{
                    
                    print("FacebookManagerData 1")
                    
                    if let mutual_likes = context["mutual_likes"] as? NSDictionary{
                        
                        print("FacebookManagerData 2")
                        
                        if let data = mutual_likes["data"] as? NSArray{
                            
                            print("FacebookManagerData 3")
                            
                            for page in data{
                                if let page = page as? NSDictionary{
                                    if let idFacebook = page.objectForKey("id") as? String, let name = page.objectForKey("name") as? String{
                                        let facebookLike = FacebookLike(_idFacebook: idFacebook, _name: name)
                                        mutualLikes.append(facebookLike)
                                        
                                    }
                                }
                            }
                        }
                    }
                    
                }
                
                if let paging = result["paging"] as? NSDictionary{
                    if let next = paging["next"] as? String{
                        self.getMutualLikes(next.componentsSeparatedByString("https://graph.facebook.com/v2.5/").last!, parameters:[:], completionBlock: completionBlock, mutualLikes: &mutualLikes)
                        return;
                    }
                }
            }
            
            completionBlock(mutualLikes: mutualLikes, error: nil)
        })
    }
    
    
    
    
    
    
    
}
