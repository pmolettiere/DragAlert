//
//  AppDelegate.swift
//  AnchorWatch
//
//  Imported from Apple documentation:
//  https://developer.apple.com/documentation/corelocation/supporting_live_updates_in_swiftui_and_mac_catalyst_apps
//

import Foundation
import UIKit


class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        let tracker = VesselTracker.shared
    
        // If location updates were previously active, restart them after the background launch.
        if tracker.isTracking {
            tracker.restart() // not sure if the tracker will still have the trackedVessel
        }

        return true
    }
}
