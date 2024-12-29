//
//  DeviceActivityMonitor.swift
//  ProductivityTrackerIOS
//
//  Created by Paris Phan on 12/28/24.
//

import Foundation
import DeviceActivity
import FamilyControls

class DeviceActivityMonitor: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        // Called when monitoring interval starts
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        // Called when monitoring interval ends
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name,
                                       activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        // Called when usage reaches threshold
    }
    
    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        // Called shortly before interval ends
    }
}
