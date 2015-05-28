//
//  EvalUtils.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 02/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class EvalUtils {
    /// Function to log a range of data between two time intervals.
    /// :param: startTime Time of start of range.
    /// :param: endTime Time of end of range.
    /// :param: csv CSV builder to append data to.
    class func logDataBetweenTimes(startTime:NSTimeInterval, endTime:NSTimeInterval, csv:CSVBuilder) {
        let data = SensorProcessor.getProcessor().dataCache.getRangeForTime(startTime, end: endTime)
        
        for d in data {
            csv.appendRow(d.print(), index: 1)
        }
    }
    
    /// Function to retrive random particiapant ID.
    /// :returns: Random particiapnt ID.
    class func generateParticipantID() -> UInt32 {
        return arc4random_uniform(10000)
    }
}