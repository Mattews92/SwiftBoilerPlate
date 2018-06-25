//
//  UIButtonExtension.swift
//  GuardianRPM
//
//  Created by Riaz on 13/11/17.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setImageFromLink(_ urlString: String, for State:UIControlState) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.setImage(image, for: State)
            }
            }.resume()
    }
}
