//
//  DrawingView.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DrawingView: PageSubView {

    var path = UIBezierPath()
    var incrementalImage: UIImage?
    var points  = [CGPoint?](count:5, repeatedValue: nil)
  
    var didChange = false
    
    var counter = 0
    var drawLayer: DocumentDrawLayer?{
        didSet{
            incrementalImage = drawLayer?.image
        }
    }

    init(drawLayer: DocumentDrawLayer, frame: CGRect) {
        self.drawLayer = drawLayer
        incrementalImage = self.drawLayer?.image
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit{
        if incrementalImage != nil && drawLayer != nil && didChange{
            drawLayer?.image = incrementalImage
            DocumentSynchronizer.sharedInstance.updateDrawLayer(drawLayer!, forceReload: false)
            didChange = false
        }
    }
    
    func commonInit() {
        multipleTouchEnabled = false
        backgroundColor = UIColor.clearColor()
        path.lineWidth = 2.0
    }
    
    override func drawRect(rect: CGRect) {
        if incrementalImage != nil {
            incrementalImage!.drawInRect(rect)
        }
        stroke()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        DocumentSynchronizer.sharedInstance.settingsViewController?.currentSettingsType = .Drawing
        
        let touch = touches.first
        points[0] = (touch?.locationInView(self))!
    }
    

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first
        let point = touch?.locationInView(self)
        counter++
        points[counter] = point!
        if counter == 4 {
            points[3] = CGPointMake((points[2]!.x + points[4]!.x)/2.0, (points[2]!.y + points[4]!.y)/2.0); // move the endpoint to the middle of the line joining the second control point of the first Bezier segment and the first control point of the second Bezier segment
            path.moveToPoint(points[0]!)
            path.addCurveToPoint(points[3]!, controlPoint1: points[1]!, controlPoint2: points[2]!)
            setNeedsDisplay()
            

            // replace points and get ready to handle the next segment
            points[0] = points[3];
            points[1] = points[4];
            counter = 1;
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchesEnd()
    }
    
    func touchesEnd() {
        didChange = true
        drawBitmap()
        setNeedsDisplay()
        path.removeAllPoints()
        counter = 0
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        touchesEnd()
    }
    
    func drawBitmap() {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.0);

//        if incrementalImage == nil {
//            let rectPath = UIBezierPath(rect: self.bounds)
//            backgroundColor?.setFill()
//            rectPath.fill()
//        }
        incrementalImage?.drawInRect(self.bounds)
        stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func stroke() {
        DrawingSettings.sharedInstance.color.setStroke()
        path.lineWidth = DrawingSettings.sharedInstance.lineWidth
        if DrawingSettings.sharedInstance.color == UIColor.clearColor() {
            path.strokeWithBlendMode(.Clear, alpha: 1.0)
        } else {
            path.stroke()
        }
    }
    


}
