//
//  RegistrationPushNotification.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 16/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class RegistrationPushNotification: NSObject {
    
    static let ENDPOINT_ARN_SANDBOX = "arn:aws:sns:eu-west-1:432106747952:app/APNS_SANDBOX/Tuesday"
    static let ENDPOINT_ARN = "arn:aws:sns:eu-west-1:432106747952:app/APNS/Tuesday"
    
    let isSandbox = Params.IS_SANDBOX
    
    var platformApplicationArn: String {
        set{}
        get{
            return isSandbox ? RegistrationPushNotification.ENDPOINT_ARN_SANDBOX : RegistrationPushNotification.ENDPOINT_ARN
        }
    }
    
    func register(){
        
        print("RegistrationPushNotification register")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        print("idFacebook \(AWSManager.sharedInstance.idFacebook)")
        print("deviceTokenData \(userDefaults.objectForKey(NSUserDefaultsKey.DEVICE_TOKEN_KEY))")
        
        if let idFacebook = AWSManager.sharedInstance.idFacebook, deviceTokenData = userDefaults.objectForKey(NSUserDefaultsKey.DEVICE_TOKEN_KEY) as? NSData{
            
            let platformEndpointRequest = AWSSNSCreatePlatformEndpointInput()
            platformEndpointRequest.customUserData = "\(idFacebook)"
            platformEndpointRequest.token = deviceTokenAsString(deviceTokenData)
            platformEndpointRequest.platformApplicationArn = platformApplicationArn
            
            let snsManager = AWSSNS.defaultSNS()
            snsManager.createPlatformEndpoint(platformEndpointRequest, completionHandler: { (response:AWSSNSCreateEndpointResponse?, error:NSError?) -> Void in
                
                print("response \(response)")
                print("error \(error)")
                print("endpointArn \(response?.endpointArn)")
                
                if let endpointArn = response?.endpointArn {
                    let userNotification = AWSUserNotification()
                    userNotification.endpointArn = endpointArn
                    userNotification.idFacebook = idFacebook
                    
                    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                    dynamoDBObjectMapper!.saveUpdateSkipNullAttributes(userNotification).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        print("task.result \(task.result)")
                        print("exception \(task.exception)")
                        print("error \(task.error)")
                        return nil
                    })
                }
                
            })
        }
    }
    
    func deviceTokenAsString(deviceTokenData: NSData) -> String{
        print("deviceTokenData \(deviceTokenData)")
        
        let rawDeviceTring = deviceTokenData.description
        let noSpaces = rawDeviceTring.stringByReplacingOccurrencesOfString(" ", withString: "")
        var tmp1 = noSpaces.stringByReplacingOccurrencesOfString("<", withString: "")
        tmp1 = tmp1.stringByReplacingOccurrencesOfString(">", withString: "")
        
        print("tmp1 \(tmp1)")
        return tmp1;
    }
    
    
}
