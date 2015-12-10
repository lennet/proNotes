//
//  MovablePlotView.swift
//  Student
//
//  Created by Leo Thomas on 10/12/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class MovablePlotView: MovableView {

    func setUpPlotView() {
        clipsToBounds = true
        let plotView = PlotView(frame: bounds)
        addSubview(plotView)
        addAutoLayoutConstraints(plotView)
        plotView.setUpGraph()
    }
    
    override func setUpSettingsViewController() {
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Text
    }

}
