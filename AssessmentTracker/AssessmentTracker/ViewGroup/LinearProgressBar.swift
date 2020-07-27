//
//  AddTaskViewController.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/16/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//


import UIKit

class LinearProgressBar: UIView {

    
    @IBInspectable public var backCircleColor: UIColor = UIColor.white
    @IBInspectable public var startGradientColor: UIColor = UIColor.red
    @IBInspectable public var endGradientColor: UIColor = UIColor.orange
    
    private var backLayer: CAShapeLayer!
    private var frontLayer: CAShapeLayer!
    private var colouredLayer: CAGradientLayer!
    
    public var progress: CGFloat = 0 {
        didSet {
            onProgressUpdate()
        }
    }
    
    //Draws the linear progress bar
    override func draw(_ rect: CGRect) {
        guard layer.sublayers == nil else {
            return
        }
        
        let width = rect.width
        let height = rect.height
        let lineWidth = 0.29 * min(width, height)
        
        backLayer = createBar(rect: rect, strokeColor: backCircleColor.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        frontLayer = createBar(rect: rect, strokeColor: UIColor.red.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        colouredLayer = CAGradientLayer()
        colouredLayer.startPoint = CGPoint(x: 0, y: 0.0)
        colouredLayer.endPoint = CGPoint(x: 1, y: 0)
        colouredLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        colouredLayer.frame = rect
        colouredLayer.mask = frontLayer
        
        layer.addSublayer(backLayer)
        layer.addSublayer(colouredLayer)
    }
    
    private func onProgressUpdate() {
           frontLayer?.strokeEnd = progress
           colouredLayer?.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
       }
    
    //Creates the linear bar
    private func createBar(rect: CGRect, strokeColor: CGColor, fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let width = rect.width
        
        let circularPath = UIBezierPath()
        circularPath.move(to: CGPoint(x: 0, y: 5))
        circularPath.addLine(to: CGPoint(x: width, y: 5))
        
        let linearLayer = CAShapeLayer()
        
        linearLayer.path = circularPath.cgPath
        linearLayer.strokeColor = strokeColor
        linearLayer.fillColor = fillColor
        linearLayer.lineWidth = lineWidth
        linearLayer.lineCap = .round
        
        return linearLayer
    }
    
    
}
