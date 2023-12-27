//
//  ViewModel.swift
//  Drag Alert
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
    var gps: LocationObserver = LocationObserver()
    var currentView: AppView = .perm
    
    var selectedUnit: UnitLength = .meters
    
    var setupModel = SetupVesselModel()
    var anchoringModel: AnchoringViewModel?
    
    init(_ container: ModelContainer) {
        self.container = container
        self.locationDelegate = LocationDelegate.instance
        
        gps.locationCallback = locationDidUpdate
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
                gps.isTrackingLocation = true
                
                if let anchor = myVessel.anchor {
                    anchor.triggerAlarmIfDragging()
                }
                
                setupViewModels()
            }
        } catch {
            fatalError("Could not retrieve or create own vessel: \(error)")
        }
    }
    
    func create(myVessel: Vessel) {
        container.mainContext.insert(myVessel)
        initMyVessel()
        gps.isTrackingLocation = true
    }
    
    func setAppView(_ newView: AppView) {
        print( "ViewModel.setAppView changing view from \(currentView) to \(newView)")
        currentView = newView
        switch newView {
        case .new_anchor :
            anchoringModel!.willEdit = .new
        case .edit_anchor :
            anchoringModel!.willEdit = .edit
        default :
            break
        }
    }
    
    func setupViewModels() {
        setupModel.setVessel(myVessel!)
        anchoringModel = AnchoringViewModel(vessel: myVessel!, state: .new)
    }

    func locationDidUpdate() {
        let location = gps.location
        if let vessel = myVessel {
            vessel.location = location
            if( vessel.isAnchored ) {
                vessel.anchor?.update(log: location)
                vessel.anchor?.triggerAlarmIfDragging()
            } else {
                Alarm.instance.stopPlaying()
            }
        }
    }
}

enum AppView {
    case perm
    case setup
    case map
    case new_anchor
    case edit_anchor
}
