//
//  ActivityLogger.swift
//  ProductivityTracker
//
//  Created by Paris Phan on 12/27/24.
//

import Foundation
import AppKit
import CoreGraphics

class ActivityLogger: ObservableObject {
    static let shared = ActivityLogger()
    @Published var logs: [String] = []

    private let workspace = NSWorkspace.shared
    private let idleThreshold: TimeInterval = 300 // 5 minutes

    func startLogging() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidLaunch(_:)),
            name: NSWorkspace.didLaunchApplicationNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(activeAppChanged(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        
        // Start monitoring idle state
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            self.monitorIdleState()
        }
    }

    @objc private func appDidLaunch(_ notification: Notification) {
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            logEvent("App Launched: \(app.localizedName ?? "Unknown")")
        }
    }

    @objc private func activeAppChanged(_ notification: Notification) {
        if let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication {
            logEvent("Active App: \(app.localizedName ?? "Unknown")")
        }
    }

    private func monitorIdleState() {
        let idleTime = ProcessInfo.processInfo.systemUptime - lastInputTime()
        let status = idleTime > idleThreshold ? "Device Inactive" : "Device Active"
        logEvent(status)
        
        func lastInputTime() -> TimeInterval {
            var iterator: io_iterator_t = 0
            var entry: io_registry_entry_t = 0
            var returnCode: kern_return_t
            defer {
                IOObjectRelease(iterator)
            }

            returnCode = IOServiceGetMatchingServices(kIOMainPortDefault, IOServiceMatching("IOHIDSystem"), &iterator)
            if returnCode != KERN_SUCCESS {
                return -1
            }
            entry = IOIteratorNext(iterator)
            if entry == 0 {
                return -1
            }

            var properties: Unmanaged<CFMutableDictionary>?
            returnCode = IORegistryEntryCreateCFProperties(entry, &properties, kCFAllocatorDefault, 0)
            if returnCode != KERN_SUCCESS {
                return -1
            }
            let dict = properties?.takeUnretainedValue() as! [String: Any]
            properties?.release()

            if let time = dict["HIDIdleTime"] as? UInt64 {
                return TimeInterval(Double(time) / 1_000_000_000.0)
            }
            return -1
        }
    }

    private func logEvent(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append("[\(Date())] \(message)")
        }
    }
    
    
}
