//
//  UITableViewCellExtension.swift
//  Mathews
//
//  Created by Mathews on 13/01/18.
//  Copyright © 2018 Mathews. All rights reserved.
//

import Foundation
import UIKit

extension UITableViewCell {
    
    func drawSectionBorder(tableView: UITableView, forCellWith indexPath: IndexPath, tableviewRequireRowSeperator requireSeperator: Bool = false) {
        if (self.responds(to: #selector(getter: UIView.tintColor))) {
            let cornerRadius: CGFloat = 5
            self.backgroundColor = UIColor.clear
            let layer: CAShapeLayer  = CAShapeLayer()
            let pathRef: CGMutablePath  = CGMutablePath()
            let bounds: CGRect  = self.bounds.insetBy(dx: 10, dy: 0)
            if (indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
                pathRef.__addRoundedRect(transform: nil, rect: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
            } else if (indexPath.row == 0) {
                pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.maxY))
                pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.minY), tangent2End: CGPoint(x:bounds.midX,y:bounds.minY), radius: cornerRadius)
                
                pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.minY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
                pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.maxY))
            } else if (indexPath.row == tableView.numberOfRows(inSection: indexPath.section)-1) {
                
                pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.minY))
                pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.midX,y:bounds.maxY), radius: cornerRadius)
                
                pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.maxX,y:bounds.midY), radius: cornerRadius)
                pathRef.addLine(to: CGPoint(x:bounds.maxX,y:bounds.minY))
                
            } else {
                if requireSeperator {
                    pathRef.addRect(bounds)
                }
                else {
                    pathRef.move(to: CGPoint(x:bounds.minX,y:bounds.minY))
                    pathRef.addArc(tangent1End: CGPoint(x:bounds.minX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.midX,y:bounds.maxY), radius: 0)
                    pathRef.move(to: CGPoint(x:bounds.maxX,y:bounds.minY))
                    pathRef.addArc(tangent1End: CGPoint(x:bounds.maxX,y:bounds.maxY), tangent2End: CGPoint(x:bounds.midX,y:bounds.maxY), radius: 0)
                }
            }
            layer.path = pathRef
            //CFRelease(pathRef)
            //set the border color
            layer.strokeColor = UIColor.lightGray.cgColor;
            //set the border width
            layer.lineWidth = 1
            layer.fillColor = UIColor(white: 1, alpha: 1.0).cgColor
            
            
//            if addLine  {
//                let lineLayer: CALayer = CALayer()
//                let lineHeight: CGFloat  = (1 / UIScreen.main.scale)
//                lineLayer.frame = CGRect(x:bounds.minX, y:bounds.size.height-lineHeight, width:bounds.size.width, height:lineHeight)
//                lineLayer.backgroundColor = tableView.separatorColor!.cgColor
//                layer.addSublayer(lineLayer)
//            }
            
            let testView: UIView = UIView(frame:bounds)
            testView.layer.insertSublayer(layer, at: 0)
            testView.backgroundColor = UIColor.clear
            self.backgroundView = testView
        }
    }
}
