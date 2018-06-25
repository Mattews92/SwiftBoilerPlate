//
//  InactivityTimer.swift
//  GuardianRPM
//
//  Created by Mathews on 25/06/18.
//  Copyright © 2017 guardian. All rights reserved.
//

import Foundation
import UIKit

class InactivityTimer: UIApplication {
    
    private var timeout: TimeInterval {
        return Double(IntegerConstants.inactivitytTimeOut * 60)
    }
    private var idleTimer: Timer?
    private var shouldRunIdleTimer = false
    
    func startTimer() {
        self.shouldRunIdleTimer = true
        self.resetTimer()
    }
    
    func stopTimer() {
        self.shouldRunIdleTimer = false
        self.invalidateTimer()
    }
    
    /// Invalidates the timer
    private func invalidateTimer() {
        
        if let timer = self.idleTimer {
            timer.invalidate()
        }
    }
    
    /// Resets the timer to count down from timeout interval
    private func resetTimer() {
        self.invalidateTimer()
        if !self.shouldRunIdleTimer {
            return
        }
        self.idleTimer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(self.sessionTimedOut), userInfo: nil, repeats: false)
    }
    
    /// Posts a notification when the session times out
    @objc private func sessionTimedOut() {
        NotificationCenter.default.post(name: .appTimeOut, object: nil, userInfo: nil)
    }
    
    
    /// Listens to events in the app
    /// Resets the timer if the event is a user interaction
    ///
    /// - Parameter event: event generated in the app
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        if let touches = event.allTouches {
            for touch in touches where touch.phase == UITouchPhase.began {
                if let timer = self.idleTimer {
                    self.resetTimer()
                }
            }
        }
    }
    
}
