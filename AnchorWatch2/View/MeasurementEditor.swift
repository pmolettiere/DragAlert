//
//  MeasurementEditor.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/11/23.
//

import SwiftUI

struct MeasurementEditor : View {

    private let measurementFormatter = MeasurementFormatter()

    @State var selectedUnit = UnitLength.meters
    
    var label: String
    var measurement: Binding<Measurement<UnitLength>>
    var range: ClosedRange<Double>
    var step: Double
    
    init(_ label: String, measurement: Binding<Measurement<UnitLength>>, range: ClosedRange<Double>, step: Double) {
        self.label = label
        self.measurement = measurement
        self.range = range
        self.step = step
        switch measurement.wrappedValue.unit {
        case UnitLength.feet :
            selectedUnit = UnitLength.feet
        default :
            selectedUnit = UnitLength.meters
        }
    }
        
    var body: some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                TextField(label, value: measurement.value, formatter: measurementFormatter)
                    .keyboardType(.decimalPad)
            }
            Slider(value: measurement.value, in: range, step: step)
                .labelsHidden()
            Picker("Unit", selection: $selectedUnit ) {
                Text("Feet").tag(UnitLength.feet)
                Text("Meters").tag(UnitLength.meters)
            }
            .pickerStyle(.menu)
        }
        .onChange(of: selectedUnit) {
            measurement.wrappedValue.convert(to: selectedUnit)
        }
    }
}
