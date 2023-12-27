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
