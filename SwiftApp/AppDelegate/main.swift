//
//  main.swift
//  Mathews
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2017 Mathews. All rights reserved.
//

import UIKit
import Foundation

// Add the main.swift to the project target to add InactivityTimer Lock to the project
// Comment the @UIApplicationMain from AppDelegate file
UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(
            to: UnsafeMutablePointer<Int8>.self,
            capacity: Int(CommandLine.argc)),
    NSStringFromClass(InactivityTimer.self),
    NSStringFromClass(AppDelegate.self)
)

