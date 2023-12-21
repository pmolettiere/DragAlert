//
//  ToolbarView.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/20/23.
//

import SwiftUI

struct ToolbarView: ToolbarContent {
    
    var vessel: Vessel?
    var editVessel: () -> Void
    var newAnchor: () -> Void
    var resetAnchor: () -> Void
    var cancelAnchor: () -> Void

    @State var isAlarmEnabled: Bool = Alarm.instance.isEnabled

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Menu(
                content: {
                    Toggle(isOn: $isAlarmEnabled) {
                        Text("view.map.alarm.enable")
                    }.onChange(of: isAlarmEnabled) {
                        Alarm.instance.isEnabled = isAlarmEnabled
                    }
                    
                    Button() {
                        Alarm.instance.snooze()
                    } label: {
                        Text("view.map.alarm.snooze")
                    }
                    .disabled(!Alarm.instance.isPlaying)
                    
                    Button() {
                        Alarm.instance.test()
                    } label: {
                        Text("view.map.alarm.test")
                    }
                    .disabled(Alarm.instance.isPlaying)
                },
                label: {
                    Label("view.map.alarm", systemImage: "alarm")
                }
            )
            Button() {
                editVessel()
            } label: {
                Label("view.map.edit.vessel", systemImage: "sailboat")
            }
            Menu(
                content: {
                    Button() {
                        newAnchor()
                    } label: {
                        Text("view.map.new")
                    }
                    .disabled(vessel?.isAnchored ?? true)
                    
                    Button() {
                        resetAnchor()
                    } label: {
                        Text("view.map.reset")
                    }
                    .disabled(vessel?.isAnchored ?? true)
                    
                    Button() {
                        cancelAnchor()
                    } label: {
                        Text("view.map.cancel")
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
