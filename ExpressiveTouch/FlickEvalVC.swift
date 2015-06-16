//
//  FlickEvalVC.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 11/04/2015.
//  Copyright (c) 2015 Newcastle University. All rights reserved.
//

import Foundation

class FlickEvalVC: UIViewController {
    private var runStack:[Flick]!
    private var current:Flick!
    private var startTime:NSTimeInterval!
    
    private let detector:InteractionDetector
    private let csvBuilder:CSVBuilder
    private let participant:UInt32
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var nextBtn: UIBarButtonItem!
    
    required init(coder aDecoder: NSCoder) {
        detector = InteractionDetector(dataCache: SensorProcessor.dataCache)
        detector.startDetection()
        participant = EvalUtils.generateParticipantID()
        csvBuilder = CSVBuilder(fileNames: ["flick-\(participant).csv", "flickData-\(participant).csv"], headerLines: ["Participant ID,Time,Requested,Flick Force", SensorData.headerLine()])
        super.init(coder: aDecoder)
        runStack = buildRunStack()
    }
    
    override func viewDidLoad() {
        self.performSegueWithIdentifier("flickTestInstructions", sender: self)
        detector.subscribe(EventType.Flicked, callback: flickedCallback)
        startTime = NSDate.timeIntervalSinceReferenceDate()
        navBar.title = "\(navBar.title!) \(participant)"
    }
    
    override func viewDidDisappear(animated: Bool) {
        detector.stopDetection()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detector.touchDown(NSDate.timeIntervalSinceReferenceDate())
        setFlickView()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        detector.touchUp(NSDate.timeIntervalSinceReferenceDate())
        setWaitView()
    }
    
    private func buildRunStack() -> [Flick] {
        var runStack = [Flick]()
        var flick = 5, noFlick = 5
        
        while (flick != 0 || noFlick != 0) {
            let num = Int(arc4random_uniform(2))
            
            if (num == 0 && flick != 0) {
                runStack.append(Flick.Flick)
                flick--
            } else if (num == 1 && noFlick != 0) {
                runStack.append(Flick.NoFlick)
                noFlick--
            }
        }
        
        return runStack
    }
    
    private func flickedCallback(data:Float!) {
        let time = NSDate.timeIntervalSinceReferenceDate()
        let currentString = current == Flick.Flick ? "Flick" : "No Flick"
        csvBuilder.appendRow("\(participant),\(time),\(currentString),\(data)", index: 0)
        setNextView()
    }
    
    private func setWaitView() {
        instructionLbl.text = "Please wait..."
        instructionLbl.textColor = UIColor.blackColor()
        self.view.userInteractionEnabled = false
    }
    
    private func setNextView() {
        instructionLbl.text = "Press next to advance to the next stage."
        instructionLbl.textColor = UIColor.blackColor()
    }
    
    private func setFlickView() {
        current = runStack[0]
        runStack.removeAtIndex(0)
        
        switch (current!) {
        case .Flick:
            instructionLbl.text = "Flick off the screen."
            instructionLbl.textColor = UIColor.greenColor()
            break
        case .NoFlick:
            instructionLbl.text = "Lift off the screen, without flicking."
            instructionLbl.textColor = UIColor.redColor()
            break
        }
    }
    
    @IBAction func next(sender: AnyObject) {
        if runStack.isEmpty {
            nextBtn.enabled = false
            instructionLbl.text = "Evaluation complete. Thank you."
            instructionLbl.textColor = UIColor.blackColor()
            EvalUtils.logDataBetweenTimes(startTime, endTime: NSDate.timeIntervalSinceReferenceDate(), csv: csvBuilder)
            csvBuilder.emailCSV(self, subject: "Flick Evaluation: \(participant)")
        } else {
            instructionLbl.text = "Press and hold."
            instructionLbl.textColor = UIColor.blackColor()
            self.view.userInteractionEnabled = true
        }
        
        progressBar.setProgress(Float(Float(10 - runStack.count) / 10.0), animated: true)
    }
}

private enum Flick {
    case Flick, NoFlick
}