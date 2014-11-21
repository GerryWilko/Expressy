//
//  GraphBuilder.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GraphBuilder : NSObject, CPTPlotDataSource {
    var graphView:CPTGraphHostingView
    var accCache:WaxCache
    var gyroCache:WaxCache
    var magCache:WaxCache
    
    init(accCache:WaxCache, gyroCache:WaxCache, magCache:WaxCache) {
        self.graphView = CPTGraphHostingView()
        
        self.accCache = accCache
        self.gyroCache = gyroCache
        self.magCache = magCache
        
        super.init()
    }
    
    func initLoad(graphView:CPTGraphHostingView) {
        self.graphView = graphView
        
        self.configureHost()
        self.configureGraph()
        self.configurePlots()
        self.configureAxes()
    }
    
    func configureHost() {
        self.graphView.allowPinchScaling = true
    }
    
    func configureGraph() {
        var graph = CPTXYGraph(frame: CGRectZero)
        self.graphView.hostedGraph = graph
        
        graph.title = "WAX9 Data"
        
        var titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.blackColor()
        titleStyle.fontName = "Helvetica-Bold"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingLeft = 30.0
        graph.plotAreaFrame.paddingBottom = 30.0
        
        //graph.defaultPlotSpace.allowsUserInteraction = true
    }
    
    func configurePlots() {
        var graph = self.graphView.hostedGraph
        var plotSpace = graph.defaultPlotSpace
        
        var accPlotX = CPTScatterPlot()
        var accPlotY = CPTScatterPlot()
        var accPlotZ = CPTScatterPlot()
        
        var gyroPlotX = CPTScatterPlot()
        var gyroPlotY = CPTScatterPlot()
        var gyroPlotZ = CPTScatterPlot()
        
        var magPlotX = CPTScatterPlot()
        var magPlotY = CPTScatterPlot()
        var magPlotZ = CPTScatterPlot()
        
        accPlotX.dataSource = self
        accPlotY.dataSource = self
        accPlotZ.dataSource = self
        
        gyroPlotX.dataSource = self
        gyroPlotY.dataSource = self
        gyroPlotZ.dataSource = self
        
        magPlotX.dataSource = self
        magPlotY.dataSource = self
        magPlotZ.dataSource = self
        
        accPlotX.identifier = SensorDataType.AX.rawValue
        accPlotY.identifier = SensorDataType.AY.rawValue
        accPlotZ.identifier = SensorDataType.AZ.rawValue
        
        gyroPlotX.identifier = SensorDataType.GX.rawValue
        gyroPlotY.identifier = SensorDataType.GY.rawValue
        gyroPlotZ.identifier = SensorDataType.GZ.rawValue
        
        magPlotX.identifier = SensorDataType.MX.rawValue
        magPlotY.identifier = SensorDataType.MY.rawValue
        magPlotZ.identifier = SensorDataType.MZ.rawValue
        
        graph.addPlot(accPlotX, toPlotSpace: plotSpace)
        graph.addPlot(accPlotY, toPlotSpace: plotSpace)
        graph.addPlot(accPlotZ, toPlotSpace: plotSpace)
        
        graph.addPlot(gyroPlotX, toPlotSpace: plotSpace)
        graph.addPlot(gyroPlotY, toPlotSpace: plotSpace)
        graph.addPlot(gyroPlotZ, toPlotSpace: plotSpace)
        
        graph.addPlot(magPlotX, toPlotSpace: plotSpace)
        graph.addPlot(magPlotY, toPlotSpace: plotSpace)
        graph.addPlot(magPlotZ, toPlotSpace: plotSpace)
        
        var accColor = CPTColor.redColor()
        var gyroColor = CPTColor.greenColor()
        var magColor = CPTColor.blueColor()
        
        var accLineStyleX = accPlotX.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        accLineStyleX.lineWidth = 2.5
        accLineStyleX.lineColor = accColor
        accPlotX.dataLineStyle = accLineStyleX
        var accLineStyleY = accPlotY.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        accLineStyleY.lineWidth = 2.5
        accLineStyleY.lineColor = accColor
        accPlotY.dataLineStyle = accLineStyleY
        var accLineStyleZ = accPlotZ.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        accLineStyleZ.lineWidth = 2.5
        accLineStyleZ.lineColor = accColor
        accPlotZ.dataLineStyle = accLineStyleZ
        
        var accSymbolLineStyle = CPTMutableLineStyle.lineStyle() as CPTMutableLineStyle
        accSymbolLineStyle.lineColor = accColor
        
        var gyroLineStyleX = gyroPlotX.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        gyroLineStyleX.lineWidth = 1.0
        gyroLineStyleX.lineColor = gyroColor
        gyroPlotX.dataLineStyle = gyroLineStyleX
        var gyroLineStyleY = gyroPlotY.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        gyroLineStyleY.lineWidth = 1.0
        gyroLineStyleY.lineColor = gyroColor
        gyroPlotY.dataLineStyle = gyroLineStyleY
        var gyroLineStyleZ = gyroPlotZ.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        gyroLineStyleZ.lineWidth = 1.0
        gyroLineStyleZ.lineColor = gyroColor
        gyroPlotZ.dataLineStyle = gyroLineStyleZ
        
        var gyroSymbolLineStyle = CPTMutableLineStyle.lineStyle() as CPTMutableLineStyle
        gyroSymbolLineStyle.lineColor = gyroColor
        
        var magLineStyleX = magPlotX.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        magLineStyleX.lineWidth = 2.0
        magLineStyleX.lineColor = magColor
        magPlotX.dataLineStyle = magLineStyleX
        var magLineStyleY = magPlotY.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        magLineStyleY.lineWidth = 2.0
        magLineStyleY.lineColor = magColor
        magPlotY.dataLineStyle = magLineStyleY
        var magLineStyleZ = magPlotZ.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        magLineStyleZ.lineWidth = 2.0
        magLineStyleZ.lineColor = magColor
        magPlotZ.dataLineStyle = magLineStyleZ
        
        var magSymbolLineStyle = CPTMutableLineStyle.lineStyle() as CPTMutableLineStyle
        magSymbolLineStyle.lineColor = magColor
    }
    
    func configureAxes() {
        var axisTitleStyle = CPTMutableTextStyle.textStyle() as CPTMutableTextStyle
        axisTitleStyle.color =  CPTColor.blackColor()
        axisTitleStyle.fontName = "Helvetica-Bold"
        axisTitleStyle.fontSize = 12.0
        var axisLineStyle = CPTMutableLineStyle.lineStyle() as CPTMutableLineStyle
        axisLineStyle.lineWidth = 2.0
        axisLineStyle.lineColor = CPTColor.blackColor()
        var axisTextStyle = CPTMutableTextStyle()
        axisTextStyle.color = CPTColor.blackColor()
        axisTextStyle.fontName = "Helvetica-Bold"
        axisTextStyle.fontSize = 11.0
        var tickLineStyle = CPTMutableLineStyle.lineStyle() as CPTMutableLineStyle
        tickLineStyle.lineColor = CPTColor.blackColor()
        tickLineStyle.lineWidth = 2.0
        var gridLineStyle = CPTMutableLineStyle.lineStyle() as CPTMutableLineStyle
        tickLineStyle.lineColor = CPTColor.blackColor()
        tickLineStyle.lineWidth = 1.0
        
        var axisSet = self.graphView.hostedGraph.axisSet as CPTXYAxisSet
        
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
        y.majorGridLineStyle = gridLineStyle
        y.labelingPolicy = CPTAxisLabelingPolicyNone;
        y.labelTextStyle = axisTextStyle
        y.labelOffset = 16.0
        y.majorTickLineStyle = axisLineStyle
        y.majorTickLength = 4.0
        y.minorTickLength = 2.0
        y.tickDirection = CPTSignPositive
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        switch (plot.identifier as Int) {
        case SensorDataType.AX.rawValue:
            fallthrough
        case SensorDataType.AY.rawValue:
            fallthrough
        case SensorDataType.AZ.rawValue:
            return UInt(accCache.count())
        case SensorDataType.GX.rawValue:
            fallthrough
        case SensorDataType.GY.rawValue:
            fallthrough
        case SensorDataType.GZ.rawValue:
            return UInt(gyroCache.count())
        case SensorDataType.MX.rawValue:
            fallthrough
        case SensorDataType.MY.rawValue:
            fallthrough
        case SensorDataType.MZ.rawValue:
            return UInt(magCache.count())
        default:
            break
        }
        return 0;
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        switch (UInt32(fieldEnum)) {
        case CPTScatterPlotFieldX.value:
            return idx
        case CPTScatterPlotFieldY.value:
            switch plot.identifier as Int {
            case SensorDataType.AX.rawValue:
                return accCache.get(idx).x
            case SensorDataType.AY.rawValue:
                return accCache.get(idx).y
            case SensorDataType.AZ.rawValue:
                return accCache.get(idx).z
            case SensorDataType.GX.rawValue:
                return gyroCache.get(idx).x
            case SensorDataType.GY.rawValue:
                return gyroCache.get(idx).y
            case SensorDataType.GZ.rawValue:
                return gyroCache.get(idx).z
            case SensorDataType.MX.rawValue:
                return magCache.get(idx).x
            case SensorDataType.MY.rawValue:
                return magCache.get(idx).y
            case SensorDataType.MZ.rawValue:
                return magCache.get(idx).z
            default:
                break
            }
        default:
            return 0
        }
        
        return 0
    }
    
    func refresh() {
        graphView.hostedGraph.reloadData()
        graphView.hostedGraph.defaultPlotSpace.scaleToFitPlots(graphView.hostedGraph.allPlots())
    }
}