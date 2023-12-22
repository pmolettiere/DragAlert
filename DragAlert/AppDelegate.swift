//
//  AppDelegate.swift
//  Drag Alert
//
//  Imported from Apple documentation:
//  https://developer.apple.com/documentation/corelocation/supporting_live_updates_in_swiftui_and_mac_catalyst_apps
//
//    Copyright (C) <2023>  <Peter Molettiere>
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
                     launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        print("AppDelegate.application didFinishLaunchingWithOptions")
        
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

//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        let sceneConfig: UISceneConfiguration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
//        sceneConfig.delegateClass = SceneDelegate.self
//        return sceneConfig
//    }
    
}
