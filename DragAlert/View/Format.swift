//
//  Format.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 11/25/23.
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

import Foundation

struct Format {
    static let singleton = Format()
    
    var intFormat: NumberFormatter
    var float2Format: NumberFormatter
    var float0Format: NumberFormatter

    init() {
        self.intFormat = NumberFormatter()
        self.float2Format = NumberFormatter()
        self.float0Format = NumberFormatter()
        intFormat.numberStyle = NumberFormatter.Style.none
        float2Format.numberStyle = NumberFormatter.Style.decimal
        float2Format.minimumFractionDigits = 1
        float2Format.maximumFractionDigits = 2
        float0Format.numberStyle = NumberFormatter.Style.decimal
        float0Format.minimumFractionDigits = 0
        float0Format.maximumFractionDigits = 0
    }
}
