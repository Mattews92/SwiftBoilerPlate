//
//  UIImageExtension.swift
//  Mathews
//
//  Created by Mathews on 13/11/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    /// Resizes the image to the specified size
    ///
    /// - Parameter targetSize: size to which image is to be resized
    /// - Returns: resized image
    func resize(to targetSize: CGSize) -> UIImage? {
        let imageSize = self.size
        
        let widthRatio  = targetSize.width  / imageSize.width
        let heightRatio = targetSize.height / imageSize.height
        
        // form a rect to resize the image to depending on the orientation of the image
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // resize to the rect using the ImageContext
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
