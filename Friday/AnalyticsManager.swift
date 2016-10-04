//
//  AnalyticsManager.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 29/02/2016.
//  Copyright © 2016 Christopher Rydahl. All rights reserved.
//

import UIKit

class AnalyticsManager {
    
    static let APP_ID = "c1e2063187ca418f9350acf67d754f91";
    static let IDENTITY_POOL_ID = "us-east-1:14c5b769-dba6-4908-8f01-3d722f036eee";
    
    static let AppEventNameBeginRegistration = "BeginRegistration";
    
    static let FACEBOOK_AppEventNameCompletedRegistration = FBSDKAppEventNameCompletedRegistration;
    static let AMAZON_AppEventNameCompletedRegistration = "CompletedRegistration"
    
    static let FACEBOOK_AppEventNameCompletedTutorial = FBSDKAppEventNameCompletedTutorial;
    static let AMAZON_AppEventNameCompletedTutorial = "CompletedTutorial"
    
    static let AppEventNameInviteFriend = "InviteFriend";
    static let AppEventAttributeKeyCanal = "Canal";
    static let AppEventAttributeValueCanalMessenger = "Messenger";
    static let AppEventAttributeValueCanalFacebook = "Facebook";
    static let AppEventAttributeValueCanalSMS = "SMS";
    static let AppEventAttributeValueCanalEmail = "Email";
    
    
    static func logEvent(amazonEventName: String?, facebookEventName: String?){
        
        logEventWithAttribute(amazonEventName, facebookEventName: facebookEventName, attributeValue: nil, attributeKey: nil)
        
    }
    
    
    static func logEventWithAttribute(amazonEventName: String?, facebookEventName: String?, attributeValue: String?, attributeKey: String?){
        
        if let amazonEventName = amazonEventName{
            let analytics = AWSMobileAnalytics(forAppId: APP_ID, identityPoolId: IDENTITY_POOL_ID)
            let eventClient = analytics.eventClient;
            let levelEvent = eventClient.createEventWithEventType(amazonEventName)
            if let attributeValue = attributeValue, attributeKey = attributeKey{
                levelEvent.addAttribute(attributeValue, forKey: attributeKey)
            }
            eventClient.recordEvent(levelEvent)
            eventClient.submitEvents()
        }
        
        if let facebookEventName = facebookEventName{
            if let attributeValue = attributeValue, attributeKey = attributeKey{
                FBSDKAppEvents.logEvent(facebookEventName, parameters: [attributeKey:attributeValue])
            }
            else{
                FBSDKAppEvents.logEvent(facebookEventName);
            }
        }
        
    }
}
