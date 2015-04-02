//
//  EvalUtils.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 02/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class EvalUtils {
    class func logDataBetweenTimes(startTime:NSTimeInterval, endTime:NSTimeInterval, csv:CSVBuilder) {
        let data = WaxProcessor.getProcessor().dataCache.getRangeForTime(startTime, end: endTime)
        
        for d in data {
            csv.appendRow(d.print(), index: 1)
        }
    }
}