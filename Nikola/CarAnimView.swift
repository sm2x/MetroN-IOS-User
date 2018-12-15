//
//  CarAnimView.swift
//  caranimation
//
//  Created by Sutharshan Ram on 04/10/17.
//  Copyright © 2017 Sutharshan. All rights reserved.
//

import UIKit
import SpriteKit

class CarAnimView: UIView {

    let carDuration:Double = 2.0
    let blackLineDuration:Double = 2.0
    let orangeLineDuration:Double = 0.3
    var path: UIBezierPath!
    var path2: UIBezierPath!
    var greenPoint: CGPoint!
    let greenMarker: CALayer = CALayer()
    let car: CALayer = CALayer()
    let orangeLayer = CAShapeLayer()
    let shapeLayer = CAShapeLayer()
    override init(frame: CGRect){
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func addCar(){
        car.bounds = CGRect(x: 0, y: 0.0, width: 44.0, height: 20.0)
        car.position = CGPoint(x:-100.0, y:-100.0)
        self.layer.addSublayer(car)
        animate(car: car)
        let rotatedImage = UIImage(named: "map_limo")?.rotated(by: Measurement(value: 90.0, unit: .degrees))
        car.contents = rotatedImage?.cgImage
    }
    
    func animate(car: CALayer){
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.doAnim()
        })
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position"
        animation.repeatCount = 0
        animation.beginTime = CACurrentMediaTime() + orangeLineDuration
        animation.duration = carDuration
        animation.rotationMode = kCAAnimationRotateAuto
        animation.path = path.cgPath
        car.add(animation, forKey: "car1anim")
        CATransaction.commit()
    }
    
    func generatePath(top: Bool){
        
        let height = self.frame.size.height
        let width = self.frame.size.width
        
        var startY = Double(arc4random_uniform(UInt32(height/3)))
        var endY = Double(arc4random_uniform(UInt32(height/3)))
        
        if (arc4random_uniform(2) == 1) {
            endY += Double(height/3*2)
        }else{
            startY += Double(height/3*2)
        }
        
        var midY = 0
        let diff: Int = abs((Int(startY) - Int(endY))/2)
        if startY > endY {
            midY =  Int(endY) + Int(arc4random_uniform(UInt32(abs(diff/2)))) + diff/2 //+ Int(startY)
        }else{
            midY =  Int(startY) + Int(arc4random_uniform(UInt32(abs(diff/2)))) + diff/2 //+ Int(startY)
        }
        var split = 1
        if (arc4random_uniform(2) == 1) { // split to 3
            split = 2
        }else{
            if (arc4random_uniform(2) == 1){
                midY = Int(startY)
            }else{
                midY = Int(endY)
            }
        }
        
        let X1 = Int(arc4random_uniform(UInt32(width/4)))
        let X2 = Int(arc4random_uniform(UInt32(width/4)))
        
        var px1 = X1
        var px2 = X2
        if X1 > X2 {
            px1 = X2 + Int(width/4)
            px2 = X1 + Int(width/2)
        } else{
            px1 += Int(width/4)
            px2 += Int(width/2)
        }
        path = UIBezierPath()
        path2 = UIBezierPath()
        path.move(to: CGPoint(x:0.0, y: Double(startY)))
        greenPoint = CGPoint(x:0.0, y: Double(endY))
        
        if split == 1 {
            
            path.addLine(to: CGPoint(x: Double(px1), y: Double(midY)))
            greenPoint = CGPoint(x:(Double(px1) + Double(width))/2, y: (Double(midY) + Double(endY))/2)
            path2.move(to: greenPoint)
            path2.addLine(to: CGPoint(x: Double(px1), y: Double(midY)))
        } else {
            path.addLine(to: CGPoint(x: Double(px1), y: Double(midY)))
            path.addLine(to: CGPoint(x: Double(px2), y: Double(midY)))
            greenPoint = CGPoint(x:(Double(px2) + Double(width))/2, y: (Double(midY) + Double(endY))/2)
            path2.move(to: greenPoint)
            path2.addLine(to: CGPoint(x: Double(px2), y: Double(midY)))
            path2.addLine(to: CGPoint(x: Double(px1), y: Double(midY)))
        }
        
        path.addLine(to: CGPoint(x: width, y: CGFloat(endY)))
        path2.addLine(to: CGPoint(x:0.0, y: Double(startY)))
    }
    
    func animatePath(){
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.path = path.cgPath
        
        // animate it
        self.layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = blackLineDuration
        shapeLayer.add(animation, forKey: "MyAnimation")
    }
    
    func animatePath2(){
        orangeLayer.isHidden = false
        orangeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        orangeLayer.strokeColor = #colorLiteral(red: 1, green: 0.6564314961, blue: 0, alpha: 1).cgColor
        orangeLayer.lineWidth = 3
        orangeLayer.path = path2.cgPath
        // animate it
        self.layer.addSublayer(orangeLayer)
        let animation2 = CABasicAnimation(keyPath: "strokeEnd")
        animation2.fromValue = 0
        animation2.duration = orangeLineDuration
        orangeLayer.add(animation2, forKey: "MyAnimation")
    }
    
    override func draw(_ rect: CGRect) {
        doAnim()
    }
    
    func doAnim()
    {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            self.animatePath2()
            self.greenMarker.bounds = CGRect(x: 0, y: 0.0, width: 16.0, height: 16.0)
            self.greenMarker.position = self.greenPoint
            self.greenMarker.isHidden = false
            self.greenMarker.contents = UIImage(named: "address_bar_pickup")?.cgImage
            self.layer.addSublayer(self.greenMarker)
            self.car.isHidden = false
            self.addCar()
        })
        car.isHidden = true
        greenMarker.isHidden = true
        orangeLayer.isHidden = true
        generatePath(top: true)
        self.greenMarker.position = self.greenPoint
        animatePath()
        CATransaction.commit()

    }
}

extension UIImage {
    struct RotationOptions: OptionSet {
        let rawValue: Int
        static let flipOnVerticalAxis = RotationOptions(rawValue: 1)
        static let flipOnHorizontalAxis = RotationOptions(rawValue: 2)
    }
    
    func rotated(by rotationAngle: Measurement<UnitAngle>, options: RotationOptions = []) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        
        let rotationInRadians = CGFloat(rotationAngle.converted(to: .radians).value)
        let transform = CGAffineTransform(rotationAngle: rotationInRadians)
        var rect = CGRect(origin: .zero, size: self.size).applying(transform)
        rect.origin = .zero
        
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        return renderer.image { renderContext in
            renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
            renderContext.cgContext.rotate(by: rotationInRadians)
            
            let x = options.contains(.flipOnVerticalAxis) ? -1.0 : 1.0
            let y = options.contains(.flipOnHorizontalAxis) ? 1.0 : -1.0
            renderContext.cgContext.scaleBy(x: CGFloat(x), y: CGFloat(y))
            
            let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
            renderContext.cgContext.draw(cgImage, in: drawRect)
        }
    }
}
