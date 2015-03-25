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
    private var dataCache:WaxCache!
    private let title:String
    private var type:WaxDataType
    
    init(title:String, type:WaxDataType) {
        self.title = title
        self.type = type
    }
    
    func initLoad(graphView:CPTGraphHostingView, dataCache:WaxCache) {
        self.graphView = graphView
        self.dataCache = dataCache
        
        configureHost()
        configureGraph()
        configurePlots()
        configureAxes()
    }
    
    private func configureHost() {
        graphView.allowPinchScaling = true
        graphView.backgroundColor = UIColor.whiteColor()
    }
    
    private func configureGraph() {
        var graph = CPTXYGraph(frame: CGRectZero)
        graphView.hostedGraph = graph
        
        var titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.blackColor()
        titleStyle.fontName = "HelveticaNeue-Medium"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingBottom = 30.0
        graph.plotAreaFrame.paddingLeft = 30.0
        
        graph.paddingTop = 40.0
        graph.paddingBottom = 40.0
        graph.paddingLeft = 40.0
        graph.paddingRight = 40.0
    }
    
    private func configurePlots() {
        var graph = graphView.hostedGraph
        var plotSpace = graph.defaultPlotSpace
        
        var dataPlotX = CPTScatterPlot()
        var dataPlotY = CPTScatterPlot()
        var dataPlotZ = CPTScatterPlot()
        
        dataPlotX.dataSource = self
        dataPlotY.dataSource = self
        dataPlotZ.dataSource = self
        
        dataPlotX.identifier = WaxDataAxis.X.rawValue
        dataPlotY.identifier = WaxDataAxis.Y.rawValue
        dataPlotZ.identifier = WaxDataAxis.Z.rawValue
        
        graph.addPlot(dataPlotX, toPlotSpace: plotSpace)
        graph.addPlot(dataPlotY, toPlotSpace: plotSpace)
        graph.addPlot(dataPlotZ, toPlotSpace: plotSpace)
        
        var dataXColor = CPTColor.redColor()
        var dataYColor = CPTColor.greenColor()
        var dataZColor = CPTColor.blueColor()
        
        var dataXLineStyle = dataPlotX.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataXLineStyle.lineWidth = 2.5
        dataXLineStyle.lineColor = dataXColor
        dataPlotX.dataLineStyle = dataXLineStyle
        
        var dataYLineStyle = dataPlotY.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataYLineStyle.lineWidth = 2.5
        dataYLineStyle.lineColor = dataYColor
        dataPlotY.dataLineStyle = dataYLineStyle
        
        var dataZLineStyle = dataPlotZ.dataLineStyle.mutableCopy() as! CPTMutableLineStyle
        dataZLineStyle.lineWidth = 2.5
        dataZLineStyle.lineColor = dataZColor
        dataPlotZ.dataLineStyle = dataZLineStyle
    }
    
    private func configureAxes() {
        var axisTitleStyle = CPTMutableTextStyle.textStyle() as! CPTMutableTextStyle
        axisTitleStyle.color =  CPTColor.blackColor()
        axisTitleStyle.fontName = "HelveticaNeue-Medium"
        axisTitleStyle.fontSize = 12.0
        var axisLineStyle = CPTMutableLineStyle.lineStyle() as! CPTMutableLineStyle
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.blackColor()
        var axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.blackColor()
        axisTextStyle.fontName = "HelveticaNeue-Medium"
        axisTextStyle.fontSize = 11.0
        
        var axisSet = graphView.hostedGraph.axisSet as! CPTXYAxisSet
        
        var x = axisSet.xAxis as CPTAxis
        x.title = "Time"
        x.titleTextStyle = axisTitleStyle
        x.titleOffset = 15.0
        x.axisLineStyle = axisLineStyle
        x.labelingPolicy = CPTAxisLabelingPolicyNone
        x.labelTextStyle = axisTextStyle
        x.majorTickLineStyle = axisLineStyle
        x.majorTickLength = 4.0
        x.tickDirection = CPTSignNegative
        
        var y = axisSet.yAxis as CPTAxis
        y.title = "Value"
        y.titleTextStyle = axisTitleStyle
        y.titleOffset = -20.0
        y.axisLineStyle = axisLineStyle
        y.labelingPolicy = CPTAxisLabelingPolicyNone;
        y.labelTextStyle = axisTextStyle
        y.labelOffset = 16.0
        y.majorTickLineStyle = axisLineStyle
        y.majorTickLength = 4.0
        y.minorTickLength = 2.0
        y.tickDirection = CPTSignPositive
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        if (dataCache.count() <= 100) {
            return UInt(dataCache.count())
        }
        
        return 100
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        switch (UInt32(fieldEnum)) {
        case CPTScatterPlotFieldX.value:
            return idx
        case CPTScatterPlotFieldY.value:
            var index = Int(idx)
            if (dataCache.count() > 100) {
                var shift = dataCache.count() - 100
                
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
            case WaxDataAxis.X.rawValue:
                return data.x
            case WaxDataAxis.Y.rawValue:
                return data.y
            case WaxDataAxis.Z.rawValue:
                return data.z
            default:
                break
            }
        default:
            break
        }
        
        return 0
    }
    
    func refresh() {
        graphView.hostedGraph.reloadData()
        graphView.hostedGraph.defaultPlotSpace.scaleToFitPlots(graphView.hostedGraph.allPlots())
    }
    
    func pause() {
        dataCache.clearSubscriptions()
    }
    
    func resume() {
        dataCache.subscribe(dataCallback)
    }
    
    func dataCallback(data:WaxData) {
        refresh()
    }
}

enum WaxDataAxis:Int {
    case X = 1, Y, Z
}

enum WaxDataType {
    case Accelerometer, Gyroscope, Magnetometer
}