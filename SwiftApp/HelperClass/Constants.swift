//
//  Constants.swift
//  Mathews
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation
import UIKit


/// Structure stores the integer constants
struct IntegerConstants {
    static let passwordMinLength = 8
    static let passwordMaxLength = 15
    static let textfieldMaxLength = 40
    static let phoneNumberMaxLength = 10
    static let inactivitytTimeOut = 10 //automatic app inactivity locking timeout in minutes
    static let appBackgroundLockOffset = 2 //lock the screen if app background time exceeds the offset in minutes
}


/// Structure stores the Storyboard IDs
struct StoryBoardID {
    static let mainStoryBoard = "Main"
}

/// Structure stores the string keys
struct StringKeyConstants {
    static let accessTokenKey = "ACCESS_TOKEN"
    static let refreshTokenKey = "REFRESH_TOKEN"
    static let userIDKey = "USER_ID"
    static let deviceTokenKey = "DEVICE_TOKEN"
    static let passwordKey = "USER_PASSWORD"
    static let userNameKey = "USER_USERNAME"
    static let organisationIDKey = "USER_ORGANISATION_ID"
    static let resignTimeStamp = "RESIGN_TIMESTAMP"
    static let timeZoneKey = "TIMEZONE"
    static let orgTimeZone = "ORG_TIMEZONE"
    static let timeZoneType = "TIMEZONE_TYPE"
    static let deviceTimeZone = "DEVICE_TIMEZONE"
}

/// Structure stores the display date formats
struct DateFormats {
    static let timeFormat = "hh:mm a"
    static let dateFormat = "MMM dd, yyyy"
    static let dateTimeFormat = "hh:mm a MMM dd, yyyy"
}
