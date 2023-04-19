//
//  EqualizerView.swift
//  Watch Consumables
//
//  Created by ICoon on 01.07.2022.
//  Copyright © 2022 icar05. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics


public struct UIEqualizerModel{
    var values: [CGPoint]
}

public extension UIEqualizerModel{
    
    static func random() -> UIEqualizerModel{
        
        let indicatorsInRow = 7
        let indicatorsInColumt = 12
        
        var models: [CGPoint] = []
        
        for index in 0...indicatorsInRow - 1 {
            let randValue = Int.random(in: 0..<indicatorsInColumt)
            models.append(CGPoint(x: index, y: randValue))
        }
        
        return UIEqualizerModel(values: models)
    }
    
    func equel(model: UIEqualizerModel) -> Bool{
        for index in 0...model.values.count - 1{
            if(model.values[index].y != self.values[index].y){
                return false
            }
        }
        
        return true
    }
    
    func getValues() -> [CGPoint]{
        return self.values
    }
    
}


@IBDesignable
public class UIEqualizer: UIView{
    
    
    
    private let animationInterval = 0.05
    
    private var graphicPath = UIBezierPath()
    
    private let padding = 8
    
    private let indicatorsInRow = 7
    
    private let indicatorsInColumt = 12
    
    private var equalizerModel: UIEqualizerModel = UIEqualizerModel.random()
    
    private var timer: Timer? = nil
    
    private var isRunningAnimation = false
    
    
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
    
    public init(_ width: CGFloat, _ height: CGFloat){
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        setup()
    }
    
    
    func setup(){
        self.equalizerModel = prepareBaseModel()
        self.drawBackgroundColor(size: self.bounds.size)
        self.border()
    }
    
    
    public override func draw(_ rect: CGRect) {
        self.drawIndicators()
    }
    
    
    private func drawIndicators(){
        let allowSize = calculateAllowedSize()
        let indicatorSize = calculateIndicatorSize(allowSize: allowSize)
        
        var xStart: CGFloat = CGFloat(padding)
        var yStart: CGFloat = CGFloat(allowSize.height)
        
        
        for index in 0...indicatorsInColumt - 1{
            
            let color = calculateColor(index: index)
            
            for horizontalIndex in 0...indicatorsInRow - 1 {

                let model = equalizerModel.getValues()[horizontalIndex]
                let value: Int = Int(model.y)

                if(index <= value){
                    self.drawRectangle(x: xStart, y: yStart, size: indicatorSize, color: color)
                }

                xStart += (CGFloat(padding) + indicatorSize.width)
            }

            xStart = CGFloat(padding)
            yStart -= (CGFloat(padding / 2) +  indicatorSize.height)
        }
    }
    
    public func drawDiagrammAnimated(model: UIEqualizerModel, callback:  (() -> Void)? = nil){
        
        if(isRunningAnimation){
            return
        }
        
        
        self.isRunningAnimation  = true
        
        let models = prepareModelsForAnimation(wantedResult: model)
        
        var value = 0
        
        self.timer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [weak self] timer in
            
            let model = models[value]
            self?.drawDiagramm(model: model)
            
            value += 1
            
            if(value == models.count){
                timer.invalidate()
                self?.isRunningAnimation = false
                callback?()
            }
        }
        
    }
    
    public func drawDiagramm(model: UIEqualizerModel){
        self.equalizerModel = model
        self.setNeedsDisplay()
    }
    
    
    private func prepareModelsForAnimation(wantedResult: UIEqualizerModel) -> [UIEqualizerModel]{
        
        var models: [UIEqualizerModel] = []
        
        var currentModel = equalizerModel
        
        
        for _ in 0...indicatorsInColumt - 1{
            
            let updatedModel = prepareValues(wantedResult, currentModel: currentModel)
            
            models.append(updatedModel)
            
            
            if(updatedModel.equel(model: wantedResult)){
                return models
            }
            
            
            currentModel = updatedModel
        }
        
        return models
    }
    
    
    /**
     prepare values for horizontal, up and down row
     */
    private func prepareValues(_ wantedResult: UIEqualizerModel, currentModel: UIEqualizerModel) -> UIEqualizerModel{
        
        var result: [CGPoint] = []
        var valuesForUp: [CGFloat] = (currentModel.values.map { $0.y })
        
        for index in 0...indicatorsInRow  - 1 {
            let currentValue = valuesForUp[index]
            let wantedValue = wantedResult.values[index].y
            
            if(currentValue < wantedValue){
                valuesForUp[index] += 1
            }
            
            if(currentValue > wantedValue){
                valuesForUp[index] -= 1
            }
            
            result.append(CGPoint(x: CGFloat(index), y: valuesForUp[index]))
        }
        
        return UIEqualizerModel(values: result)
    }
    
    
    
    private func prepareBaseModel() -> UIEqualizerModel{
        var models: [CGPoint] = []
        
        for index in 0...indicatorsInRow - 1 {
            let randValue = Int.random(in: 0..<indicatorsInColumt)
            models.append(CGPoint(x: index, y: randValue))
        }
        
        return UIEqualizerModel(values: models)
    }
    
    private func calculateColor(index: Int) -> UIColor{
        
        let topPart = (indicatorsInColumt / 3 ) * 2
        let middlePart = (indicatorsInColumt / 2)
        
        if(index > topPart){
            return UIColor.red
        }else if(index >= middlePart){
            return UIColor.orange
        } else {
            return UIColor.green
        }
        
    }
    
    
    private func drawRectangle(x: CGFloat, y: CGFloat, size: CGSize, color: UIColor){
        
        let context = UIGraphicsGetCurrentContext()
        
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        color.set()
        context?.addRect(rect)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
    }
    
    
    private func calculateIndicatorSize(allowSize: CGSize) -> CGSize{
        
        let leftForIndicators: CGFloat = allowSize.width - CGFloat((indicatorsInRow - 1) * padding)
        let width: CGFloat = leftForIndicators / CGFloat(indicatorsInRow)
        
        let leftForIndicatorsV: CGFloat = allowSize.height - CGFloat((indicatorsInColumt - 1) * (padding / 2))
        let height: CGFloat = leftForIndicatorsV / CGFloat(indicatorsInColumt)
        
        return CGSize(width: width, height: height)
    }
    
    private func calculateAllowedSize() -> CGSize{
        return CGSize(
            width:  self.bounds.width - CGFloat((padding * 2)),
            height: self.bounds.height - CGFloat((padding * 2))
        )
    }
    
    private func drawBackgroundColor(size: CGSize){
        let color = self.appropriateSize(size: size) ? UIColor.white : UIColor.red
        self.backgroundColor = color.withAlphaComponent(0.4)
    }
    
    private func appropriateSize(size: CGSize) -> Bool{
        return size.height >= 100 && size.width >= 100
    }
    
    private func border(){
        layer.masksToBounds = true
        layer.borderWidth = 1.5
        layer.borderColor = UIColor.black.cgColor
    }
    
}

