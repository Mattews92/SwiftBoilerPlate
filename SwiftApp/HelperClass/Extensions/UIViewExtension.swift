//
//  UIViewExtension.swift
//  Mathews
//
//  Created by Mathews on 04/10/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation
import UIKit

/// Enum for directions
///
/// - left:
/// - top:
/// - right:
/// - bottom:
/// - topLeft:
/// - topRight:
/// - bottomLeft:
/// - bottomRight:
/// - allSides:
enum Directions {
    case left
    case top
    case right
    case bottom
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case allSides
}

extension Directions {
    var shadowOffset: CGSize {
        switch self {
        case .left:
            return CGSize(width: -10, height: 0)
        case .top:
            return CGSize(width: 0, height: -5)
        case .right:
            return CGSize(width: 10, height: 0)
        case .bottom:
            return CGSize(width: 0, height: 10)
        case .topLeft:
            return CGSize(width: -10, height: -10)
        case .topRight:
            return CGSize(width: 10, height: -10)
        case .bottomLeft:
            return CGSize(width: -10, height: 10)
        case .bottomRight:
            return CGSize(width: 10, height: 10)
        case .allSides:
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: - UIView Extension
extension UIView {
    
    
    /// Defines associatedkeys for storing properties in estension
    private struct AssociatedKey {
        static var badgeKey:   UInt8 = 0
    }

    
    /// New property stored in UIView definition
    var badgeLabel: UILabel? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.badgeKey) as? UILabel
        
        }
        
        set(label) {
            objc_setAssociatedObject(self, &AssociatedKey.badgeKey, label, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
        }
    }
    
    /// Sets a shadow around a UIView
    ///
    /// - Parameters:
    ///   - shadowOffset: offset to be set for the shadow - receives a value from Directions
    ///   - roundedEdge: Boolean flag determines if the UIView require a rounded edge
    ///   - radius: Radius to be set to the shadow.
    ///   - color: Color to be set to the shadow.
    func setShadowLayer(shadowOffset: CGSize, withRoundedEdge roundedEdge: Bool, edgeCornerRadius cornerRadius: CGFloat = 5, shadowRadius radius: Float = 5, shadowColor color: UIColor = UIColor.darkGray) {
        if roundedEdge {
            self.layer.cornerRadius = cornerRadius;
            self.layer.masksToBounds = false;
        }
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowOpacity = 0.5;
    }
    
    
    /// Removes any shadow set to the view
    func removeShadowLayer() {
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.shadowRadius = 0
    }
    
    
    /// Adds a badge to the view on top right corner
    ///
    /// - Parameters:
    ///   - badgeText: text to be displayed on badge
    ///   - textColor: color of text
    ///   - bgColor: background color of the badge
    func addBadgeView(badgeText: String = "", withColor textColor: UIColor = UIColor.white, andBGColor bgColor: UIColor = UIColor.red) {
        if self.badgeLabel == nil {
            self.badgeLabel = UILabel()
            badgeLabel?.translatesAutoresizingMaskIntoConstraints = false
            if let superView = self.superview {
                superView.addSubview(badgeLabel!)
                
                let leadingConstraint = NSLayoutConstraint(item: badgeLabel!, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -15)
                let bottomConstraint = NSLayoutConstraint(item: badgeLabel!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 15)
                let heightConstraint = NSLayoutConstraint(item: badgeLabel!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
                let widthConstraint = NSLayoutConstraint(item: badgeLabel!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30)
                
                superView.addConstraints([leadingConstraint, bottomConstraint, widthConstraint, heightConstraint])
                superView.bringSubview(toFront: badgeLabel!)
                self.backgroundColor = UIColor.green
                badgeLabel?.backgroundColor = bgColor
                badgeLabel?.textColor = textColor
                badgeLabel?.textAlignment = .center
                badgeLabel?.text = badgeText
                badgeLabel?.font = UIFont.systemFont(ofSize: 15)
                
                badgeLabel?.layer.cornerRadius = 15
                badgeLabel?.clipsToBounds = true
                
            }
        }
    }
    
    
    /// Removes the badge from the view
    func removeBadgeView() {
        self.badgeLabel?.removeFromSuperview()
        self.badgeLabel = nil
    }
    
    /// Sets rounded corners for the UIView
    ///
    /// - Parameters:
    ///   - corners: Corners for which
    ///   - radius: Corner radius for the rounded corners
    func roundCorners(corners: UIRectCorner, withCornerRadius radius: CGFloat) {
        DispatchQueue.main.async {
            let maskPath: UIBezierPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let maskLayer: CAShapeLayer = CAShapeLayer()
            maskLayer.frame = self.bounds
            maskLayer.path = maskPath.cgPath
            self.layer.mask = maskLayer
            self.layer.masksToBounds = true;
        }
    }
    
    /// Adds a no content available label to the UIView - mostly list views
    ///
    /// - Parameter message: message to be displayed in the label
    func addNoContentLabel(message: String, textColor color: UIColor = UIColor().color(fromHex:"#515A69")) {
        for view in self.subviews {
            if view.tag == 1029 {
                /* return if NoContentLabel is already added to the UIView */
                return
            }
        }
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.font = UIFont(name: "PTSans-Narrow", size: 15)
        label.textColor = color
        label.backgroundColor = UIColor.clear
        label.tag = 1029
        label.numberOfLines = 0
        label.preferredMaxLayoutWidth = self.bounds.size.width - 50
        self.addSubview(label)
        self.bringSubview(toFront: label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: label, attribute: .centerX, multiplier: 1.0, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .centerY, multiplier: 1.0, constant: 0)
        self.addConstraints([horizontalConstraint, verticalConstraint])
    }
    
    /// Removes the no content available label added to the UIView
    func removeNoContentLabel() {
        for view in self.subviews {
            if view.tag == 1029 {
                view.removeFromSuperview()
            }
        }
    }
    
    /// Adds a no content image to the UIView
    ///
    /// - Parameter image: image to be displayed on the view
    func addNoContentImage(image: UIImage?, backgroundColor color: UIColor = UIColor.clear) {
        self.removeNoContentImage()
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = color
        imageView.tag = 1030
        self.addSubview(imageView)
        self.bringSubview(toFront: imageView)
        
        let horizontalOffset = (self.frame.size.width - (self.frame.size.width * 2 / 3)) / 2
        let verticalOffset = (self.frame.size.height - (self.frame.size.height * 2 / 3)) / 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: verticalOffset)
        let leading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: horizontalOffset)
        let trailing = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -horizontalOffset)
        let bottom = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: -verticalOffset)
        
        NSLayoutConstraint.activate([top, leading, trailing, bottom])
    }
    
    /// Removes the no content image added to the UIView
    func removeNoContentImage() {
        for view in self.subviews {
            if view.tag == 1030 {
                view.removeFromSuperview()
            }
        }
    }
    
    func disableView(isDisabled:Bool) {
        self.isUserInteractionEnabled = isDisabled ? false : true
        self.alpha = isDisabled ? 0.5 : 1.0
    }
    
    
    
    /// Returns the first responder of the view
    ///
    /// - Returns: first responder
    func firstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.firstResponder() {
                return view
            }
        }
        
        return nil
    }
}
