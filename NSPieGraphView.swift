//
//  NSPieGraphView.swift
//  NineSeals
//
//  Created by apple on 2019/3/22.
//  Copyright © 2019 NineSeals. All rights reserved.
//

import UIKit

class NSPieGraphView: UIView {
    private let firstLine : CGFloat = 10  //第一条线的长度
    private let secLine : CGFloat = 20    //第二条线长度
    
    var colorArray : [UIColor] = []
    var dataA : [[String : Float]] = []
    
    private let bgLayer : CAShapeLayer =  CAShapeLayer()
    private var titleA : [String] = []   //标题
    private var numberA : [Float] = []  //比例A
    private var radius : CGFloat = 0    //中间半径
    private var circleWidth : CGFloat = 0   //圆环宽度
    
    convenience init(colorA:[UIColor],radiu:CGFloat,circle:CGFloat) {
        self.init()
        self.backgroundColor = UIColor.white
        
        colorArray = colorA
        radius = radiu
        circleWidth = circle
    }

    public func setData(dataA:[[String : Float]]) {
        titleA.removeAll()
        numberA.removeAll()
        for dic in dataA {
            titleA.append(dic.keys.first!)
            numberA.append(dic.values.first!)
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        while self.layer.sublayers?.count ?? 0 > 0 {
            self.layer.sublayers?.removeFirst()
        }
        
        bgLayer.fillColor = UIColor.clear.cgColor
        bgLayer.frame = CGRect.init(x: self.centerX - self.radius, y: self.centerY - self.radius, width: self.radius * 2, height: self.radius * 2)
        
        let bgPath = UIBezierPath.init(arcCenter: self.center, radius: self.radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        bgLayer.path = bgPath.cgPath
        self.layer.addSublayer(bgLayer)
        
        drawPieLayer()
    }
    
    private func drawPieLayer() {
        var startA : CGFloat = 0
        var endA : CGFloat = startA
        
        for i in 0..<numberA.count {
            endA = startA + CGFloat(self.numberA[i] * 2 * .pi)
            
            //添加一个layer用于判断是否在范围内
            
            let subLayer = CAShapeLayer()
            subLayer.strokeColor = UIColor.clear.cgColor
            subLayer.fillColor = UIColor.clear.cgColor
            let centerP = CGPoint.init(x: bgLayer.bounds.width / 2, y: bgLayer.bounds.height / 2)
            
            let subPath = UIBezierPath()
            subPath.move(to: centerP)
            subPath.addArc(withCenter: centerP, radius: self.radius, startAngle: startA, endAngle: endA, clockwise: true)
            subLayer.path = subPath.cgPath
            bgLayer.addSublayer(subLayer)
            
            let pieLayer = NSPieLayer()
            pieLayer.lineWidth = self.circleWidth
            pieLayer.fillColor = UIColor.clear.cgColor
            pieLayer.strokeColor = colorArray[i].cgColor
            
            endA = startA + CGFloat(numberA[i] * 2 * .pi)
            
            let piePath = UIBezierPath.init(arcCenter: centerP, radius: radius - self.circleWidth / 2.0, startAngle: startA, endAngle: endA, clockwise: true)
            
            pieLayer.startAngle = startA
            pieLayer.endAngle = endA
            
            pieLayer.path = piePath.cgPath
            subLayer.addSublayer(pieLayer)
            
            startA = endA
            
            //中心点
            let midAnagle = (pieLayer.startAngle + pieLayer.endAngle) / 2.0
            let newPosition = CGPoint.init(x: bgLayer.position.x + (self.radius + firstLine) * cos(midAnagle), y: bgLayer.position.y + (self.radius + firstLine) * sin(midAnagle))
            
            //添加点
            let circlePointLayer = CAShapeLayer()
            let circlePointPath = UIBezierPath.init(arcCenter: newPosition, radius: 2, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            
            circlePointLayer.fillColor = pieLayer.strokeColor
            circlePointLayer.path = circlePointPath.cgPath
            self.layer.addSublayer(circlePointLayer)
            
            //画线
            let pointLayer = CAShapeLayer()
            pointLayer.lineCap = CAShapeLayerLineCap.round
            pointLayer.lineJoin = CAShapeLayerLineJoin.round
            
            let pointPath = UIBezierPath()
            pointPath.move(to: newPosition)
            
            var firstLinePoint = CGPoint.zero
            if newPosition.x >= bgLayer.position.x {
                if newPosition.y >= bgLayer.position.y {
                    //第一象限
                    firstLinePoint = CGPoint.init(x: newPosition.x + secLine * cos(.pi / 4.0 / 2.0), y: newPosition.y + secLine * sin(.pi / 4.0 * 7.0 / 8.0))
                }else {
                    //第四象限
                    firstLinePoint = CGPoint.init(x: newPosition.x + secLine * cos(.pi / 2.0 * 3 + .pi / 4), y: newPosition.y + secLine * sin(.pi / 2 * 3.0 + .pi / 4.0))
                }
            }else{
                if newPosition.y >= bgLayer.position.y {
                    //第二象限
                    firstLinePoint = CGPoint.init(x: newPosition.x + secLine * cos(.pi - .pi / 4.0), y: newPosition.y + secLine * sin(.pi - .pi / 4.0))
                }else{
                    firstLinePoint = CGPoint.init(x: newPosition.x + secLine * cos(.pi + .pi / 4.0), y: newPosition.y + secLine * sin(.pi + .pi / 4.0))
                }
            }
            pointPath.addLine(to: firstLinePoint)
            
            let lineX : CGFloat = firstLinePoint.x > bgLayer.position.x ? 40 : -40
            
            let secondLinePoint = CGPoint.init(x: firstLinePoint.x + lineX, y: firstLinePoint.y)
            pointPath.addLine(to: secondLinePoint)
            
            pointLayer.strokeColor = pieLayer.strokeColor
            pointLayer.fillColor = UIColor.clear.cgColor
            pointLayer.lineWidth = 1
            pointLayer.path = pointPath.cgPath
            layer.addSublayer(pointLayer)
            
            //添加文字
            let numberString = String(format: "%.2f%%", numberA[i] * 100)
            let titleStirng = String(format: "%@", titleA[i])
            let numberSize = numberString.getTextSizeWithFont(font: 12)
            let titleSize = titleStirng.getTextSizeWithFont(font: 12)
            addTextLayer(text: numberString, frame: CGRect.init(x: secondLinePoint.x - numberSize.width / 2.0, y: secondLinePoint.y - numberSize.height, width: numberSize.width, height: numberSize.height), fontSize: 12)
            addTextLayer(text: titleStirng, frame: CGRect.init(x: secondLinePoint.x - titleSize.width / 2.0, y: secondLinePoint.y, width: titleSize.width, height: titleSize.height), fontSize: 12)
            
        }
    }
    
    func addTextLayer(text:String,frame:CGRect,fontSize:CGFloat) {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.alignmentMode = .center
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = UIColor.lightGray.cgColor
        textLayer.frame = frame
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.isWrapped = false
        self.layer.addSublayer(textLayer)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension String{
    func getTextSizeWithFont(font:CGFloat) -> CGSize {
        let rect = NSString(string: self).boundingRect(with: CGSize.init(width: CGFloat(MAXFLOAT), height: font), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : fontPingFangSC_RegularWithSize(size: font)], context: nil)
        return rect.size
    }
}


class NSPieLayer: CAShapeLayer {
    var startAngle : CGFloat = 0
    var endAngle : CGFloat = 0
}
