//
//  AuthStatusListener.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import MapKit


@Observable
class AuthStatusListener {
    var authStatus: CLAuthorizationStatus = .notDetermined
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(authStatusDidChange), name: LocationNotifications.authStatus.asNotificationName(), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: LocationNotifications.authStatus.asNotificationName(), object: nil)
    }
    
    @objc func authStatusDidChange(notification: Notification) {
        let lasn: LocationAuthStatusNotification = notification.object as! LocationAuthStatusNotification
        authStatus = lasn.authStatus
    }
    
    func allowsWhileUsing() -> Bool {
        authStatus == CLAuthorizationStatus.authorizedWhenInUse || authStatus == CLAuthorizationStatus.authorizedAlways
    }
    
    func allowAlways() -> Bool {
        authStatus == CLAuthorizationStatus.authorizedAlways
    }
}
