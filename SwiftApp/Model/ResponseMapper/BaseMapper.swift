//
//  BaseMapper.swift
//  GuardianRPM
//
//  Created by Mathews on 27/10/17.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseResponse: Mappable {
    var status: Bool?
    var message: String?
    var code: Int?
    
    required init?(map: Map) {
        mapping(map: map)
    }
    
    func mapping(map: Map) {
        self.status         <- map["status"]
        self.message        <- map["message"]
        self.code           <- map["code"]
    }
}
