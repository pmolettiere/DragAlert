//
//  DistanceEditorModel.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 12/26/23.
//

import Foundation
import SwiftUI

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

    var model: MeasurementModel
    var max: Measurement<UnitLength>?
    var specifiedStep: Double?

    var value: Double {
        get { model.displayValue }
        set { model.displayValue = newValue }
    }
    var unit: UnitLength {
        get { model.displayUnit }
        set { model.displayUnit = newValue }
    }
    var range: ClosedRange<Double> {
        get {
            if let end = max {
                let cvt = end.converted(to: model.displayUnit).value
                if( cvt >= 1) { return 0...cvt }
            }
            let i = (model.displayUnit == UnitLength.feet ? 0 : 1)
            return constants[i].range
        }
    }
    var step: Double {
        get {
            if let stp = specifiedStep {
                if stp < 1 { return 1 }
                return stp
            } else {
                let i = (model.displayUnit == UnitLength.feet ? 0 : 1)
                return constants[i].step
            }
        }
    }
    
    init(_ measurement:Binding<Double>, maxMeters: Double?, step: Double?) {
        model = MeasurementModel(measurement)
        if( maxMeters != nil ) {
            self.max = Measurement(value: maxMeters!, unit: .meters)
        } else {
            self.max = nil
        }
        self.specifiedStep = step
    }
}

@Observable
class MeasurementModel {
    
    var lengthMeters: Binding<Double>
    var measurement: Measurement<UnitLength>
    
    var displayUnit: UnitLength
    var displayValue: Double {
        get{ measurement.converted(to: displayUnit).value }
        set{
            lengthMeters.wrappedValue = Measurement(value: newValue, unit: displayUnit).converted(to: .meters).value
            measurement.value = lengthMeters.wrappedValue
        }
    }
    
    init(_ meters: Binding<Double> ) {
        lengthMeters = meters
        measurement = Measurement(value: meters.wrappedValue, unit: .meters)
        displayUnit = Preferred.value.lengthUnit
        
        NotificationCenter.default.addObserver(self, selector: #selector(setDisplayUnit), name: Preferred.lengthUnitNotificationName, object: nil)
    }
    
    @objc func setDisplayUnit(notification: Notification) {
        displayUnit = notification.object as! UnitLength
    }
}
