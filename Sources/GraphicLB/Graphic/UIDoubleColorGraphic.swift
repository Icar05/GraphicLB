//
//  UITest.swift
//  GraphicMotionApplication
//
//  Created by Ipinguin_linuxoid on 2019/02/11.
//  Copyright © 2019 ipinguin_linuxoid. All rights reserved.
//

import UIKit


@IBDesignable
public final class UIDoubleColorGraphic: UIView, UIGraphic {
    
    
    
    @IBInspectable var bC: UIColor = UIColor.black
    
    @IBInspectable var guideColor: UIColor = UIColor.gray
    
    @IBInspectable var positiveColor: UIColor = UIColor.red
    
    @IBInspectable var negativeColor: UIColor = UIColor.orange
    
    @IBInspectable var debugHorizontalGuideColor: UIColor = UIColor.yellow
    
    @IBInspectable var needDebug: Bool = false
    
    @IBInspectable var guidesCount: Int {
        get { return _guidesCount }
        set { if(newValue > 3 && newValue < 10){
            _guidesCount = newValue
        } }
    }
    
    private var graphicPath: UIBezierPath = UIBezierPath()
    
    private let sizeOfView: CGFloat = 150
    
    private let calc = CrossCalculator()
    
    private let defaultDataSourceCount = 50
    
    private let markSize = 2
    
    private var _guidesCount = 4
    
    private var datasource: Queue<Int> = Queue()
    
    private var maxDataSourceValue: CGFloat = 0
    
    public var onValueChanged: (() -> Void )? = nil
    
    
    public override func prepareForInterfaceBuilder(){
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = bounds
    }
    
    
    func setup(){
        self.layer.bounds.size = CGSize(width: CGFloat(sizeOfView), height: CGFloat(sizeOfView))
        self.backgroundColor = bC
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.setupDefaultData()
    }
    
    
    private func setupDefaultData(){
        let values = [1,4,2,4,3,4,4,6,5,7,6,8,7,8,8,7,9,10]
        self.datasource.setup(values)
        self.maxDataSourceValue = CGFloat(self.datasource.getElements().max()!)
    }
    
    public override func draw(_ rect: CGRect) {
        self.drawGuides(count: guidesCount, color: guideColor)
        self.drawGraphic(array: datasource.getElements())
        
        if(needDebug){
            self.drawCenterLine(color: debugHorizontalGuideColor)
            self.drawMarks(array: datasource.getElements())
        }
        
    }
    
    
    private func drawGraphic(array: [Int]){
        
        let horizontalOffset = CGFloat(sizeOfView) / CGFloat(array.count)
        let verticalOffset = CGFloat(sizeOfView) / CGFloat(array.max()!)
        
        var startX: CGFloat = 0
        var startY: CGFloat = sizeOfView / 2
        var endX: CGFloat = 0
        var endY: CGFloat = 0
        
        for index in 0 ..< array.count + 1{
            
            if(index == array.count){
                endX = sizeOfView
                endY = sizeOfView / 2
            }else{
                endX = (CGFloat(index) * horizontalOffset) + (horizontalOffset / 2)
                endY = (CGFloat(array[index]) * verticalOffset ) - (verticalOffset / 2)
            }
            
            self.drawGraphicLine(
                start: CGPoint(x: startX , y:startY ),
                end: CGPoint(x: endX, y:endY),
                index: index
            )
            
            startX = endX
            startY = endY
        }
    }
    
    private func drawGraphicLine(start: CGPoint, end: CGPoint, index: Int){
        
        let center = sizeOfView / 2
        let centerPointStart = CGPoint(x: 0, y: center)
        let centerPointEnd = CGPoint(x: sizeOfView, y: center)
        
        if(crossesTheCentralLine(startY: start.y, newY: end.y)){
            let crossPoint = calc.linesCross(
                start1: start,
                end1: end,
                start2: centerPointStart,
                end2: centerPointEnd)!
            
            
            self.drawLine(startCoords: CGPoint(x: start.x, y: start.y),
                          endCoords: CGPoint(x: crossPoint.x, y: crossPoint.y),
                          color: getColorForMultyLine(start: start.y, end: crossPoint.y))
            
            self.drawLine(startCoords: CGPoint(x: crossPoint.x, y: crossPoint.y),
                          endCoords: CGPoint(x: end.x, y: end.y),
                          color: getColorForMultyLine(start: crossPoint.y, end: end.y))
            
            return
        }
        
        
        self.drawLine(
            startCoords: CGPoint(x: start.x, y: start.y),
            endCoords: CGPoint(x: end.x, y: end.y),
            color: getColorForLinestartY(startY: start.y, endY: end.y))
    }
    
    
    private func drawMarks(array: [Int]){
        
        let horizontalOffset = CGFloat(sizeOfView) / CGFloat(array.count)
        let verticalOffset = CGFloat(sizeOfView) / CGFloat(array.max()!)
        
        for index in 0 ..< array.count{
            
            let model = array[index]
            
            let x = (CGFloat(index) * horizontalOffset) + (horizontalOffset / 2)
            let y = (CGFloat(model) * verticalOffset ) - (verticalOffset / 2)
            
            let coords = CGPoint(x: x, y: y)
            self.drawMark(point: coords, color: UIColor.white, size: CGFloat(markSize))
        }
        
    }
    
    private func drawLine(startCoords: CGPoint, endCoords: CGPoint, color: UIColor){
        color.setStroke()
        
        graphicPath = UIBezierPath()
        graphicPath.move(to: startCoords)
        graphicPath.addLine(to: endCoords)
        graphicPath.stroke()
        graphicPath.close()
    }
    
    private func drawCenterLine(color: UIColor){
        self.drawLine(
            startCoords: CGPoint(x: 0, y: sizeOfView / 2),
            endCoords: CGPoint(x: sizeOfView, y: sizeOfView / 2),
            color: color)
    }
    
    private func drawGuides(count: Int, color: UIColor){
        let offset = CGFloat(sizeOfView) / CGFloat(count)
        
        for index in 1 ..< count{
            let startY: CGFloat = CGFloat(index) * offset
            self.drawLine(
                startCoords: CGPoint(x: 0, y: startY),
                endCoords: CGPoint(x: sizeOfView, y: startY),
                color: color
            )
            
            let startX: CGFloat = CGFloat(index) * offset
            self.drawLine(
                startCoords: CGPoint(x: startX, y: 0),
                endCoords: CGPoint(x: startX, y: sizeOfView),
                color: color
            )
        }
    }
    
    
    private func drawMark(point: CGPoint, color: UIColor, size: CGFloat){
        let startX = point.x - size
        let startY = point.y - size
        let endX = point.x + size
        let endY = point.y + size
        
        self.drawLine(
            startCoords: CGPoint(x: startX, y: startY),
            endCoords: CGPoint(x: endX, y: endY),
            color: color)
        
        self.drawLine(
            startCoords: CGPoint(x: endX, y: startY),
            endCoords: CGPoint(x: startX, y: endY),
            color: color)
    }
    
    
    private func getColorForMultyLine(start: CGFloat, end: CGFloat) -> UIColor{
        let centerY = CGFloat(sizeOfView / 2)
        return (start > centerY || end > centerY) ? negativeColor : positiveColor
    }
    
    private func getColorForLinestartY(startY: CGFloat, endY: CGFloat) -> UIColor{
        let centerY = CGFloat(sizeOfView / 2)
        let middleAge = (startY + endY) / 2
        return middleAge > centerY ? negativeColor : positiveColor
    }
    
    private func crossesTheCentralLine(startY: CGFloat, newY: CGFloat) -> Bool{
        let centerY = CGFloat(sizeOfView / 2)
        return between(start: startY, end: newY, target: centerY) ||
        between(start: newY, end: startY, target: centerY)
    }
    
    private func between(start: CGFloat, end: CGFloat, target: CGFloat) -> Bool{
        return start > target && end < target
    }
    
    
    public func pushValue(index: Int, value: Int) throws {
        
        if(CGFloat(value) > maxDataSourceValue){
            throw RuntimeError("wrong value: \(value) -> max: \(maxDataSourceValue)")
        }
        
        if(value < 1){
            throw RuntimeError("too small value")
        }
        
        self.datasource.push(value)
        self.layer.sublayers = nil
        self.graphicPath = UIBezierPath()
        self.setNeedsDisplay()
        self.onValueChanged?()
    }
    
    
    public func setupWithArray(index: Int, values: [Int]) throws {
        
        if(values.count > defaultDataSourceCount){
            throw RuntimeError("too many start elements")
        }
        
        self.datasource.setup(values)
        self.maxDataSourceValue = CGFloat(self.datasource.getElements().max()!)
        self.layer.sublayers = nil
        self.graphicPath = UIBezierPath()
        self.setNeedsDisplay()
    }
    
    public func getUIView() -> UIView {
        return self
    }
    
}
