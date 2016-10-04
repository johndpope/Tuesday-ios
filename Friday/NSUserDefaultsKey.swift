//
//  NSUserDefaultKey.swift
//  Friday
//
//  Created by Christopher Rydahl on 24/09/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

public struct NSUserDefaultsKey{
    
    static let DEVICE_TOKEN_KEY = "DEVICE_TOKEN_KEY";
    static let COGNITO_DEVICE_TOKEN_KEY = "COGNITO_DEVICE_TOKEN_KEY";
    
    static let IS_NEW_ON_DASHBOARD_LIKE = "isNewOnDashboardLike";
    static let IS_NEW_ON_DASHBOARD_NOPE = "isNewOnDashboardNope";
    static let IS_NEW_ON_TUESDAY = "isNewOnTuesday";
    static let IS_NEW_ON_DASHBOARD_EXPLICATION = "isNewOnDashboardExplication"
    
    static let HAS_ASKED_TO_ENABLE_NOTIFICATION_LOGIN = "hasAskedToEnableNotificationLogin"
    static let HAS_ASKED_TO_ENABLE_NOTIFICATION_DASHBOARD = "hasAskedToEnableNotificationDashboard"
}