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
    var lastAnchor: Anchor = Anchor.new()
    
    init(_ container: ModelContainer) {
        self.container = container
        self.locationDelegate = LocationDelegate()
        initMyVessel()
    }
    
    func initMyVessel() {
        let context = container.mainContext
        var fd = FetchDescriptor<Vessel>()
        fd.fetchLimit = 1
        fd.includePendingChanges = true
        
        do {
            if let myVessel = try context.fetch(fd).first {
                self.myVessel = myVessel
                self.myVessel?.startTrackingLocation()
                lastAnchor = initLastAnchor()
            }
        } catch {
            fatalError("Could not retrieve or create own vessel: \(error)")
        }
    }

    func getMyVessel() -> Vessel {
        if( myVessel == nil ) {
            print("Null myVessel in ViewModel.getMyVessel!!!")
            initMyVessel()
        }
        return myVessel!
    }
    
    func initLastAnchor() -> Anchor {
        let v = getMyVessel()
        if var ancs = v.anchors {
            if( ancs.count == 0 ) {
                ancs.append(lastAnchor)
            }
        } else {
            print("No anchors array on Vessel!")
        }
        return lastAnchor
    }
}
