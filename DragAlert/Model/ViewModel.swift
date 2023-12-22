//
//  ViewModel.swift
//  AnchorWatch
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
import SwiftData
import SwiftUI

@MainActor
@Observable class ViewModel {
    var container: ModelContainer
    var locationDelegate: LocationDelegate
    
    var myVessel: Vessel?
    var currentView: AppView = .perm
    
    init(_ container: ModelContainer) {
        self.container = container
        self.locationDelegate = LocationDelegate.instance
    }
    
    func initMyVessel() {
        print("ViewModel.initMyVessel")
        let context = container.mainContext
        var fd = FetchDescriptor<Vessel>()
        fd.fetchLimit = 1
        fd.includePendingChanges = true
        
        do {
            if let myVessel = try context.fetch(fd).first {
                self.myVessel = myVessel
                locationDelegate.isTrackingLocation = true
                self.myVessel?.startTrackingLocation()
                
                if let anchor = myVessel.anchor {
                    anchor.triggerAlarmIfDragging()
                }
            }
        } catch {
            fatalError("Could not retrieve or create own vessel: \(error)")
        }
    }
    
    func create(myVessel: Vessel) {
        container.mainContext.insert(myVessel)
        initMyVessel()
        myVessel.startTrackingLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationDelegate.requestWhenInUseAuthorization()
    }
    
    func requestAlwaysAuthorization() {
        locationDelegate.requestAlwaysAuthorization()
    }
    
    func requestAuthStatus() {
        locationDelegate.requestAuthStatus()
    }
    
    func setAppView(_ newView: AppView) {
        print( "ViewModel.setAppView changing view from \(currentView) to \(newView)")
        currentView = newView
    }
}

enum AppView {
    case perm, setup, map, anchor
}
