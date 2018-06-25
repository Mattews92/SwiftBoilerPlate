//
//  UITextFieldExtension.swift
//  GuardianRPM
//
//  Created by Mathews on 04/10/17.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import UIKit

// MARK: - UITextField extension
extension UITextField {
    
    
    /// Sets a padding to the textField in the specified diretion
    ///
    /// - Parameter direction: direction in which padding is to be set
    func setPaddingtoTextField (direction: Directions, paddingWidth: Int = 10) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: paddingWidth, height: 10))
        switch direction {
        case Directions.left:
            self.leftView = paddingView
            self.leftViewMode = .always
        case Directions.right:
            self.leftView = paddingView
            self.rightView = paddingView
            self.rightViewMode = .always
            self.leftViewMode = .always
        default:
            break
        }
    }
}
