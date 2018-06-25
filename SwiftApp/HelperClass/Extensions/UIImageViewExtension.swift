//
//  UIImageViewExtension.swift
//  Mathews
//
//  Created by Mathews on 04/10/17.
//  Copyright © 2017 Mathews. All rights reserved.
//

import Foundation
import UIKit



// MARK: - UIImageView extension
extension UIImageView {
    
    
    /// Downloads an image from URL and sets it to the imageview
    ///
    /// - Parameters:
    ///   - url: image URL
    ///   - mode: content mode for imageview
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit, defaultImage: UIImage? = nil, completionHandler: @escaping (UIImage?) -> Void) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    DispatchQueue.main.async() { () -> Void in
                        self.image = defaultImage
                        return
                    }
                    return
            }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            completionHandler(image)
            }.resume()
    }
    
    
    /// Alternate method to download image from the URL string
    ///
    /// - Parameters:
    ///   - link: URL string of image
    ///   - mode: content mode for imageview
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit, defaultImage: UIImage? = nil, completionHandler: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: link) else {
            self.image = defaultImage
            return
        }
        downloadedFrom(url: url, contentMode: mode, defaultImage: defaultImage) { (image) in
            completionHandler(image)
        }
    }
}
