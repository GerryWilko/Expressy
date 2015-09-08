//
//  EvaluationVC.swift
//  ExpressiveTouch
//
//  Created by Gerard Wilkinson on 07/09/2015.
//  Copyright © 2015 Newcastle University. All rights reserved.
//

import Foundation

class EvaluationVC: UIViewController {
    let detector:InteractionDetector
    var csv:CSVBuilder!
    
    var participant:UInt32!
    var evalVC:EvaluationMenuVC!
    
    private var startTime:NSTimeInterval!
    private var evalFileName:String!
    private var sensorFileName:String!
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.dataCache)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = navigationItem.title! + " \(participant)"
        startTime = NSDate.timeIntervalSinceReferenceDate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        detector.startDetection()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        detector.touchDown()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        detector.touchUp()
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        detector.touchCancelled()
    }
    
    func setupCSV(filePrefix:String, headerLine:String) {
        evalFileName = "\(filePrefix)-\(participant).csv"
        sensorFileName = "\(filePrefix)-sensordata-\(participant).csv"
        csv = CSVBuilder(files: [evalFileName : headerLine, sensorFileName : SensorData.headerLine()])
    }
    
    func logEvalData(data:String) {
        csv.appendRow(data, file: evalFileName)
    }
    
    func logSensorData() {
        EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csv, file: sensorFileName)
    }
}