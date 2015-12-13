//
//  MovablePlotView.swift
//  Student
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovablePlotView: MovableView, PlotSettingsDelegate {

    var plotView: PlotView?
    
    func setUpPlotView() {
        clipsToBounds = true
        plotView = PlotView(frame: bounds)
        addSubview(plotView!)
        addAutoLayoutConstraints(plotView!)
        plotView?.setUpGraph((movableLayer as? PlotLayer)?.function)
    }
    
    override func setUpSettingsViewController() {
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Plot
        PlotSettingsViewController.delegate = self
    }
    
    // MARK: - PlotSettingsDelegate
    
    func updatePlot(function: String) {
        plotView?.setUpGraph(function)
        // todo update layer object
    }

}
