//
//  DoubleExtension.swift
//  Mathews
//
//  Created by Mathews on 27/10/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation

extension Double {
    
    
    /// Returns Date from UNIX timestamp
    ///
    /// - Returns: Date generated from UTC
    func date() -> Date {
        let date = Date(timeIntervalSince1970: self / 1000)
        return  date
    }
    
    /// Formats the UNIX timestamp to specified date formatted string
    ///
    /// - Parameter dateFormat: required date format
    /// - Returns: formatted date string
    func formatUTCToDateString(dateFormat: String) -> String {
        let date = self.date()
        return date.string(withDateFormat: dateFormat)
    }
    
    
    /// Formats the difference of UNIX timestamp to current date in months, weeks, days, hours, minutes and seconds
    ///
    /// - Returns: formatted time difference string in terms of Months, weeks, days, hours or minutes
    func formatTimeDifferenceFromUTC() -> String {
        let dateInput = self.date().convertToLocalTime(fromTimeZone: TimeZone()!.getTimeZone(isGMT: false))
        let components = Calendar.current.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: dateInput, to: Date())
        if components.year ?? 0 > 1 {
            return "\(components.year ?? 0) years ago"
        }
        if components.year ?? 0 == 1 {
            return "\(components.year ?? 0) year ago"
        }
        if components.month ?? 0 > 1 {
            return "\(components.month ?? 0) months ago"
        }
        if components.month ?? 0 == 1 {
            return "\(components.month ?? 0) month ago"
        }
        if components.weekOfMonth ?? 0 >= 2 {
            return "\(components.weekOfMonth ?? 0) weeks ago"
        }
        if components.weekOfMonth ?? 0 == 1 {
            return "\(components.weekOfMonth ?? 0) week ago"
        }
        if components.day ?? 0 >= 2 {
            return "\(components.day ?? 0) days ago"
        }
        if components.day ?? 0 == 1 {
            return "\(components.day ?? 0) day ago"
        }
        if components.hour ?? 0 >= 2 {
            return "\(components.hour ?? 0) hours ago"
        }
        if components.hour ?? 0 == 1 {
            return "\(components.hour ?? 0) hour ago"
        }
        if components.minute ?? 0 >= 2 {
            return "\(components.minute ?? 0) minutes ago"
        }
        if components.minute ?? 0 == 1 {
            return "\(components.minute ?? 0) minute ago"
        }
        if components.second ?? 0 >= 10 {
            return "A few seconds ago"
        }
        if components.second ?? 0 < 10 {
            return "Just now"
        }
        return "Just now"
    }
    
    
    /// Calculates the difference between current date and given timestamp
    ///
    /// - Parameter component: DateComponent in which difference is to be calculated
    /// - Returns: difference in diven component
    func differenceInDate(component: Calendar.Component) -> Int {
        let dateInput = self.date()
        return dateInput.differenceInDate(component: component)
    }
    
    /// Format the double value to a clean string
    ///
    /// - Returns: 3.11 to 3.11 & 3.00 to 3
    
    var formateDoubleValueToCleanText: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.1f", self)
    }
    
    
    /// Formats the double value to trim the decimal part completely
    ///
    /// - Returns: 3 for 3.0, 3.1 and 3.12
    var decimalTrimmed: UInt64 {
        return UInt64(self)
    }
    
    
    /// Splits the milliseconds into Hours, minutes and seconds
    ///
    /// - Returns: Hours, minutes and seconds
    func milliSecondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        let seconds = Int(self/1000)
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    /// Rounds the milliseconds to minute precision
    ///
    /// - Returns: value rounded to minutes in milliseconds (13 digit)
    func roundSeconds() -> Int {
        var (hours, minutes, seconds) = self.milliSecondsToHoursMinutesSeconds()
        if seconds >= 30 {
            minutes += 1
        }
        return (hours * 3600 + minutes * 60) * 1000
    }
}

