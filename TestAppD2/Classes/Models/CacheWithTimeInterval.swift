//
//  CacheWithTimeInterval.swift
//  TestAppD1
//
//  Created by  on 24/01/2019.
//  Copyright © 2019 . All rights reserved.
//

import UIKit

class CacheWithTimeInterval: NSObject {
    
    class func questionsForKey(_ key: String) -> [Item]? {
        if let data = objectForKey(key),
           let items = try? JSONDecoder().decode(Question.self, from: data).items {
            return items
        }
        return nil
    }

    class func objectForKey(_ key: String) -> Data? {
        let arrayOfCachedData: [Data] = UserDefaults.standard.array(forKey: "cache") as? [Data] ?? []
        var mutableArrayOfCachedData = arrayOfCachedData
        var deletedCount = 0
        for (index, data) in arrayOfCachedData.enumerated() {
            if let storedData = try? PropertyListDecoder().decode(StoredData.self, from: data) {
                if abs(storedData.date.timeIntervalSinceNow) < 5*60 {
                    if storedData.key == key {
                        return storedData.data
                    }
                } else {
                    mutableArrayOfCachedData.remove(at: index - deletedCount)
                    deletedCount += 1
                    UserDefaults.standard.set(mutableArrayOfCachedData, forKey: "cache")
                }
            }
        }
        return nil
    }
    
    class func set(data: Data?, for key: String) {
        var arrayOfCachedData: [Data]  = UserDefaults.standard.array(forKey: "cache") as? [Data] ?? []
        if data != nil {
            if CacheWithTimeInterval.objectForKey(key) == nil {
                let storedData = StoredData(key: key, date: Date(), data: data!)
                if let data = try? PropertyListEncoder().encode(storedData) {
                    arrayOfCachedData.append(data)
                }
            }
        }
        UserDefaults.standard.set(arrayOfCachedData, forKey: "cache")
    }
    
}
