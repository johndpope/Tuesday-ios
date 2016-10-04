//
//  DateManager.swift
//  Friday
//
//  Created by Christopher Rydahl on 13/10/2015.
//  Copyright © 2015 Christopher Rydahl. All rights reserved.
//

import Foundation

class DateManager: NSObject {
    
    static func getNextDate(weekday: Int) -> (NSDate, String, String, Int){
        let today = NSDate()
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        
        // Get the weekday component of the current date
        let weekdayComponents = gregorian!.components(NSCalendarUnit.Weekday, fromDate: today)
        
        /*
        Create a date components to represent the number of days to add to the current date.
        The weekday value for Friday in the Gregorian calendar is 6, so add the difference between 6 and today to get the number of days to add.
        Actually, on Saturday that will give you -1, so you want to subtract from 13 then take modulo 7
        */
        
        var nbDayToAdd = (weekday + 7 - weekdayComponents.weekday) % 7
        if (nbDayToAdd < 3){
            nbDayToAdd + 7
        }
        
        
        let componentsToAdd = NSDateComponents()
        componentsToAdd.setValue(nbDayToAdd, forComponent: NSCalendarUnit.Day)
        
        var date =  gregorian?.dateByAddingComponents(componentsToAdd, toDate: today, options: [])
        
        /*
        friday now has the same hour, minute, and second as the original date (today).
        To normalize to midnight, extract the year, month, and day components and create a new date from those components.
        */
        let components = gregorian!.components(([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]), fromDate: date!)
        
        // And to set the time to 20:00
        components.timeZone = NSTimeZone(name: "UTC")
        components.setValue(20, forComponent: NSCalendarUnit.Hour)
        
        date = gregorian?.dateFromComponents(components)
        
        /*var dayOfWeek = ""
        switch(weekday){
        case 1:
            dayOfWeek = "Sunday".localized
            break;
        case 2:
            dayOfWeek = "Monday".localized
            break;
        case 3:
            dayOfWeek = "Tuesday".localized
            break;
        case 4:
            dayOfWeek = "Wednesday".localized
            break;
        case 5:
            dayOfWeek = "Thursday".localized
            break;
        case 6:
            dayOfWeek = "Friday".localized
            break;
        default:
            dayOfWeek = "Saturday".localized
            break;
        }
        var labelText = "Next %@".localizedStringWithVariables(dayOfWeek)
        if (nbDayToAdd >= 7){
            labelText = "%@ of next week".localizedStringWithVariables(dayOfWeek)
        }
        
        var subtitleLabelText = ""
        if (nbDayToAdd == 0){
            subtitleLabelText = "Today".localized
        }else if(nbDayToAdd == 1){
            subtitleLabelText = "Tomorrow".localized
        }else{
            subtitleLabelText = "%@ days from now".localizedStringWithVariables(String(nbDayToAdd))
        }*/
        
        
        
        //return (date!, labelText, subtitleLabelText, nbDayToAdd)
        
        return (date!, getTitle(date!, isTime: false), getSubtitle(date!), nbDayToAdd)
    }
    
    static func getTitleSubtitleFromDate(date: NSDate) -> (String, String){
        return (getTitle(date, isTime: true), getSubtitle(date))
    }
    
    static func getTitleSubtitleFromDateNoTime(date: NSDate) -> (String, String){
        return (getTitle(date, isTime: false), getSubtitle(date))
    }
    
    static func getTitle(nextDate: NSDate, isTime _isTime: Bool) -> String{
        let today = NSDate()
        let nbDayToAdd = today.numberOfDaysUntilDate(nextDate)
        var labelText = "";
        
        if (nbDayToAdd < 7){
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale.currentLocale()
            formatter.dateFormat = "EEEE"
            
            if (!_isTime){
                labelText = "Next %@".localizedStringWithVariables(formatter.stringFromDate(nextDate))
            }
            else{
                let timeFormatter = NSDateFormatter()
                timeFormatter.locale = NSLocale.currentLocale()
                timeFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
                
                labelText = "Next %@ at %@".localizedStringWithVariables(formatter.stringFromDate(nextDate), timeFormatter.stringFromDate(nextDate))
            }
        }
            
        else{
            var dateComponents = "EEEEMMMMddHHmm"
            if (!_isTime){
                dateComponents = "EEEEMMMMdd"
            }
            let dateFormat = NSDateFormatter.dateFormatFromTemplate(dateComponents, options: 0, locale: NSLocale.currentLocale())
            let formatter2 = NSDateFormatter()
            formatter2.dateFormat = dateFormat
            labelText = formatter2.stringFromDate(nextDate)
        }
        
        return labelText
    }
    
    
    static func getSubtitle(nextDate: NSDate) -> String{
        let today = NSDate()
        let nbDayToAdd = today.numberOfDaysUntilDate(nextDate)
        
        var subtitleLabelText = ""
        if (nbDayToAdd == 0){
            subtitleLabelText = "Today".localized
        }else if(nbDayToAdd == 1){
            subtitleLabelText = "Tomorrow".localized
        }else{
            subtitleLabelText = "%@ days from now".localizedStringWithVariables(String(nbDayToAdd))
        }
        
        return subtitleLabelText
    }
    
    
}
