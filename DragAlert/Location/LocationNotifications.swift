//
//  LocationNotifications.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/12/23.
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
