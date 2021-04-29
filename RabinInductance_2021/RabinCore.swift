//
//  RabinCore.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//

import Foundation

class RabinCore:Codable {
    
    let radius:Double
    let windowWidth:Double
    private let realWindowHt:Double
    
    var windowHeightMultiplier:Double
    
    var adjustedWindowHeight:Double {
        
        get {
            
            return self.realWindowHt * windowHeightMultiplier
        }
    }
    
    init(radius:Double, windowWidth:Double, windowHt:Double, windowHtMultiplier:Double) {
        
        self.radius = radius
        self.windowWidth = windowWidth
        self.realWindowHt = windowHt
        self.windowHeightMultiplier = windowHtMultiplier
    }
    
    convenience init(xlFile:PCH_ExcelDesignFile, windowHtMultiplier:Double)
    {
        self.init(radius:xlFile.core.radius, windowWidth:xlFile.core.windowWidth, windowHt:xlFile.core.windowHeight, windowHtMultiplier:windowHtMultiplier)
    }
    
}
