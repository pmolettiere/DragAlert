//
//  MeasurementEditor.swift
//  AnchorWatch2
//
//  Created by Peter Molettiere on 12/11/23.
//

import SwiftUI

struct DistanceEditor : View {
    
    private let measurementFormatter = MeasurementFormatter()
    
    var label: LocalizedStringKey
    @State var model: DistanceEditorModel
    
    init(_ label: LocalizedStringKey, measurement: Binding<Measurement<UnitLength>>, max: Measurement<UnitLength>? = nil, step: Double? = nil) {
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

    var binding: Binding<Measurement<UnitLength>>
    var unit: UnitLength {
        willSet(toUnit) {
            value = Measurement(value: value, unit: unit).converted(to: toUnit).value
        }
    }
    var value: Double {
        didSet {
            binding.wrappedValue = asMeasurement()
        }
    }
    var max: Measurement<UnitLength>?
    var specifiedStep: Double?

    var range: ClosedRange<Double>{
        get {
            if let end = max {
                let cvt = end.converted(to: unit).value
                if( cvt >= 1) { return 0...cvt }
            }
            let i = (unit == UnitLength.feet ? 0 : 1)
            return constants[i].range
        }
    }
    var step: Double {
        get {
            if let stp = specifiedStep {
                if stp < 1 { return 1 }
                return stp
            } else {
                let i = (unit == UnitLength.feet ? 0 : 1)
                return constants[i].step
            }
        }
    }
    
    init(_ measurement:Binding<Measurement<UnitLength>>, max: Measurement<UnitLength>?, step: Double?) {
        binding = measurement
        value = measurement.wrappedValue.value
        unit = measurement.wrappedValue.unit
        self.max = max
        self.specifiedStep = step
    }
        
    func asMeasurement() -> Measurement<UnitLength> {
        Measurement(value: value, unit: unit)
    }
}

