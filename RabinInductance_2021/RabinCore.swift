//
//  RabinCore.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//

import Foundation

fileprivate let defaultWindowHtMultiplier = 3.0

class RabinCore:Codable {
    
    let radius:Double
    private let realWindowHt:Double
    
    var windowHeightMultiplier:Double
    
    var windowHeight:Double {
        
        get {
            
            return self.realWindowHt * windowHeightMultiplier
        }
    }
    
}
