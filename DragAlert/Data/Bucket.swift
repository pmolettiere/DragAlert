//
//  Bucket.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 1/16/24.
//

import Foundation
import SwiftData

struct Bucket : Hashable, Codable, Equatable {
    
    static let granularity = 5/0.00001
    
    static func == (lhs: Bucket, rhs: Bucket) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Bucket, rhs: Bucket) -> Bool {
        if lhs.latitudeBucket == rhs.latitudeBucket { return lhs.longitudeBucket < rhs.longitudeBucket }
        return lhs.latitudeBucket < rhs.latitudeBucket
    }
      
    let latitudeBucket: Double
    let longitudeBucket: Double
    let centerLatitude: Double
    let centerLongitude: Double
        
    var id : (Double, Double, Double, Double) {
        get { (latitudeBucket, longitudeBucket, centerLatitude, centerLongitude) }
    }
    
    func center(with altitude: Double) -> Location {
        Location(timestamp: Date.distantPast, latitude: centerLatitude, longitude: centerLongitude, hAccuracy: 3.8, altitude: altitude, vAccuracy: 0, speed: 0, sAccuracy: 0, course: 0, cAccuracy: 0)
    }
}

class BucketCache {
    static let instance = BucketCache()
    
    var buckets: Dictionary<Location, Bucket> = Dictionary<Location, Bucket>()  // center, bucket
    
    func get(of: Location, from: Location) -> Bucket {
        let (center, latitudeBucket, longitudeBucket) = center(of: of, from: from)
        if buckets[center] == nil {
            print("Creating bucket \(latitudeBucket), \(longitudeBucket)")
            buckets[center] = Bucket(latitudeBucket: latitudeBucket, longitudeBucket: longitudeBucket, centerLatitude: center.latitude, centerLongitude: center.longitude)
        }
        return buckets[center]!
    }
    
    /// Reduces lat/long locations into a set of Buckets aligned along specific 0.00005 degree boundaries, which
    /// corresponds to roughly square areas 5.5m on a side. Close to the poles, these squares become slightly more
    /// trapezoidal, and the horizontal distance becomes smaller.
    ///
    /// These bucket indices are calculated relative to the anchor location latitude and longitude.
    ///
    func center(of: Location, from: Location) -> (center: Location, latitudeBucket: Double, longitudeBucket: Double) {
        //  40075 km in circumference, over 360º is 111.319km per degree. Each 0.00001º is about 1.113 m
        let latitudeBucket = ((from.latitude - of.latitude) * Bucket.granularity ).rounded(.towardZero)
        let longitudeBucket = ((from.longitude - of.longitude) * Bucket.granularity ).rounded(.towardZero)
        
        let lat = from.latitude - (latitudeBucket / Bucket.granularity)
        let long = from.longitude - (longitudeBucket / Bucket.granularity)
        return (Location(timestamp: Date.distantPast, latitude: lat, longitude: long, hAccuracy: 5, altitude: -1, vAccuracy: -1, speed: 0, sAccuracy: 0, course: 0, cAccuracy: 0) , latitudeBucket, longitudeBucket)
    }
  
}
