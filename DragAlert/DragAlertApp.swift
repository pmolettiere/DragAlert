//
//  DragAlertApp.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/6/23.
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

import SwiftUI
import SwiftData
import CoreData
import MapKit

@main
struct DragAlertApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Vessel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
//#if DEBUG
//            // Use an autorelease pool to make sure Swift deallocates the persistent
//            // container before setting up the SwiftData stack.
//            try autoreleasepool {
//                let desc = NSPersistentStoreDescription(url: modelConfiguration.url)
//                let opts = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.sv.salacia.AnchorWatch")
//                desc.cloudKitContainerOptions = opts
//                // Load the store synchronously so it completes before initializing the
//                // CloudKit schema.
//                desc.shouldAddStoreAsynchronously = false
//                if let mom = NSManagedObjectModel.makeManagedObjectModel(for: [Vessel.self]) {
//                    let container = NSPersistentCloudKitContainer(name: "DragAlert", managedObjectModel: mom)
//                    container.persistentStoreDescriptions = [desc]
//                    container.loadPersistentStores {_, err in
//                        if let err {
//                            fatalError(err.localizedDescription)
//                        }
//                    }
//                    // Initialize the CloudKit schema after the store finishes loading.
//                    try container.initializeCloudKitSchema()
//                    // Remove and unload the store from the persistent container.
//                    if let store = container.persistentStoreCoordinator.persistentStores.first {
//                        try container.persistentStoreCoordinator.remove(store)
//                    }
//                }
//            }
//#endif
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            container.mainContext.autosaveEnabled = true
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
