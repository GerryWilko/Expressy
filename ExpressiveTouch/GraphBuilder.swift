//
//  GraphBuilder.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GraphBuilder : NSObject, CPTPlotDataSource {
    private var graphView:CPTGraphHostingView!
    private var dataCache:SensorCache
    private var type:SensorDataType
    
    private let title:String
    
    /// Initialises a new graph builder for setting up of a CorePlot graph.
    /// - parameter title: Title of CorePlot graph.
    /// - parameter type: Type of sensor data to be displayed.
    /// - parameter dataCache: Sensor data cache to be used.
    /// - returns: New GraphBuilder instance.
    init(title:String, type:SensorDataType, dataCache:SensorCache) {
        self.title = title
        self.type = type
        self.dataCache = dataCache
    }
    
    /// Function to initiate loading of graph view.
    /// graphView CPTGraphHostingView to be used.
    func initLoad(graphView:CPTGraphHostingView) {
        self.graphView = graphView
        
        configureHost()
        configureGraph()
        configurePlots()
        configureAxes()
    }
    
    /// Internal function to configure host view of graph.
    private func configureHost() {
        graphView.allowPinchScaling = true
        graphView.backgroundColor = UIColor.whiteColor()
    }
    
    /// Internal function to configure graph container properties.
    private func configureGraph() {
        let graph = CPTXYGraph(frame: CGRectZero)
        graphView.hostedGraph = graph
        
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.blackColor()
        titleStyle.fontName = "HelveticaNeue-Medium"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.Top
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingTop = 30.0
        graph.plotAreaFrame.paddingBottom = 30.0
        graph.plotAreaFrame.paddingLeft = 20.0
        
        graph.paddingTop = 40.0
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingRight = 40.0
    }
    
    /// Internal function to configure plot space for each axis.
    private func configurePlots() {
        let graph = graphView.hostedGraph
        let plotSpace = graph.defaultPlotSpace
        
        let dataPlotX = CPTScatterPlot(frame: graphView.frame)
        let dataPlotY = CPTScatterPlot(frame: graphView.frame)
        let dataPlotZ = CPTScatterPlot(frame: graphView.frame)
        
        dataPlotX.dataSource = self
        dataPlotY.dataSource = self
        dataPlotZ.dataSource = self
        
        dataPlotX.identifier = SensorDataAxis.X.rawValue
        dataPlotY.identifier = SensorDataAxis.Y.rawValue
        dataPlotZ.identifier = SensorDataAxis.Z.rawValue
        
        graph.addPlot(dataPlotX, toPlotSpace: plotSpace)
        graph.addPlot(dataPlotY, toPlotSpace: plotSpace)
        graph.addPlot(dataPlotZ, toPlotSpace: plotSpace)
        
        let dataXColor = CPTColor.redColor()
        let dataYColor = CPTColor.greenColor()
        let dataZColor = CPTColor.blueColor()
        
        let dataXLineStyle = dataPlotX.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataXLineStyle.lineWidth = 2.5
        dataXLineStyle.lineColor = dataXColor
        dataPlotX.dataLineStyle = dataXLineStyle
        
        let dataYLineStyle = dataPlotY.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataYLineStyle.lineWidth = 2.5
        dataYLineStyle.lineColor = dataYColor
        dataPlotY.dataLineStyle = dataYLineStyle
        
        let dataZLineStyle = dataPlotZ.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataZLineStyle.lineWidth = 2.5
        dataZLineStyle.lineColor = dataZColor
        dataPlotZ.dataLineStyle = dataZLineStyle
    }
    
    /// Internal function to configure x and y axes.
    private func configureAxes() {
        let axisTitleStyle = CPTMutableTextStyle()
        axisTitleStyle.color =  CPTColor.blackColor()
        axisTitleStyle.fontName = "HelveticaNeue-Medium"
        axisTitleStyle.fontSize = 12.0
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.blackColor()
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.blackColor()
        axisTextStyle.fontName = "HelveticaNeue-Medium"
        axisTextStyle.fontSize = 11.0
        
        let axisSet = graphView.hostedGraph.axisSet as! CPTXYAxisSet
        
        let x = axisSet.xAxis as CPTAxis
        x.title = "Time"
        x.titleTextStyle = axisTitleStyle
        x.titleOffset = 15.0
        x.axisLineStyle = axisLineStyle
        x.labelingPolicy = CPTAxisLabelingPolicy.None
        x.labelTextStyle = axisTextStyle
        x.tickDirection = CPTSign.Negative
        
        let y = axisSet.yAxis as CPTAxis
        y.title = "Value"
        y.titleTextStyle = axisTitleStyle
        y.titleOffset = -20.0
        y.axisLineStyle = axisLineStyle
        y.labelingPolicy = CPTAxisLabelingPolicy.None;
        y.labelTextStyle = axisTextStyle
        y.labelOffset = 16.0
        y.tickDirection = CPTSign.Positive
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (dataCache.count() <= 100) {
            return UInt(dataCache.count())
        }
        
        return 100
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> AnyObject! {
        switch (Int(fieldEnum)) {
        case CPTScatterPlotField.X.rawValue:
            return idx
        case CPTScatterPlotField.Y.rawValue:
            var index = Int(idx)
            if (dataCache.count() > 100) {
                let shift = dataCache.count() - 100
                
                index = index + shift
            }
            
            var data:Vector3D!
            
            switch type {
            case .Accelerometer:
                data = dataCache[index].acc
                break
            case .Gyroscope:
                data = dataCache[index].gyro
                break
            case .Magnetometer:
                data = dataCache[index].mag
                break
            }
            
            switch plot.identifier as! Int {
            case SensorDataAxis.X.rawValue:
                return data.x
            case SensorDataAxis.Y.rawValue:
                return data.y
            case SensorDataAxis.Z.rawValue:
                return data.z
            default:
                break
            }
        default:
            break
        }
        
        return 0
    }
    
    /// Function to reload map data.
    func refresh() {
        graphView.hostedGraph.reloadData()
        graphView.hostedGraph.defaultPlotSpace.scaleToFitPlots(graphView.hostedGraph.allPlots())
    }
    
    /// Function to pause loading of sensor data.
    func pause() {
        dataCache.clearSubscriptions()
    }
    
    /// Function to resume loading of sensor data.
    func resume() {
        dataCache.subscribe(dataCallback)
    }
    
    /// Internal function to process new sensor data.
    private func dataCallback(data:SensorData) {
        refresh()
    }
}

/// Enum for axes of sensor data.
/// - X: Value for x-axis.
/// - Y: Value for y-axis.
/// - Z: Value for z-axis.
enum SensorDataAxis:Int {
    case X = 1, Y, Z
}

/// Enum for sensor data type.
/// - Accelerometer: Value for accelerometer.
/// - Gyroscope: Value for gyroscope.
/// - Magnetometer: Value for magnetometer.
enum SensorDataType {
    case Accelerometer, Gyroscope, Magnetometer
}