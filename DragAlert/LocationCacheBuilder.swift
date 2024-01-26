//
//  LocationCacheBuilder.swift
//  Drag Alert
//
//  Created by Peter Molettiere on 1/26/24.
//

import Foundation

actor LocationCacheBuilder {

    let bucketIdx: Dictionary<Bucket, Int>
    
    init(bucketIdx: Dictionary<Bucket, Int>) {
        self.bucketIdx = bucketIdx
    }

    func rebuildLocationCache() -> [Location] {
        var newCache: [Location] = []
        bucketIdx.keys.sorted(by: {$0 < $1}).forEach { bucket in
            newCache.append(bucket.center(with: Double(bucketIdx[bucket]!)))
        }
        return newCache
    }
    
}
