//
//  LocationNotifications.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/12/23.
//

import Foundation
import MapKit

enum LocationNotifications: String {
    case authStatus = "sv.salacia.AnchorWatch.notifications.locationManagerDidChangeAuthorization"
    case failure = "sv.salacia.AnchorWatch.notifications.didFailWithError"
    case updateLocation = "sv.salacia.AnchorWatch.notifications.didUpdateLocations"
    case pauseLocations = "sv.salacia.AnchorWatch.notifications.didPauseLocationUpdates"
    case resumeLocations = "sv.salacia.AnchorWatch.notifications.didResumeLocationUpdates"
    case updateHeading = "sv.salacia.AnchorWatch.notifications.updateHeading"
    
    func asNotificationName() -> Notification.Name {
        Notification.Name(self.rawValue)
    }
}

struct LocationAuthStatusNotification {
    let authStatus: CLAuthorizationStatus
}

struct LocationFailure {
    let error: Error
}

struct LocationUpdate {
    let locations: [CLLocation]
}

struct HeadingUpdate {
    let heading: CLHeading
}
