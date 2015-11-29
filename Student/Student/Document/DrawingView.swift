//
//  DrawingView.swift
//  Student
//
//  Created by Leo Thomas on 28/11/15.
//  Copyright © 2015 leonardthomas. All rights reserved.
//

import UIKit

class DrawingView: UIView {

    var path = UIBezierPath()
    var incrementalImage: UIImage?
    var points  = [CGPoint?](count:5, repeatedValue: nil)
  
    var counter = 0
    var drawLayer: DocumentDrawLayer?{
        didSet{
            incrementalImage = drawLayer?.image
            setNeedsDisplay()
        }
    }
  
    init(drawLayer: DocumentDrawLayer, frame: CGRect) {
        self.drawLayer = drawLayer
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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

        if incrementalImage == nil {
            let rectPath = UIBezierPath(rect: self.bounds)
            backgroundColor?.setFill()
            rectPath.fill()
        }
        incrementalImage?.drawAtPoint(CGPointZero)
        stroke()
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func stroke() {
        DrawingSettings.sharedInstance.color.setStroke()
        path.lineWidth = DrawingSettings.sharedInstance.lineWidth
        path.stroke()
    }
    


}
