//
//  GraphBuilder.swift
//  Expressy
//
//  Created by Gerard Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation
import CorePlot

class GraphBuilder : NSObject, CPTPlotDataSource {
    fileprivate var graphView:CPTGraphHostingView!
    fileprivate var dataCache:SensorCache
    fileprivate var type:SensorDataType
    
    fileprivate let title:String
    
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
    func initLoad(_ graphView:CPTGraphHostingView) {
        self.graphView = graphView
        
        configureHost()
        configureGraph()
        configurePlots()
        configureAxes()
    }
    
    /// Internal function to configure host view of graph.
    fileprivate func configureHost() {
        graphView.allowPinchScaling = true
        graphView.backgroundColor = UIColor.white
    }
    
    /// Internal function to configure graph container properties.
    fileprivate func configureGraph() {
        let graph = CPTXYGraph(frame: CGRect.zero)
        graphView.hostedGraph = graph
        
        let titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.black()
        titleStyle.fontName = "HelveticaNeue-Medium"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchor.top
        graph.titleDisplacement = CGPoint(x: 0.0, y: 10.0)
        
        graph.plotAreaFrame!.paddingTop = 30.0
        graph.plotAreaFrame!.paddingBottom = 40.0
        graph.plotAreaFrame!.paddingLeft = 20.0
        
        graph.paddingTop = 40.0
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingRight = 40.0
    }
    
    /// Internal function to configure plot space for each axis.
    fileprivate func configurePlots() {
        let graph = graphView.hostedGraph!
        let plotSpace = graph.defaultPlotSpace
        
        let dataPlotX = CPTScatterPlot(frame: graphView.frame)
        let dataPlotY = CPTScatterPlot(frame: graphView.frame)
        let dataPlotZ = CPTScatterPlot(frame: graphView.frame)
        
        dataPlotX.dataSource = self
        dataPlotY.dataSource = self
        dataPlotZ.dataSource = self
        
        dataPlotX.identifier = SensorDataAxis.x.rawValue as (NSCoding & NSCopying & NSObjectProtocol)?
        dataPlotY.identifier = SensorDataAxis.y.rawValue as (NSCoding & NSCopying & NSObjectProtocol)?
        dataPlotZ.identifier = SensorDataAxis.z.rawValue as (NSCoding & NSCopying & NSObjectProtocol)?
        
        graph.add(dataPlotX, to: plotSpace)
        graph.add(dataPlotY, to: plotSpace)
        graph.add(dataPlotZ, to: plotSpace)
        
        let dataXColor = CPTColor.red()
        let dataYColor = CPTColor.green()
        let dataZColor = CPTColor.blue()
        
        let dataXLineStyle = dataPlotX.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        dataXLineStyle.lineWidth = 2.5
        dataXLineStyle.lineColor = dataXColor
        dataPlotX.dataLineStyle = dataXLineStyle
        
        let dataYLineStyle = dataPlotY.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        dataYLineStyle.lineWidth = 2.5
        dataYLineStyle.lineColor = dataYColor
        dataPlotY.dataLineStyle = dataYLineStyle
        
        let dataZLineStyle = dataPlotZ.dataLineStyle!.mutableCopy() as! CPTMutableLineStyle
        dataZLineStyle.lineWidth = 2.5
        dataZLineStyle.lineColor = dataZColor
        dataPlotZ.dataLineStyle = dataZLineStyle
    }
    
    /// Internal function to configure x and y axes.
    fileprivate func configureAxes() {
        let axisTitleStyle = CPTMutableTextStyle()
        axisTitleStyle.color =  CPTColor.black()
        axisTitleStyle.fontName = "HelveticaNeue-Medium"
        axisTitleStyle.fontSize = 12.0
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.black()
        let axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.black()
        axisTextStyle.fontName = "HelveticaNeue-Medium"
        axisTextStyle.fontSize = 11.0
        
        let axisSet = graphView.hostedGraph!.axisSet as! CPTXYAxisSet
        
        let x = axisSet.xAxis! as CPTAxis
        x.title = "Time"
        x.titleTextStyle = axisTitleStyle
        x.titleOffset = 15.0
        x.axisLineStyle = axisLineStyle
        x.labelingPolicy = CPTAxisLabelingPolicy.none
        x.labelTextStyle = axisTextStyle
        x.tickDirection = CPTSign.negative
        
        let y = axisSet.yAxis! as CPTAxis
        y.title = "Value"
        y.titleTextStyle = axisTitleStyle
        y.titleOffset = -20.0
        y.axisLineStyle = axisLineStyle
        y.labelingPolicy = CPTAxisLabelingPolicy.none;
        y.labelTextStyle = axisTextStyle
        y.labelOffset = 16.0
        y.tickDirection = CPTSign.positive
    }
    
    func numberOfRecords(for plot: CPTPlot) -> UInt {
        if (dataCache.count() <= 100) {
            return UInt(dataCache.count())
        }
        
        return 100
    }
    
    func number(for plot: CPTPlot, field fieldEnum: UInt, record idx: UInt) -> Any? {
        switch (Int(fieldEnum)) {
        case CPTScatterPlotField.X.rawValue:
            return idx as AnyObject?
        case CPTScatterPlotField.Y.rawValue:
            var index = Int(idx)
            if (dataCache.count() > 100) {
                let shift = dataCache.count() - 100
                
                index = index + shift
            }
            
            var data:Vector3D!
            
            switch type {
            case .accelerometer:
                data = dataCache[index].acc
                break
            case .gyroscope:
                data = dataCache[index].gyro
                break
            case .magnetometer:
                data = dataCache[index].mag
                break
            }
            
            switch plot.identifier as! Int {
            case SensorDataAxis.x.rawValue:
                return data.x as AnyObject?
            case SensorDataAxis.y.rawValue:
                return data.y as AnyObject?
            case SensorDataAxis.z.rawValue:
                return data.z as AnyObject?
            default:
                break
            }
        default:
            break
        }
        
        return 0 as AnyObject?
    }
    
    /// Function to reload map data.
    func refresh() {
        graphView.hostedGraph!.reloadData()
        graphView.hostedGraph!.defaultPlotSpace!.scale(toFit: graphView.hostedGraph!.allPlots())
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
    fileprivate func dataCallback(_ data:SensorData) {
        refresh()
    }
}

/// Enum for axes of sensor data.
/// - X: Value for x-axis.
/// - Y: Value for y-axis.
/// - Z: Value for z-axis.
enum SensorDataAxis:Int {
    case x = 1, y, z
}

/// Enum for sensor data type.
/// - Accelerometer: Value for accelerometer.
/// - Gyroscope: Value for gyroscope.
/// - Magnetometer: Value for magnetometer.
enum SensorDataType {
    case accelerometer, gyroscope, magnetometer
}
