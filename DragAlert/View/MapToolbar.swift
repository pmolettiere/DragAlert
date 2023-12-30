//
//  MapToolbar.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/20/23.
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

struct MapToolbar: ToolbarContent {
    
    var vessel: Vessel?
    var editVessel: () -> Void
    var newAnchor: () -> Void
    var resetAnchor: () -> Void
    var adjustAnchor: () -> Void
    var cancelAnchor: () -> Void

    @State var isAlarmEnabled: Bool = Alarm.instance.isEnabled
    @State var disableIdle: Bool = false
        
    func disableIdle( disable: Bool )  {
        Task { @MainActor in
            UIApplication.shared.isIdleTimerDisabled = disable
        }
    }
    
    func awaitTask( _ task: @escaping @Sendable () async -> Void ) {
        Task {
            await task()
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Menu(
                content: {
                    Toggle(isOn: $isAlarmEnabled) {
                        Label("view.toolbar.alarm.enable", systemImage: "alarm.fill")
                    }.onChange(of: isAlarmEnabled) {
                        Alarm.instance.isEnabled = isAlarmEnabled
                    }
                    
                    Toggle(isOn: $disableIdle) {
                        Label("view.toolbar.alarm.disable.idle", systemImage: "sun.max")
                    }.onChange(of: disableIdle) {
                        TipInstance.disableIdleTip.invalidate(reason: .actionPerformed)
                        disableIdle(disable: disableIdle)
                    }

                    Button() {
                        Alarm.instance.snooze()
                    } label: {
                        Label("view.toolbar.alarm.snooze", systemImage: "powersleep")
                    }
                    .disabled(!Alarm.instance.isPlaying)
                    
                    Button() {
                        Alarm.instance.test()
                    } label: {
                        Label("view.toolbar.alarm.test", systemImage: "alarm.waves.left.and.right")
                    }
                    .disabled(Alarm.instance.isPlaying)
                },
                label: {
                    Label("view.toolbar.alarm", systemImage: "alarm")
                }
            )

            Button() {
                editVessel()
            } label: {
                Label("view.toolbar.edit.vessel", systemImage: "sailboat")
            }
            Menu(
                content: {
                    Button() {
                        awaitTask( { await TipEvent.didSetAnchor.donate(.init(name: "didSetAnchor")) } )
                        newAnchor()
                    } label: {
                        Label("view.toolbar.new", systemImage: "location")
                    }
                    .disabled(vessel?.isAnchored ?? true)
                    
                    Button() {
                        awaitTask( { await TipEvent.didResetAnchor.donate(.init(name: "didResetAnchor")) } )
                        awaitTask( { await TipEvent.didSetAnchor.donate(.init(name: "didSetAnchor")) } )
                        resetAnchor()
                    } label: {
                        Label("view.toolbar.reset", systemImage:"return")
                    }
                    .disabled(( (vessel?.isAnchored ?? false) || (vessel?.anchor ?? nil) == nil) )
                    
                    Button() {
                        awaitTask( { await TipEvent.didAdjustAnchor.donate(.init(name: "didAdjustAnchor")) } )
                        awaitTask( { await TipEvent.didSetAnchor.donate(.init(name: "didSetAnchor")) } )
                        adjustAnchor()
                    } label: {
                        Label("view.toolbar.adjust", systemImage: "wrench.adjustable")
                    }
                    .disabled(!(vessel?.isAnchored ?? true))
                    
                    Button() {
                        awaitTask( { await TipEvent.didCancelAnchor.donate(.init(name: "didCancelAnchor")) } )
                        cancelAnchor()
                    } label: {
                        Label("view.toolbar.cancel", systemImage: "location.slash")
                    }
                    .disabled(!(vessel?.isAnchored ?? false))
                },
                label: {
                    AnchorView(color: .blue, size: CGFloat(28))
//                            Text("view.map.anchor")
                }
            )
        }
    }
}
