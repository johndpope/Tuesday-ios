//
//  MeetingManager.swift
//  Story
//
//  Created by Christopher Rydahl on 05/04/2015.
//  Copyright (c) 2015 Christopher Rydahl. All rights reserved.
//

import Foundation


class MeetingManager{
    
    //Arguments
    var user_in_Group: AWSUser_in_Group?
    
    
    //Singleton
    class var sharedInstance: MeetingManager {
        struct Static {
            static var instance: MeetingManager?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = MeetingManager()
        }
        
        return Static.instance!
    }
    
    
    /*
    * Log out
    */
    func logOut(){
    }
    
    
    func getCurrentUserInGroup (completionBlock : ((user_in_Group: AWSUser_in_Group?, error: NSError?) -> Void)){
        
        print("getCurrentGroup")
        AWSManager.sharedInstance.getUser { (user, userProfile) -> Void in
            if let currentUser = user {
                
                print("getCurrentMeeting 1")
                if let idFacebook = currentUser.idFacebook {
                    
                    print("getCurrentMeeting 2")
                    let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()
                    let queryExpression = AWSDynamoDBQueryExpression()
                    
                    queryExpression.hashKeyAttribute = "idUser"
                    queryExpression.hashKeyValues = idFacebook
                    
                    //dans l'ordre décroissant de dateString
                    queryExpression.scanIndexForward = false
                    queryExpression.limit = 1
                    
                    dynamoDBObjectMapper.query(AWSUser_in_Group.self, expression: queryExpression).continueWithBlock({ (task:AWSTask) -> AnyObject? in
                        
                        print("taskerror \(task.error)")
                        print("taskexception \(task.exception)")
                        if task.error == nil{
                            let paginatedOutput = task.result;
                            if let user_in_Groups = paginatedOutput?.items as? [AWSUser_in_Group]{
                                print("paginatedOutput \(user_in_Groups)")
                                
                                if (user_in_Groups.count > 0){
                                    let user_in_Group = user_in_Groups[0] // le meeting le plus récent
                                    self.user_in_Group = user_in_Group
                                    
                                    self.didGetCurrentUserInGroup(user_in_Group, error: nil, completionBlock: completionBlock)
                                    return nil
                                }
                            }
                        }
                        
                        self.didGetCurrentUserInGroup(nil, error: NSError(domain: "domain", code: 0, userInfo: nil), completionBlock: completionBlock)
                        return nil
                        
                    })
                }
            }
        }
        
    }
    
    
    func didGetCurrentUserInGroup(user_in_Group: AWSUser_in_Group?, error: NSError?, completionBlock : ((user_in_Group: AWSUser_in_Group?, error: NSError?) -> Void)){
        dispatch_async(dispatch_get_main_queue()) {
            completionBlock(user_in_Group: user_in_Group, error: error)
        }
    }
    
    
    
    func getTuesdaySortKey(myGroupSortKey:String, otherGroupSortKey:String) -> String{
        if (myGroupSortKey < otherGroupSortKey){
            return "\(myGroupSortKey)///\(otherGroupSortKey)"
        }
        else{
            return "\(otherGroupSortKey)///\(myGroupSortKey)"
        }
    }
    
    func getIdChat(tuesday:AWSTuesday?)-> String?{
        if let sortKey = tuesday?.sortKey{
            return sortKey;
        }
        return nil
    }
    
}


extension NSDate
{
    
    func numberOfDaysUntilDate(toDateTime: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        var fromDate: NSDate?, toDate: NSDate?
        
        calendar.rangeOfUnit(.Day, startDate: &fromDate, interval: nil, forDate: self)
        calendar.rangeOfUnit(.Day, startDate: &toDate, interval: nil, forDate: toDateTime)
        
        let difference = calendar.components(.Day, fromDate: fromDate!, toDate: toDate!, options: [])
        return difference.day
    }
    
    func isLess(dateToCompare : NSDate) -> Bool
    {
        
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func toYYYYMMddhhmm() -> String{
        let newDateFormat = NSDateFormatter()
        newDateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        return newDateFormat.stringFromDate(self)
    }
    
    func toYYYYMMdd() -> String{
        let newDateFormat = NSDateFormatter()
        newDateFormat.dateFormat = "yyyy-MM-dd"
        return newDateFormat.stringFromDate(self)
    }
    
    func toYYYYMMddhhmmssInUTC() -> String{
        let newDateFormat = NSDateFormatter()
        newDateFormat.timeZone = NSTimeZone(name: "UTC")
        newDateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return newDateFormat.stringFromDate(self)
    }
    
    
    
    func componentsFrom(date:NSDate) -> NSDateComponents{
        return NSCalendar.currentCalendar().components([.Day,.Hour,.Minute,.Second], fromDate: date, toDate: self, options: [])
    }
    
    func isLessOrEqualThanDateWithoutTime(dateToCompare : NSDate) -> Bool
    {
        //textcode : on ne veut pas prendre en compte l'heure
        let startOfSelf = NSCalendar.currentCalendar().startOfDayForDate(self)
        let startOfDateToCompare = NSCalendar.currentCalendar().startOfDayForDate(dateToCompare)
        
        //Declare Variables
        var isLess = true
        
        //Compare Values
        if startOfSelf.compare(startOfDateToCompare) == NSComparisonResult.OrderedDescending
        {
            isLess = false
        }
        
        //Return Result
        return isLess
    }
    
    
    func isLessThanOnHour() -> Bool{
        return (-self.timeIntervalSinceNow/3600) < 1
    }
    
}

extension String{
    func getDateYYYYMMddHHmm() -> NSDate?{
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm"
        return fmt.dateFromString(self)
    }
    
    func getDateYYYYMMdd() -> NSDate?{
        let fmt = NSDateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.dateFromString(self)
    }
    
    func getDateYYYYMMddHHmmssInUTC() -> NSDate?{
        let fmt = NSDateFormatter()
        fmt.timeZone = NSTimeZone(name: "UTC")
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt.dateFromString(self)
    }
}
