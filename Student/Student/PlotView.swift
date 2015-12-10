//
//  PlotView.swift
//  Student
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit
import CorePlot
import MathParser

class PlotView: CPTGraphHostingView {
    
    func setUpGraph() {
        let graph = CPTXYGraph(frame: bounds)
        self.hostedGraph = graph
        graph.applyTheme(CPTTheme(named: kCPTPlainWhiteTheme))

        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = false
        plotSpace.yRange = CPTPlotRange(location:-5.0, length:10.0)
        plotSpace.xRange = CPTPlotRange(location:-5.0, length:10.0)

        let mainPlot = CPTScatterPlot(frame: bounds)
        let lineStyle = CPTMutableLineStyle()
        lineStyle.miterLimit    = 1.0
        lineStyle.lineWidth     = 3.0
        lineStyle.lineColor     = CPTColor.blackColor()
        mainPlot.dataLineStyle = lineStyle
        mainPlot.identifier    = "Main Plot"
        
        if let axisSet = graph.axisSet as? CPTXYAxisSet {
            if let x = axisSet.xAxis {
                x.majorIntervalLength   = 1
                x.orthogonalPosition    = 0
                x.minorTicksPerInterval = 2
            }
            
            if let y = axisSet.xAxis {
                y.majorIntervalLength   = 1
                y.minorTicksPerInterval = 5
                y.orthogonalPosition    = 0
                
            }
        }
   
        let datasource = CPTFunctionDataSource(forPlot: mainPlot, withBlock: { (value) -> Double in
            let math = "cos($a)"
            let substitutions = ["a": value]
            let result = try! math.evaluate(substitutions)
            return result
        })
        
        datasource.resolution = 2
        
        graph.addPlot(mainPlot)
    }
    
}
