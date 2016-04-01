//
//  CloudDownloadingIndicator.swift
//  proNotes
//
//  Created by Leo Thomas on 22/01/16.
//  Copyright © 2016 leonardthomas. All rights reserved.
//

import UIKit


@IBDesignable
class CloudDownloadingIndicator: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let pathLayer = CAShapeLayer()
        pathLayer.frame = bounds
        pathLayer.lineWidth = 2
        pathLayer.fillColor = UIColor.blackColor().CGColor
        pathLayer.strokeColor = UIColor.redColor().CGColor
        pathLayer.path = cloudBezierPath(bounds).CGPath
        layer.addSublayer(pathLayer)
    }

    private func cloudBezierPath(rect: CGRect) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(320, 32))
        bezierPath.addCurveToPoint(CGPointMake(416, 126.81), controlPoint1: CGPointMake(372.56, 32), controlPoint2: CGPointMake(415.38, 74.44))
        bezierPath.addCurveToPoint(CGPointMake(415.5, 132.69), controlPoint1: CGPointMake(415.75, 128.75), controlPoint2: CGPointMake(415.56, 130.69))
        bezierPath.addLineToPoint(CGPointMake(414.69, 156.19))
        bezierPath.addLineToPoint(CGPointMake(436.94, 163.94))
        bezierPath.addCurveToPoint(CGPointMake(480, 224), controlPoint1: CGPointMake(462.69, 172.91), controlPoint2: CGPointMake(480, 197.06))
        bezierPath.addCurveToPoint(CGPointMake(416, 288), controlPoint1: CGPointMake(480, 259.31), controlPoint2: CGPointMake(451.31, 288))
        bezierPath.addLineToPoint(CGPointMake(96, 288))
        bezierPath.addCurveToPoint(CGPointMake(32, 224), controlPoint1: CGPointMake(60.72, 288), controlPoint2: CGPointMake(32, 259.31))
        bezierPath.addCurveToPoint(CGPointMake(95, 160), controlPoint1: CGPointMake(32, 189.06), controlPoint2: CGPointMake(60.19, 160.56))
        bezierPath.addCurveToPoint(CGPointMake(99.62, 160.5), controlPoint1: CGPointMake(96.5, 160.22), controlPoint2: CGPointMake(98.06, 160.41))
        bezierPath.addLineToPoint(CGPointMake(123.94, 162.09))
        bezierPath.addLineToPoint(CGPointMake(131.94, 139.12))
        bezierPath.addCurveToPoint(CGPointMake(192, 96), controlPoint1: CGPointMake(140.94, 113.31), controlPoint2: CGPointMake(165.06, 96))
        bezierPath.addCurveToPoint(CGPointMake(203.19, 97.19), controlPoint1: CGPointMake(195.12, 96), controlPoint2: CGPointMake(198.56, 96.38))
        bezierPath.addLineToPoint(CGPointMake(225.59, 101.22))
        bezierPath.addLineToPoint(CGPointMake(236.75, 81.38))
        bezierPath.addCurveToPoint(CGPointMake(320, 32), controlPoint1: CGPointMake(253.88, 50.94), controlPoint2: CGPointMake(285.75, 32))
        bezierPath.closePath()
        bezierPath.moveToPoint(CGPointMake(320, 0))
        bezierPath.addCurveToPoint(CGPointMake(208.84, 65.69), controlPoint1: CGPointMake(272.06, 0), controlPoint2: CGPointMake(230.78, 26.69))
        bezierPath.addCurveToPoint(CGPointMake(192, 64), controlPoint1: CGPointMake(203.38, 64.72), controlPoint2: CGPointMake(197.78, 64))
        bezierPath.addCurveToPoint(CGPointMake(101.72, 128.56), controlPoint1: CGPointMake(150.06, 64), controlPoint2: CGPointMake(114.78, 91.06))
        bezierPath.addCurveToPoint(CGPointMake(96, 128), controlPoint1: CGPointMake(99.81, 128.44), controlPoint2: CGPointMake(97.97, 128))
        bezierPath.addCurveToPoint(CGPointMake(0, 224), controlPoint1: CGPointMake(43, 128), controlPoint2: CGPointMake(0, 171))
        bezierPath.addCurveToPoint(CGPointMake(96, 320), controlPoint1: CGPointMake(0, 277), controlPoint2: CGPointMake(43, 320))
        bezierPath.addLineToPoint(CGPointMake(416, 320))
        bezierPath.addCurveToPoint(CGPointMake(512, 224), controlPoint1: CGPointMake(469, 320), controlPoint2: CGPointMake(512, 277))
        bezierPath.addCurveToPoint(CGPointMake(447.44, 133.69), controlPoint1: CGPointMake(512, 182.06), controlPoint2: CGPointMake(484.94, 146.75))
        bezierPath.addCurveToPoint(CGPointMake(448, 128), controlPoint1: CGPointMake(447.5, 131.75), controlPoint2: CGPointMake(448, 129.94))
        bezierPath.addCurveToPoint(CGPointMake(320, 0), controlPoint1: CGPointMake(448, 57.31), controlPoint2: CGPointMake(390.69, 0))
        bezierPath.addLineToPoint(CGPointMake(320, 0))
        bezierPath.closePath()

        bezierPath.applyTransform(CGAffineTransformMakeScale(rect.width / 512, rect.height / 320))
        return bezierPath
    }

}
