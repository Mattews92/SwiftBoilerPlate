//
//  CALayerExtension.swift
//  GuardianRPM
//
//  Created by Mathews on 06/04/18.
//  Copyright © 2018 guardian. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    
    func shake(duration: TimeInterval = TimeInterval(0.5)) {
        
        let animationKey = "shake"
        removeAnimation(forKey: animationKey)
        
        let kAnimation = CAKeyframeAnimation(keyPath: "transform.rotation")
        kAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        kAnimation.duration = duration
        
        var maxRotationAngle = Float.pi / 4
        var values = [Float]()
        
        let minOffset = maxRotationAngle * 0.1
        
        repeat {
            
            values.append(-maxRotationAngle)
            values.append(maxRotationAngle)
            maxRotationAngle *= 0.5
        } while maxRotationAngle > minOffset
        
        values.append(0)
        kAnimation.values = values
        add(kAnimation, forKey: animationKey)
    }
}
