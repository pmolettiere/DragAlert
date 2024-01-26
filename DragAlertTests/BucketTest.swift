//
//  BucketTest.swift
//  Drag Alert Tests
//
//  Created by Peter Molettiere on 1/2/24.
//

import XCTest
@testable import Drag_Alert

final class BucketTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let l = Location(timestamp: Date.distantPast, latitude: 0.0, longitude: 0.0, hAccuracy: 0.0, altitude: 0.0, vAccuracy: 0.0, speed: 0.0, sAccuracy: 0.0, course: 0.0, cAccuracy: 0.0)
        let a = Anchor(location: l, rodeInUseMeters: 0.0)
     
        for lat in -5...5 {
            for long in -5...5 {
                for dec in 10...90 {
                    let latitude: Double = Double(lat) + (Double(dec)/1000.0)
                    let longitude: Double = Double(long) + (Double(dec)/1000.0)
                    let loc = Location(timestamp: Date.distantPast, latitude: latitude, longitude: longitude, hAccuracy: 0, altitude: 0, vAccuracy: 0, speed: 0, sAccuracy: 0, course: 0, cAccuracy: 0)
                    let (latitudeBucket, longitudeBucket) = a.getBucket(of: loc)
                    print("\(latitude), \(longitude) bucket \(latitudeBucket), \(longitudeBucket)")
                }
            }
        }
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
