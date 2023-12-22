//
//  DistanceEditor.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/11/23.
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

struct DistanceEditor : View {
    
    private let measurementFormatter = MeasurementFormatter()
    
    var label: LocalizedStringKey
    @State var model: DistanceEditorModel
    
    init(_ label: LocalizedStringKey, measurement: MeasurementModel<UnitLength>, max: Measurement<UnitLength>? = nil, step: Double? = nil) {
        self.label = label
        self.model = DistanceEditorModel(measurement, max: max, step: step)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                TextField(label, value: $model.value, formatter: Format.singleton.float0Format)
                    .keyboardType(.decimalPad)
                Picker("view.editor.distance.unit", selection: $model.unit ) {
                    Text("view.editor.distance.feet").tag(UnitLength.feet)
                    Text("view.editor.distance.meters").tag(UnitLength.meters)
                }
                .labelsHidden()
            }
            Slider(value: $model.value, in: model.range, step: model.step)
                .labelsHidden()
            .pickerStyle(.menu)
        }
    }
}

@Observable
class DistanceEditorModel {
    struct MeasurementConstants {
        let unit: UnitLength
        let range: ClosedRange<Double>
        let step: Double
    }
    
    let constants: [MeasurementConstants] = [
        MeasurementConstants(unit: UnitLength.feet, range: 0...330, step: 5),
        MeasurementConstants(unit: UnitLength.meters, range: 0...100, step: 1),
    ]

    var model: MeasurementModel<UnitLength>
    var max: Measurement<UnitLength>?
    var specifiedStep: Double?

    var value: Double {
        get { model.value }
        set { model.value = newValue }
    }
    var unit: UnitLength {
        get { model.unit }
        set { model.unit = newValue }
    }
    var range: ClosedRange<Double> {
        get {
            if let end = max {
                let cvt = end.converted(to: model.unit).value
                if( cvt >= 1) { return 0...cvt }
            }
            let i = (model.unit == UnitLength.feet ? 0 : 1)
            return constants[i].range
        }
    }
    var step: Double {
        get {
            if let stp = specifiedStep {
                if stp < 1 { return 1 }
                return stp
            } else {
                let i = (model.unit == UnitLength.feet ? 0 : 1)
                return constants[i].step
            }
        }
    }
    
    init(_ measurement:MeasurementModel<UnitLength>, max: Measurement<UnitLength>?, step: Double?) {
        model = measurement
        self.max = max
        self.specifiedStep = step
    }
        
    func asMeasurement() -> Measurement<UnitLength> {
        model.measurement
    }
}

@Observable
class MeasurementModel<U: Dimension> {
    var measurement: Measurement<U> {
        get {
            Measurement(value: value, unit: unit)
        }
    }
    var value: Double
    var unit: U {
        willSet(toUnit) {
            if( unit != toUnit ) {
                value = measurement.converted(to: toUnit).value
            }
        }
    }
    
    init(_ measurement: Measurement<U>) {
        self.value = measurement.value
        self.unit = measurement.unit
    }
    
    func asUnit(_ unit: U) -> Measurement<U> {
        measurement.converted(to: unit)
    }
}
