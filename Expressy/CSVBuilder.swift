//
//  CSVBuilder.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 27/03/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class CSVBuilder: NSObject {
    var files:[String:String]
    
    /// Initialises a CSV builder for logging of data and exporting via email.
    /// - parameter fileNames: Array of file names for CSV files.
    /// - parameter headerLines: Array of headerLines for CSV files.
    init(files:[String:String]) {
        self.files = files
    }
    
    /// Function to append new row of data.
    /// - parameter data: CSV formatted data string to append.
    /// - parameter index: Index of CSV file to append data to.
    func appendRow(data:String, file:String) {
        files[file]! += "\n" + data
    }
}