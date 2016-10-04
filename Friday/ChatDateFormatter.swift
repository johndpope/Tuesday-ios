//
//  ChatDateFormatter.swift
//  Tuesday
//
//  Created by Christopher Rydahl on 25/12/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class ChatDateFormatter: NSObject {
    
    var dateFormatter:NSDateFormatter = NSDateFormatter()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        
    }
    
    func stringFromDate(date: NSDate) -> String {
        let today = NSDate()
        
        let calender = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let dif = calender!.compareDate(today, toDate: date, toUnitGranularity: NSCalendarUnit.Day)
        if (dif == NSComparisonResult.OrderedSame){
            dateFormatter.dateStyle = NSDateFormatterStyle.NoStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        else{
            dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
            dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        }
        
        return dateFormatter.stringFromDate(date)
        
    }
    
}
