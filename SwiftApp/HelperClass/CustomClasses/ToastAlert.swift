
//  Created by Riaz on 14/02/18.

import UIKit

class ToastAlert
{
    let label = UILabel(frame: CGRect.zero)
    let bgView = UIView(frame: CGRect.zero)
    
    class var shared: ToastAlert {
        struct Static {
            static let instance: ToastAlert = ToastAlert()
        }
        return Static.instance
    }
    
    private func showToastAlert(backgroundColor:UIColor, textColor:UIColor, message:String)
    {
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    
        bgView.frame = CGRect(x: 15, y: -50, width: appDelegate.window!.frame.size.width - 30, height: 35)
        bgView.backgroundColor = backgroundColor
        bgView.addSubview(label)
        bgView.alpha = 1
        bgView.layer.cornerRadius = 4
        appDelegate.window!.addSubview(bgView)
        
        label.textAlignment = NSTextAlignment.center
        label.text = message
        label.font = UIFont(name: "PTSans-Narrow", size: 15)!
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor =  UIColor.clear
        label.textColor = textColor //TEXT COLOR
        label.sizeToFit()
        label.numberOfLines = 4
        label.layer.shadowColor = UIColor.gray.cgColor
        label.layer.shadowOffset = CGSize(width: 4, height: 3)
        label.layer.shadowOpacity = 0.3
        label.frame = CGRect(x: 10, y: 0, width: bgView.frame.size.width - 20, height: 35)
        label.alpha = 1
        label.layer.cornerRadius = 4
        
        var viewToTopFrame: CGRect = bgView.frame;
        viewToTopFrame.origin.y = 60;
        
        UIView.animate(withDuration
            :0.5, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.bgView.frame = viewToTopFrame
        },  completion: {
            (value: Bool) in
            viewToTopFrame.origin.y = -50
            UIView.animate(withDuration:2.0, delay: 3.0, usingSpringWithDamping: 0, initialSpringVelocity: 0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.bgView.frame = viewToTopFrame
            },  completion: {
                (value: Bool) in
                self.bgView.removeFromSuperview()
            })
        })
    }
    
    private func showNotificationBar(backgroundColor:UIColor, textColor:UIColor, message:String)
    {
        self.bgView.removeFromSuperview()
        
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        label.textAlignment = NSTextAlignment.left
        label.text = message
        label.font = UIFont(name: "PTSans-NarrowBold", size: 18)!
        label.adjustsFontSizeToFitWidth = true
        
        label.backgroundColor =  backgroundColor //UIColor.whiteColor()
        label.textColor = textColor //TEXT COLOR
        
        label.sizeToFit()
        label.numberOfLines = 4
        label.frame = CGRect(x: 15, y: 0, width: appDelegate.window!.frame.size.width - 30, height: 65)
        label.alpha = 1
        label.layer.cornerRadius = 3
        bgView.frame = CGRect(x: 0, y: -65, width: appDelegate.window!.frame.size.width, height: 65)
        bgView.backgroundColor = UIColor.gray
        bgView.addSubview(label)
        appDelegate.window!.addSubview(bgView)
        
        let basketTopFrame: CGRect =  CGRect(x: 0, y: 0, width: appDelegate.window!.frame.size.width , height: 65)
        
        UIView.animate(withDuration
            :2.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.bgView.frame = basketTopFrame
        },  completion: {
            (value: Bool) in
            UIView.animate(withDuration:2.0, delay: 2.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.label.alpha = 0
                self.bgView.alpha = 0
            },  completion: {
                (value: Bool) in
                self.bgView.removeFromSuperview()
            })
        })
    }
    
    class func removeToastAlert() {
        DispatchQueue.main.async {
            let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.layer.removeAllAnimations()
            
            self.shared.bgView.layer.removeAllAnimations()
            self.shared.bgView.removeFromSuperview()
        }
    }
    
    class func showSuccessMessage(message:String)
    {
        DispatchQueue.main.async {
            ToastAlert.shared.showToastAlert(backgroundColor: UIColor.black, textColor: UIColor.white, message: message)
        }
    }
    
    class func showErrorMessage(message:String)
    {
        DispatchQueue.main.async {
            ToastAlert.shared.showToastAlert(backgroundColor: UIColor.black, textColor: UIColor.red, message: message)
        }
    }
    
    class func showForGroundNotification(message:String)
    {
        ToastAlert.shared.showNotificationBar(backgroundColor: UIColor.black, textColor: UIColor.white, message: message)
    }
}

