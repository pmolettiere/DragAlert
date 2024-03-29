//
//  Vessel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/1/23.
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
import CoreLocation
import simd

@Model
final class Vessel {
    var uuid = UUID()
    var name = String()
    var loaMeters: Double = 0
    var totalRodeMeters: Double = 0  // total rode installed on Vessel
    var isAnchored = false
    var location: Location = Location.nowhere
    var anchor: Anchor?

    @Transient
    var maxDistanceFromAnchor: Double {
        get { totalRodeMeters + loaMeters }
    }
    
    init(uuid: UUID = UUID(), name: String = "", loaMeters: Double, rodeMeters: Double, location: Location, isAnchored: Bool = false, anchor: Anchor? = nil) {
        self.uuid = uuid
        self.name = name
        self.loaMeters = loaMeters
        self.totalRodeMeters = rodeMeters
        self.location = location
        self.isAnchored = isAnchored
        self.anchor = anchor
    }
}

//extension Vessel : Equatable, Identifiable, Hashable {
//    var id: UUID { uuid }
//
//    static func == (lhs: Vessel, rhs: Vessel) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//}
