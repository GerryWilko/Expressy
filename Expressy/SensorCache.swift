//
//  SensorCache.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class SensorCache {
    private var data:[SensorData]
    private var dataCallbacks:[(data:SensorData) -> Void]
    
    static var limit:UInt = 100
    
    /// Initialises a new data cache for storage of sensor data.
    /// - returns: New SensorCache instance.
    init() {
        data = [SensorData]()
        dataCallbacks = Array<(data:SensorData) -> Void>()
    }
    
    class func setRecordLimit() {
        SensorCache.limit = 10000
    }
    
    class func resetLimit() {
        SensorCache.limit = 100
    }
    
    /// Function to add new sensor data to cache.
    /// - parameter newData: New sensor data to be added.
    func add(newData: SensorData) {
        if (UInt(data.count) >= SensorCache.limit) {
            data.removeAtIndex(0)
        }
        data.append(newData)
        fireDataCallbacks(newData)
    }
    
    /// Function to retrieve specific sensor data by index.
    /// - parameter index: Index of data to be retrieved.
    /// - returns: Sensor data.
    subscript(index: Int) -> SensorData {
        get {
            return data[index]
        }
    }
    
    /// Function to return range of data from cache.
    /// - parameter startIndex: Index of start of range.
    /// - parameter endIndex: Index of end of range.
    /// - returns: Array of sensor data.
    subscript(startIndex:Int, endIndex:Int) -> Array<SensorData> {
        return Array(data[startIndex..<endIndex])
    }
    
    /// Function to subscribe to callbacks when new data is available.
    /// - parameter callback: Function to call when new sensor data arrives.
    func subscribe(callback:(data:SensorData) -> Void) {
        dataCallbacks.append(callback)
    }
    
    /// Function to clear current subscriptions to new data.
    func clearSubscriptions() {
        dataCallbacks.removeAll(keepCapacity: false)
    }
    
    /// Internal function to fire data callbacks.
    /// - parameter data: New sensor data to pass to callback.
    private func fireDataCallbacks(data:SensorData) {
        for cb in dataCallbacks {
            cb(data: data)
        }
    }
    
    /// Function to retrive the number of items in the data cache.
    /// - returns: Number of sensor data objects so.
    func count() -> Int {
        return data.count
    }
    
    /// Internal function retrieve the index of sensor data closest to a specified time.
    /// - parameter time: Time to search for.
    /// - returns: Index of located sensor data.
    private func getIndexForTime(time:NSTimeInterval) -> Int {
        var closest:Int = 0
        for i in 0..<count() {
            if(abs(time - self[closest].time) > abs(self[i].time - time)) {
                closest = i;
            }
        }
        return closest;
    }
    
    /// Function to retrieve the sensor data closest to a specified time.
    /// - parameter time: Time to search for.
    /// - returns: Located sensor data.
    func getForTime(time:NSTimeInterval) -> SensorData {
        return self[getIndexForTime(time)]
    }
    
    /// Function to retrieve a range of sensor data between two specified time intervals.
    /// - parameter start: Time of start of range.
    /// - parameter end: Time of end of range.
    /// - returns: Array of sensor data recieved between the two intervals.
    func getRangeForTime(start:NSTimeInterval, end:NSTimeInterval) -> [SensorData] {
        let startIndex = getIndexForTime(start)
        let endIndex = getIndexForTime(end)
        
        return self[startIndex, endIndex]
    }
}