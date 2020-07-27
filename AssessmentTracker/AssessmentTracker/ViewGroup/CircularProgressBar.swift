//
//  CircularProgressBar.swift
//  TaskPlanningApp
//
//  Created by Shenali Samaranayake on 5/15/20.
//  Copyright © 2020 Shenali Samaranayake. All rights reserved.
//
import UIKit

class CircularProgressBar: UIView {
    
    @IBInspectable public var backCircleColor: UIColor = UIColor.white
    @IBInspectable public var startGradientColor: UIColor = UIColor.red
    @IBInspectable public var endGradientColor: UIColor = UIColor.orange
    @IBInspectable public var textColor: UIColor = UIColor.white
    @IBInspectable public var customTitle: String = ""
    @IBInspectable public var customSubtitle: String = ""
    
    private var titleLayer: CATextLayer!
    private var subtitleLayer: CATextLayer!
    private var backLayer: CAShapeLayer!
    private var frontLayer: CAShapeLayer!
    private var gradientLayer: CAGradientLayer!
    
    public var progress: CGFloat = 0 {
        didSet {
            onProgressUpdate()
        }
    }
    
    //Draws out the circluar progress bar
    override func draw(_ rect: CGRect) {
        guard layer.sublayers == nil else {
            return
        }
        
        var cProgressTitle = "\(Int(progress * 100))"
        var subtitle = ""
        
        let width = rect.width
        let height = rect.height
        let lineWidth = 0.05 * min(width, height)
        
        backLayer = createCircularLayer(rect: rect, strokeColor: backCircleColor.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        frontLayer = createCircularLayer(rect: rect, strokeColor: UIColor.red.cgColor, fillColor: UIColor.clear.cgColor, lineWidth: lineWidth)
        
        gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        gradientLayer.frame = rect
        gradientLayer.mask = frontLayer
        
        if customTitle != "" {
            cProgressTitle = customTitle
        }
        titleLayer = createTitle(rect: rect, text: cProgressTitle, textColor: textColor.cgColor)
        
        if customSubtitle != "" {
            subtitle = customSubtitle
        }
        subtitleLayer = createSubTitle(rect: rect, text: subtitle, textColor: textColor.cgColor)
        
        layer.addSublayer(backLayer)
        layer.addSublayer(gradientLayer)
        layer.addSublayer(titleLayer)
        layer.addSublayer(subtitleLayer)
    }
    
    //Creates the main title
    private func createTitle(rect: CGRect, text: String, textColor: CGColor) -> CATextLayer {
           
           let width = rect.width
           let height = rect.height
           let fontSize = min(width, height) / 3
           let offset = min(width, height) * 0.1
           let mainLayer = CATextLayer()
        
           mainLayer.string = "\(text)%"
           mainLayer.backgroundColor = UIColor.clear.cgColor
           mainLayer.foregroundColor = textColor
           mainLayer.frame = CGRect(x: 0, y: (height - fontSize - offset) / 2, width: width, height: fontSize + offset)
           mainLayer.alignmentMode = .center
           mainLayer.fontSize = fontSize
        
           return mainLayer
       }
       
    //Creates the subtitle
    private func createSubTitle(rect: CGRect, text: String, textColor: CGColor) -> CATextLayer {
           
           let width = rect.width
           let height = rect.height
           let fontSize = min(width, height) / 10
           let offset = min(width, height) * 0.35
           let subLayer = CATextLayer()
        
           subLayer.string = "\(text)%"
           subLayer.foregroundColor = textColor
           subLayer.fontSize = fontSize
           subLayer.frame = CGRect(x: 0, y: (height - fontSize + offset) / 2, width: width, height: fontSize + offset)
           subLayer.alignmentMode = .center
           subLayer.backgroundColor = UIColor.clear.cgColor
        
           return subLayer
       }
       
    //updates the titles and colors
    private func onProgressUpdate() {
        var title = "\(Int(progress * 100))%"
        var subtitle = ""
        
        if customTitle != "" {
            title = customTitle
        }
        
        if customSubtitle != "" {
            subtitle = customSubtitle
        }
        
        titleLayer?.string = title
        subtitleLayer?.string = subtitle
        frontLayer?.strokeEnd = progress
        
        gradientLayer?.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
    }
    
    //Creates the circular layer
    private func createCircularLayer(rect: CGRect, strokeColor: CGColor,
                                     fillColor: CGColor, lineWidth: CGFloat) -> CAShapeLayer {
        
        let width = rect.width
        let height = rect.height
        let center = CGPoint(x: width / 2, y: height / 2)
        let circlRadius = (min(width, height) - lineWidth) / 2
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let circularPath = UIBezierPath(arcCenter: center, radius: circlRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        let circularShapeLayer = CAShapeLayer()
        
        circularShapeLayer.path = circularPath.cgPath
        circularShapeLayer.fillColor = fillColor
        circularShapeLayer.lineWidth = lineWidth
        circularShapeLayer.strokeColor = strokeColor
        circularShapeLayer.lineCap = .round
        
        return circularShapeLayer
    }
    
   
    
    
}
