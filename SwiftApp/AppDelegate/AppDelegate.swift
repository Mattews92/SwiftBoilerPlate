//
//  AppDelegate.swift
//  SwiftApp
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2018 Mathews. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var overlayView: UIView?
    var restrictToPortrait = true
    var shouldAutoLockScreen = false
    var appIsLocked = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.configureNavigationBar()
        self.initializeIQKeyBoardManager()
        self.resetApplicationBadge()
        /*
         * Uncomment to add Inactivity Timer Lock to the application
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationDidTimeOut), name: .appTimeOut, object: nil)
        */
        return true
    }
    
    
    /// Delegate invoked when device attempts rotation
    ///
    /// - Parameters:
    ///   - application: UIApplication instance
    ///   - window: keywindow of UIApplication
    /// - Returns: supported interface orientations
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if self.restrictToPortrait {
            return .portrait
        }
        return .allButUpsideDown
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UserDefaults.standard.set(Date(), forKey: StringKeyConstants.resignTimeStamp)
        if self.shouldAutoLockScreen {
            self.addAppOverlayView()
        }
        application.ignoreSnapshotOnNextApplicationLaunch()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        self.removeAppOverlayView()
        if UserDefaults.standard.value(forKey: StringKeyConstants.accessTokenKey) != nil {
            let resignTimestamp = UserDefaults.standard.value(forKey: StringKeyConstants.resignTimeStamp) as? Date
            if self.shouldAutoLockScreen && (Date().timeIntervalSince(resignTimestamp ?? Date()) >= Double(IntegerConstants.appBackgroundLockOffset * 60)) {
                self.applicationDidTimeOut()
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        self.removeAppOverlayView()
        self.resetApplicationBadge()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    
    /// Configures navigation bar in the scope of the application
    fileprivate func configureNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = UIColor.red
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.red, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)]
        
        
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "backButton")?.withRenderingMode(.alwaysOriginal)
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -300, vertical: 0), for: .default)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().isTranslucent = false
        
        UINavigationBar.appearance().shadow = true
        
    }
    
    /// Initializes the IQKeyBoardManager for the app
    /// IQKeyBoardManager handles the view scrolling and textfield next buttons when keyboard appear
    fileprivate func initializeIQKeyBoardManager() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().toolbarTintColor = UIColor.white
        IQKeyboardManager.sharedManager().toolbarBarTintColor = UIColor.green
        IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false
    }
    
    
    /// Resets the application badge number to zero
    fileprivate func resetApplicationBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    /*
     * Add an overlay view to the app when moving to background
     * Overlay is added to mask the PHI from other users
     */
    fileprivate func addAppOverlayView() {
        if self.overlayView != nil {
            return
        }
        self.overlayView = UIView()
        self.overlayView?.backgroundColor = UIColor.white
        self.window?.addSubview(self.overlayView!)
        self.window?.bringSubview(toFront: self.overlayView!)
        
        self.overlayView?.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = NSLayoutConstraint(item: self.overlayView!, attribute: .top, relatedBy: .equal, toItem: self.window!, attribute: .top, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: self.overlayView!, attribute: .leading, relatedBy: .equal, toItem: self.window!, attribute: .leading, multiplier: 1, constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.overlayView!, attribute: .trailing, relatedBy: .equal, toItem: self.window!, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.overlayView!, attribute: .bottom, relatedBy: .equal, toItem: self.window!, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, bottomConstraint])
        
    }
    
    /*
     * Removes the overlay view added to the app when moving to background
     * Method is invoked when returning to foreground
     */
    fileprivate func removeAppOverlayView() {
        if self.overlayView != nil {
            self.overlayView?.removeFromSuperview()
            self.overlayView = nil
        }
    }
    
    /// Activates auto locking of screen in
    /// Foreground inactivity for a time period set in IntegerConstants.inactivitytTimeOut
    /// Background to foreground transitions
    func registerForInactivityTimer() {
        self.shouldAutoLockScreen = true
        (UIApplication.shared as? InactivityTimer)?.startTimer()
    }
    
    /// Deactivate auto locking of screen
    func unregisterFromInactivityTimer() {
        self.shouldAutoLockScreen = false
        (UIApplication.shared as? InactivityTimer)?.stopTimer()
    }
    
    /// Invoked when application times out
    @objc func applicationDidTimeOut() {
        self.appIsLocked = true
        (UIApplication.shared as? InactivityTimer)?.stopTimer()
        //Load lock screen
    }
    
    /// Pulls the app version and build from the plist
    ///
    /// - Returns: current version and build of the app
    func getAppVersion() -> (String, String) {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return (version, build)
    }
    
    /// Logout from application action
    func logoutAction(isSessionExpired: Bool) {
    }
}

