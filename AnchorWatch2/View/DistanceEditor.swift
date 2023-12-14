//
//  MeasurementEditor.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/11/23.
//

import SwiftUI

struct DistanceEditor : View {
    
    private let measurementFormatter = MeasurementFormatter()
    
    var label: String
    @State var model: DistanceEditorModel
    
    init(_ label: String, measurement: Binding<Measurement<UnitLength>>, max: Measurement<UnitLength>? = nil) {
        self.label = label
        self.model = DistanceEditorModel(measurement, max: max)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(label)
                Spacer()
                TextField(label, value: $model.value, formatter: Format.singleton.float0Format)
                    .keyboardType(.decimalPad)
                Picker("Unit", selection: $model.unit ) {
                    Text("Feet").tag(UnitLength.feet)
                    Text("Meters").tag(UnitLength.meters)
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

    var binding: Binding<Measurement<UnitLength>>
    var unit: UnitLength {
        willSet(toUnit) {
            value = Measurement(value: value, unit: unit).converted(to: toUnit).value
        }
        didSet {
            setRangeStep(unit: unit)
        }
    }
    var value: Double {
        didSet {
            binding.wrappedValue = asMeasurement()
        }
    }
    var range: ClosedRange<Double>
    var step: Double
    var max: Measurement<UnitLength>?
    
    init(_ measurement:Binding<Measurement<UnitLength>>, max: Measurement<UnitLength>?) {
        binding = measurement
        value = measurement.wrappedValue.value
        unit = measurement.wrappedValue.unit
        self.max = max
        range = constants[0].range
        step = constants[1].step
        setRangeStep(unit: unit)
    }
    
    func setRangeStep(unit: UnitLength) {
        switch unit {
        case UnitLength.feet :
            range = constants[0].range
            step = constants[0].step
        default :
            range = constants[1].range
            step = constants[1].step
        }
        if let m = max {
            range = 0...m.converted(to: unit).value
        }
    }
    
    func asMeasurement() -> Measurement<UnitLength> {
        Measurement(value: value, unit: unit)
    }
}

