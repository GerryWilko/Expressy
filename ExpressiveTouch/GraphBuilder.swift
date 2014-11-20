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
        titleStyle.color = CPTColor.whiteColor()
        titleStyle.fontName = "Helvetica-Bold"
        titleStyle.fontSize = 16.0
        
        graph.titleTextStyle = titleStyle
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop
        graph.titleDisplacement = CGPointMake(0.0, 10.0)
        
        graph.plotAreaFrame.paddingLeft = 30.0
        graph.plotAreaFrame.paddingBottom = 30.0
        
        graph.defaultPlotSpace.allowsUserInteraction = true
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
        
        graph.addPlot(accPlotX)
        graph.addPlot(accPlotY)
        graph.addPlot(accPlotZ)
        
        graph.addPlot(gyroPlotX)
        graph.addPlot(gyroPlotY)
        graph.addPlot(gyroPlotZ)
        
        graph.addPlot(magPlotX)
        graph.addPlot(magPlotY)
        graph.addPlot(magPlotZ)
        
        plotSpace.scaleToFitPlots([accPlotX, accPlotY, accPlotZ, gyroPlotX, gyroPlotY, gyroPlotZ, magPlotX, magPlotY, magPlotZ])
        
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
        var accSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        accSymbol.fill = CPTFill(color: accColor)
        accSymbol.lineStyle = accSymbolLineStyle;
        accSymbol.size = CGSizeMake(6.0, 6.0)
        accPlotX.plotSymbol = accSymbol
        accPlotY.plotSymbol = accSymbol
        accPlotZ.plotSymbol = accSymbol
        
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
        var gyroSymbol = CPTPlotSymbol.starPlotSymbol()
        gyroSymbol.fill = CPTFill(color: gyroColor)
        gyroSymbol.lineStyle = gyroSymbolLineStyle
        gyroSymbol.size = CGSizeMake(6.0, 6.0)
        gyroPlotX.plotSymbol = gyroSymbol;
        gyroPlotY.plotSymbol = gyroSymbol;
        gyroPlotZ.plotSymbol = gyroSymbol;
        
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
        var magSymbol = CPTPlotSymbol.diamondPlotSymbol()
        magSymbol.fill = CPTFill(color: magColor)
        magSymbol.lineStyle = magSymbolLineStyle
        magSymbol.size = CGSizeMake(6.0, 6.0)
        magPlotX.plotSymbol = magSymbol
        magPlotY.plotSymbol = magSymbol
        magPlotZ.plotSymbol = magSymbol
    }
    
    func configureAxes() {
    }
    
    func numberOfRecordsForPlot(plot: CPTPlot!) -> UInt {
        return UInt(accCache.count())
    }
    
    func numberForPlot(plot: CPTPlot!, fieldEnum: UInt, index: UInt) -> NSNumber! {
        var valueCount:UInt = 1000
        
        switch (UInt32(fieldEnum)) {
        case CPTScatterPlotFieldX.value:
            if (index < valueCount) {
                return index
            }
            break;
            
        case CPTScatterPlotFieldY.value:
            switch plot.identifier as Int {
            case SensorDataType.AX.rawValue:
                return accCache.get(index).x
            case SensorDataType.AY.rawValue:
                return accCache.get(index).y
            case SensorDataType.AZ.rawValue:
                return accCache.get(index).z
            case SensorDataType.GX.rawValue:
                return gyroCache.get(index).x
            case SensorDataType.GY.rawValue:
                return gyroCache.get(index).y
            case SensorDataType.GZ.rawValue:
                return gyroCache.get(index).z
            case SensorDataType.MX.rawValue:
                return magCache.get(index).x
            case SensorDataType.MY.rawValue:
                return magCache.get(index).y
            case SensorDataType.MZ.rawValue:
                return magCache.get(index).z
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
    }
}