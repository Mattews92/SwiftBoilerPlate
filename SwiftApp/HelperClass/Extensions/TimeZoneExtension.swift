//
//  TimeZoneExtension.swift
//  Mathews
//
//  Created by Mathews on 30/01/18.
//  Copyright © 2018 Mathews. All rights reserved.
//

import Foundation

extension TimeZone {
    
    init?() {
        self.init(abbreviation: "GMT")
    }
    
    func getTimeZone(isGMT:Bool = false)-> TimeZone {
        if !isGMT {
            if let identifier = UserDefaults.standard.value(forKey: StringKeyConstants.timeZoneKey) as? String {
                return TimeZone(identifier: identifier) ?? TimeZone.current
            }
            return TimeZone.current
        }
        return TimeZone(identifier: "GMT") ?? TimeZone.current
    }
    
    func getAppTimezoneAbbrevation() -> String {
        if let identifier = UserDefaults.standard.value(forKey: StringKeyConstants.timeZoneKey) as? String {
            return identifier
        }
        return TimeZone.current.abbreviation() ?? ""
    }
}
