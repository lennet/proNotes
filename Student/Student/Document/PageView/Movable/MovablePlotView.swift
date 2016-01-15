//
//  MovablePlotView.swift
//  Student
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovablePlotView: MovableView, PlotSettingsDelegate {

    var plotView = PlotView()

    func setUpPlotView() {
        clipsToBounds = true
        plotView.frame = bounds
        addSubview(plotView)
        plotView.layoutIfNeeded()
        plotView.setUpGraph((movableLayer as? PlotLayer)?.function)
    }

    override func setUpSettingsViewController() {
        PlotSettingsViewController.delegate = self
        SettingsViewController.sharedInstance?.currentSettingsType = .Plot
    }

    // MARK: - PlotSettingsDelegate

    func updatePlot(function: String) {
        plotView.setUpGraph(function)
        if let layer = movableLayer as? PlotLayer {
            layer.function = function
            DocumentSynchronizer.sharedInstance.updateMovableLayer(layer)
        }
    }

}
