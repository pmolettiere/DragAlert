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

        let isTrackingLocation: Bool = UserDefaults.standard.bool(forKey: "isTrackingLocation")
        if( isTrackingLocation ) {
            let ld = LocationDelegate.instance
            ld.isTrackingLocation = true
        }

        let isTrackingHeading: Bool = UserDefaults.standard.bool(forKey: "isTrackingHeading")
        if( isTrackingHeading ) {
            let ld = LocationDelegate.instance
            ld.isTrackingHeading = true
        }

        return true
    }
}
