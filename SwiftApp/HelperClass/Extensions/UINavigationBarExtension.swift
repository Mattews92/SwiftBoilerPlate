//
//  UINavigationBarExtension.swift
//  GuardianRPM
//
//  Created by Mathews on 22/11/17.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    
    var shadow: Bool {
        get {
            return false
        }
        set {
            if newValue {
                self.setShadowLayer(shadowOffset: CGSize(width: 0, height: 1), withRoundedEdge: false, shadowRadius: 2.0, shadowColor: UIColor.lightGray)
            }
        }
    }
}
