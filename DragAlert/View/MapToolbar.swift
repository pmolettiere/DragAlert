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
    var cancelAnchor: () -> Void

    @State var isAlarmEnabled: Bool = Alarm.instance.isEnabled
    @State var disableIdle: Bool = false
    
    func disableIdle( disable: Bool )  {
        Task { @MainActor in
            UIApplication.shared.isIdleTimerDisabled = disable
        }
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Menu(
                content: {
                    Toggle(isOn: $isAlarmEnabled) {
                        Text("view.toolbar.alarm.enable")
                    }.onChange(of: isAlarmEnabled) {
                        Alarm.instance.isEnabled = isAlarmEnabled
                    }
                    
                    Toggle(isOn: $disableIdle) {
                        Text("view.toolbar.alarm.disable.idle")
                    }.onChange(of: disableIdle) {
                        disableIdle(disable: disableIdle)
                    }
                    
                    Button() {
                        Alarm.instance.snooze()
                    } label: {
                        Text("view.toolbar.alarm.snooze")
                    }
                    .disabled(!Alarm.instance.isPlaying)
                    
                    Button() {
                        Alarm.instance.test()
                    } label: {
                        Text("view.toolbar.alarm.test")
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
                        newAnchor()
                    } label: {
                        Text("view.toolbar.new")
                    }
                    .disabled(vessel?.isAnchored ?? true)
                    
                    Button() {
                        resetAnchor()
                    } label: {
                        Text("view.toolbar.reset")
                    }
                    .disabled(vessel?.isAnchored ?? true)
                    
                    Button() {
                        cancelAnchor()
                    } label: {
                        Text("view.toolbar.cancel")
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
