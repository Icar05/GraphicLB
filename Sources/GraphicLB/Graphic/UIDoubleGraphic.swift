//
//  UITestMultiple.swift
//  GraphicMotionApplication
//
//  Created by ICoon on 28.07.2022.
//  Copyright © 2022 ipinguin_linuxoid. All rights reserved.
//

import UIKit

public struct UIDoubleGraphicModel{
    public let positivewColor: UIColor
    public let negativeColor: UIColor
    public var datasource: Queue<Int> = Queue()
    
    
    public init(positivewColor: UIColor, negativeColor: UIColor) {
        self.positivewColor = positivewColor
        self.negativeColor = negativeColor
    }
    
}
public extension UIDoubleGraphicModel {
    mutating func getMaxValue() -> CGFloat{
        return  CGFloat(datasource.getElements().max()!)
    }
    
    mutating func getValues() -> [Int]{
        return  datasource.getElements()
    }
}

@IBDesignable
public final class UIDoubleGraphic: UIView, UIGraphic {
    
    
    
    @IBInspectable var bC: UIColor = UIColor.black
    
    @IBInspectable var guideColor: UIColor = UIColor.gray
    
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
    
    private var datasource: [UIDoubleGraphicModel] = []
    
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
        var datasource = Queue<Int>()
            datasource.setup(values)
    }
    
    public override func draw(_ rect: CGRect) {
        self.drawGuides(count: guidesCount, color: guideColor)
        
        for i in 0...datasource.count - 1{
            self.drawGraphic(model: &datasource[i])
        }
        
        if(needDebug){
            self.drawCenterLine(color: debugHorizontalGuideColor)
            
            
            for i in 0...datasource.count - 1{
                self.drawMarks(array:  datasource[i].getValues())
            }
        }
        
    }
    
    
    private func drawGraphic(model: inout UIDoubleGraphicModel){
        
        let array: [Int] = model.datasource.getElements()
        
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
                index: index,
                negColor: model.negativeColor,
                posColor: model.positivewColor
            )
            
            startX = endX
            startY = endY
        }
    }
    
    private func drawGraphicLine(start: CGPoint, end: CGPoint, index: Int, negColor: UIColor, posColor: UIColor){
        
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
                          color: getColorForMultyLine(start: start.y, end: crossPoint.y, negColor: negColor, posColor: posColor))
            
            self.drawLine(startCoords: CGPoint(x: crossPoint.x, y: crossPoint.y),
                          endCoords: CGPoint(x: end.x, y: end.y),
                          color: getColorForMultyLine(start: crossPoint.y, end: end.y, negColor: negColor, posColor: posColor))
            
            return
        }
        
        
        self.drawLine(
            startCoords: CGPoint(x: start.x, y: start.y),
            endCoords: CGPoint(x: end.x, y: end.y),
            color: getColorForLinestartY(startY: start.y, endY: end.y, negColor: negColor, posColor: posColor))
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
    
    
    private func getColorForMultyLine(start: CGFloat, end: CGFloat, negColor: UIColor, posColor: UIColor) -> UIColor{
        let centerY = CGFloat(sizeOfView / 2)
        return (start > centerY || end > centerY) ? negColor : posColor
    }
    
    private func getColorForLinestartY(startY: CGFloat, endY: CGFloat, negColor: UIColor, posColor: UIColor) -> UIColor{
        let centerY = CGFloat(sizeOfView / 2)
        let middleAge = (startY + endY) / 2
        return middleAge > centerY ? negColor : posColor
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
        
//        if(CGFloat(value) > datasource[index].getMaxValue()){
//            throw RuntimeError("wrong value: \(value) -> max: \(datasource[index].getMaxValue())")
//        }
        
        if(value < 1){
            throw RuntimeError("too small value")
        }
        
        self.datasource[index].datasource.push(value)
    }
    
    public func update(){
        self.layer.sublayers = nil
        self.graphicPath = UIBezierPath()
        self.setNeedsDisplay()
        self.onValueChanged?()
    }
    
    
    public func setupWithArray(index: Int, model: inout UIDoubleGraphicModel) throws{
        
        if(model.datasource.getElements().count > defaultDataSourceCount){
            throw RuntimeError("too many start elements")
        }
        
        self.datasource.append(model)
        self.layer.sublayers = nil
        self.graphicPath = UIBezierPath()
        self.setNeedsDisplay()
    }
    
    public func setupWithArray(index: Int, values: [Int]) throws {
        
        if(values.count > defaultDataSourceCount){
            throw RuntimeError("too many start elements")
        }
        
        self.datasource[index] = UIDoubleGraphicModel(positivewColor: UIColor.red, negativeColor: UIColor.orange)

        self.datasource[index].datasource.setup(values)
        self.layer.sublayers = nil
        self.graphicPath = UIBezierPath()
        self.setNeedsDisplay()
    }
    
    public func getUIView() -> UIView {
        return self
    }
    
}
