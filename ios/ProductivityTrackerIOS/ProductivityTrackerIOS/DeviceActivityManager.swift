//
//  DeviceActivityManager.swift
//  ProductivityTrackerIOS
//
//  Created by Paris Phan on 12/27/24.
//

import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings

class DeviceActivityManager: ObservableObject {
    static let shared = DeviceActivityManager()
    private let activityCenter = DeviceActivityCenter()
    private let selectionCenter = FamilyActivitySelection.shared
    @Published var activityReport: [String: TimeInterval] = [:]
    
    func startMonitoring() {
        // Create a schedule for monitoring (24 hours)
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        // Create a DeviceActivityName (identifier for the monitoring session)
        let activityName = DeviceActivityName("daily.tracking")
        
        // Create a monitoring configuration
        let configuration = DeviceActivityMonitoringConfiguration(
            activityName: activityName,
            schedule: schedule,
            familyActivitySelection: selectionCenter.selection,
            threshold: DateComponents(minute: 1)
        )
        
        do {
            try activityCenter.startMonitoring(configuration)
            print("Monitoring started successfully.")
        } catch {
            print("Failed to start monitoring: \(error.localizedDescription)")
        }
    }
    
    func fetchScreenTimeReport() {
        // This will be implemented in the DeviceActivityMonitor
    }
}
