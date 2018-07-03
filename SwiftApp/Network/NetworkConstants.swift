//
//  NetworkConstants.swift
//  SwiftApp
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2018 Mathews. All rights reserved.
//

import Foundation

struct NetworkConstants {
    static let serverUrl = ""
    
    //API sub URLs
    static let login = ""
    static let refreshToken = ""
}


/**
 API Error status
 
 - Success:      API request success
 - Failure:      API request falure
 - NetworkError: General network errors
 - NoInternet:   No internet connection
 */
enum APIErrorStatus {
    case success
    case failure
    case networkError
    case noInternet
    case sessionExpired
}
