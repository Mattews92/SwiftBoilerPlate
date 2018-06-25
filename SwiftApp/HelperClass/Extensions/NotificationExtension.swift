//
//  NotificationExtension.swift
//  Mathews
//
//  Created by Mathews on 22/12/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let appTimeOut = Notification.Name("com.swiftapp.appTimedOut")
    static let appUnlocked = Notification.Name("com.swiftapp.appUnLocked")
    static let remoteNotificationRecieved = Notification.Name("com.swiftapp.remoteNotificationRecieved")
}
