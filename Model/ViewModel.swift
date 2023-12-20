//
//  ViewModel.swift
//  AnchorWatch
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
