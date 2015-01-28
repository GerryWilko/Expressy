//
//  GraphBuilder.swift
//  ExpressiveTouch
//
//  Created by Gerry Wilkinson on 19/11/2014.
//  Copyright (c) 2014 Newcastle University. All rights reserved.
//

import Foundation

class GraphBuilder : NSObject, CPTPlotDataSource {
    private var graphView:CPTGraphHostingView
    private var dataCache:WaxCache
    private let title:String
    private var timer:NSTimer
    
    init(title:String) {
        graphView = CPTGraphHostingView()
        dataCache = WaxCache(limit: 0)
        
        self.title = title
        
        timer = NSTimer()
        
        super.init()
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
    }
    
    private func configureGraph() {
        var graph = CPTXYGraph(frame: CGRectZero)
        graphView.hostedGraph = graph
        
        graph.title = title
        
        var titleStyle = CPTMutableTextStyle()
        titleStyle.color = CPTColor.blackColor()
        titleStyle.fontName = "Helvetica-Bold"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingLeft = 30.0
        graph.plotAreaFrame.paddingBottom = 30.0
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
        
        var dataXLineStyle = dataPlotX.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        dataXLineStyle.lineWidth = 2.5
        dataXLineStyle.lineColor = dataXColor
        dataPlotX.dataLineStyle = dataXLineStyle
        
        var dataYLineStyle = dataPlotY.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        dataYLineStyle.lineWidth = 2.5
        dataYLineStyle.lineColor = dataYColor
        dataPlotY.dataLineStyle = dataYLineStyle
        
        var dataZLineStyle = dataPlotZ.dataLineStyle.mutableCopy() as CPTMutableLineStyle
        dataZLineStyle.lineWidth = 2.5
        dataZLineStyle.lineColor = dataZColor
        dataPlotZ.dataLineStyle = dataZLineStyle
    }
    
    private func configureAxes() {
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
        
        var axisSet = graphView.hostedGraph.axisSet as CPTXYAxisSet
        
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
        switch (plot.identifier as Int) {
        case WaxDataAxis.X.rawValue:
            fallthrough
        case WaxDataAxis.Y.rawValue:
            fallthrough
        case WaxDataAxis.Z.rawValue:
            return UInt(dataCache.length())
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
            case WaxDataAxis.X.rawValue:
                return dataCache.get(idx).x
            case WaxDataAxis.Y.rawValue:
                return dataCache.get(idx).y
            case WaxDataAxis.Z.rawValue:
                return dataCache.get(idx).z
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
        timer.invalidate()
    }
    
    func resume() {
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "refresh", userInfo: nil, repeats: true)
    }
}