//
//  DistanceEditorModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation

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
