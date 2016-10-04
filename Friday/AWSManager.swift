//
//  AWSManager.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 31/01/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//
//http://www.jhreview.com/tech-stack/questions/30138094/querying-dynamodb-on-non-key-attributes

import UIKit

class AWSManager {
    
    //Arguments
    var user: AWSUser?
    var userProfile: AWSUserProfile?
    var idFacebook: String?
    
    //Singleton
    class var sharedInstance: AWSManager {
        struct Static {
            static var instance: AWSManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = AWSManager()
        }
        
        return Static.instance!
    }
    
    
    /*
    * Log out
    */
    func logOut(){
        user = nil
        userProfile = nil
    }
    
    func getPromoCode() -> String?{
        if let idFacebook = user?.idFacebook, firstName = user?.firstName{
            let index = idFacebook.endIndex.predecessor()
            return "\(firstName)\(idFacebook[index.predecessor()])\(idFacebook[index])".lowercaseString
        }
        
        return nil
    }
    
    func getIdFacebook() -> String{
        
        if let idFacebook = self.idFacebook{
            return idFacebook
        }
        
        let syncClient = AWSCognito.defaultCognito()
        let dataset = syncClient.openOrCreateDataset("identity")
        if let idFacebook = dataset.stringForKey("idFacebook"){
            return idFacebook
        }
        
        return "idFacebook"
    }
    
    func getUser(completionBlock : ((user: AWSUser?, userProfile: AWSUserProfile?) -> Void)?){
        
        if let user = self.user, userProfile = self.userProfile {
            completionBlock?(user: user, userProfile: userProfile)
        }
            
        else{
            let syncClient = AWSCognito.defaultCognito()
            
            // Create a record in a dataset and synchronize with the server
            let dataset = syncClient.openOrCreateDataset("identity")
            if let idFacebook = dataset.stringForKey("idFacebook"){
                self.idFacebook = idFacebook
                
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                dynamoDBObjectMapper.load(AWSUser.self, hashKey: idFacebook, rangeKey: nil).continueWithBlock { (task:AWSTask) -> AnyObject? in
                    if let result = task.result as? AWSUser {
                        self.user = result
                    }
                    
                    return dynamoDBObjectMapper.load(AWSUserProfile.self, hashKey: idFacebook, rangeKey: nil)
                    
                    }.continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            if let result = task.result as? AWSUserProfile {
                                self.userProfile = result
                                completionBlock?(user: self.user!, userProfile: self.userProfile!)
                            }
                            else{
                                completionBlock?(user: nil, userProfile: nil)
                            }
                        }
                        
                        return nil
                        
                    })
            }
                
            else{
                completionBlock?(user: nil, userProfile: nil)
            }
        }
    }
    
    func getUserTask() -> AWSTask{
        if let _ = self.user, _ = self.userProfile {
            return AWSTask(result: nil)
        }
            
        else{
            let syncClient = AWSCognito.defaultCognito()
            
            // Create a record in a dataset and synchronize with the server
            let dataset = syncClient.openOrCreateDataset("identity")
            if let idFacebook = dataset.stringForKey("idFacebook"){
                self.idFacebook = idFacebook
                
                let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                
                return dynamoDBObjectMapper.load(AWSUser.self, hashKey: idFacebook, rangeKey: nil).continueWithBlock { (task:AWSTask) -> AnyObject? in
                    print("AWSManager getUser3Task")
                    if let result = task.result as? AWSUser {
                        self.user = result
                    }
                    
                    return dynamoDBObjectMapper.load(AWSUserProfile.self, hashKey: idFacebook, rangeKey: nil)
                    
                    }.continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        
                        print("AWSManager getUserTask 4")
                        if let result = task.result as? AWSUserProfile {
                            self.userProfile = result
                            print("AWSManager getUserTask 5")
                        }
                        
                        return nil
                        
                    })
            }
                
            else{
                return AWSTask(result: nil)
            }
        }
    }
    
    func getShareMessage() -> String{
        var shareMessage = "You want to save the world and promote peace. It's easy click on this : http://youtuesday.com."
        
        if let promoCode = AWSManager.sharedInstance.getPromoCode(){
            shareMessage = shareMessage + " " + "Here is my code: %@".localizedStringWithVariables(promoCode)
        }
        
        return shareMessage
    }
    
    
    
    func registerForRemoteNotifications(){
        let registrationPushNotification = RegistrationPushNotification()
        registrationPushNotification.register()
    }
    
    func getNbCredits(userCredits: AWSUserCredits?) -> Int?{
        var nbCredits: Int?
        if let _ = userCredits?.nbCredits{
            nbCredits = userCredits!.nbCredits!.integerValue
            if let dateLikeFacebookPage = userCredits?.dateLikeFacebookPage?.getDateYYYYMMdd(){
                let numberOfDaysUntilDate = dateLikeFacebookPage.numberOfDaysUntilDate(NSDate())
                nbCredits = nbCredits! + numberOfDaysUntilDate/7
            }
        }
        
        return nbCredits
    }
    
    
    func getDateFromGroupPartitionKey(groupPartitionKey: String?) -> NSDate?{

        if let dashboardKey = groupPartitionKey{
            
            let dashboardKeyArray = dashboardKey.componentsSeparatedByString("//")
            let dateString = dashboardKeyArray[1]
            return dateString.getDateYYYYMMdd()
        }
        
        return nil
    }
}
