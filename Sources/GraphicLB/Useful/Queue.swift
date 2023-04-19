//
//  Queue.swift
//  GraphicMotionApplication
//
//  Created by ICoon on 04.02.2022.
//  Copyright © 2022 ipinguin_linuxoid. All rights reserved.
//


/**
 source -> https://benoitpasquier.com/data-structure-implement-queue-swift/
 */
public struct Queue<T> {
    
    private var elements: [T] = []
    
    public init(){}
    
    public init(_ elements: [T]){
        self.elements = elements
    }
    
    public mutating func enqueue(_ value: T) {
        elements.append(value)
    }
    
    @discardableResult
    public mutating func dequeue() -> T? {
        guard !elements.isEmpty else {
            return nil
        }
        return elements.removeFirst()
    }
    
    public mutating func count() -> Int{
        return elements.count
    }
    
    public mutating func setup(_ values: [T]){
        self.elements = values
    }
    
    public mutating func getElements() ->  [T]{
        return elements
    }
    
    public mutating func getElement(index: Int) -> T{
        return elements[index]
    }
    
    public mutating func push(_ value: T){
        self.enqueue(value)
        self.dequeue()
    }
    
    public var head: T? {
        return elements.first
    }
    
    public var tail: T? {
        return elements.last
    }
}
