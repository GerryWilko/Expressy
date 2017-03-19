//
//  EvaluationVC.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 07/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation
import UIKit

class EvaluationVC: UIViewController {
    let detector:EXTInteractionDetector
    var csv:CSVBuilder!
    
    var participant:UInt32!
    var evalVC:EvaluationMenuVC!
    
    fileprivate var startTime:TimeInterval!
    fileprivate var evalFileName:String!
    fileprivate var sensorFileName:String!
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        detector = EXTInteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title! + " \(participant)"
        startTime = Date.timeIntervalSinceReferenceDate
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        detector.startDetection()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        detector.stopDetection()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        detector.touchDown()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        detector.touchUp()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        detector.touchCancelled()
    }
    
    func setupCSV(_ filePrefix:String, headerLine:String) {
        evalFileName = "\(filePrefix)-\(participant).csv"
        sensorFileName = "\(filePrefix)-sensordata-\(participant).csv"
        csv = CSVBuilder(files: [evalFileName : headerLine, sensorFileName : SensorData.headerLine()])
    }
    
    func logEvalData(_ data:String) {
        csv.appendRow(data, file: evalFileName)
    }
    
    func logSensorData() {
        EvalUtils.logDataBetweenTimes(startTime, endTime: Date.timeIntervalSinceReferenceDate, csv: csv, file: sensorFileName)
    }
}
