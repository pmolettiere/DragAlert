//
//  Tips.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/29/23.
//

import Foundation
import TipKit

struct TipInstance {
    static let disableIdleTip = DisableIdleTip()
    static let lowVolumeAlertTip = LowVolumeAlertTip()
    static let adjustTip = AdjustTip()
    static let resetTip = ResetTip()
    static let setTip = SetTip()
    static let legendTip = MapLegendTip()
}

struct TipEvent {
    static let didCancelAnchor = Tips.Event<AppAction>(id: "didCancelAnchor")
    static let didAdjustAnchor = Tips.Event<AppAction>(id: "didAdjustAnchor")
    static let didResetAnchor = Tips.Event<AppAction>(id: "didResetAnchor")
    static let didSetAnchor = Tips.Event<AppAction>(id: "didSetAnchor")

    struct AppAction : Codable, Sendable {
        var name : String
    }
}

struct DisableIdleTip : Tip {
    var title : Text { Text("tip.maptoolbar.disable.idle.title") }
    var message : Text? { Text("tip.maptoolbar.disable.idle.message") }
    var image : Image? { Image(systemName: "sun.max")}
    
    var rules: [Rule] {
        #Rule(TipEvent.didSetAnchor) {
            $0.donations.count >= 3
        }
    }
}

struct LowVolumeAlertTip : Tip {
    var title : Text {
        Text("tip.map.low.volume.title")
            .foregroundStyle(Color.red)
    }
    var message : Text? { Text("tip.map.low.volume.message") }
    var image : Image? { Image(systemName: "alarm.waves.left.and.right") }
}

struct AdjustTip : Tip {
    var title : Text { Text("tip.map.adjust.title") }
    var message : Text? { Text("tip.map.adjust.message") }
    var image : Image? { Image(systemName: "wrench.adjustable")}

    var rules: [Rule] {
        #Rule(TipEvent.didSetAnchor) {
            $0.donations.count >= 1
        }
    }
}

struct ResetTip : Tip {
    var title : Text { Text("tip.map.reset.title") }
    var message : Text? { Text("tip.map.reset.message") }
    var image : Image? { Image(systemName: "return")}
    
    var rules: [Rule] {
        #Rule(TipEvent.didCancelAnchor) {
            $0.donations.count >= 1
        }
    }
}

struct SetTip : Tip {
    var title : Text { Text("tip.map.set.title") }
    var message : Text? { Text("tip.map.set.message") }
    var image : Image? { Image(systemName: "location")}
    
//    var rules: [Rule] {
//        #Rule(TipEvent.didCancelAnchor) {
//            $0.donations.count >= 1
//        }
//    }
}

struct MapLegendTip : Tip {
    var title : Text { Text("tip.map.legend.title") }
    var message : Text? { Text("tip.map.legend.message") }
    var image : Image? { Image(systemName: "globe")}
    
    var rules: [Rule] {
        #Rule(TipEvent.didAdjustAnchor) {
            $0.donations.count >= 1
        }
    }
}
