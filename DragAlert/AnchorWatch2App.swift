//
//  AnchorWatch2App.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/6/23.
//

import SwiftUI
import SwiftData
import MapKit

@main
struct AnchorWatch2App: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Vessel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("DragAlert.sharedModelContainer initialized.")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
            
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(ViewModel(sharedModelContainer))
    }
}
