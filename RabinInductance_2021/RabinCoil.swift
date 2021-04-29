//
//  RabinCoil.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//

import Foundation

class RabinCoil:Codable {
    
    let innerRadius:Double
    let outerRadius:Double
    
    var sections:[RabinSection]
    
    init(innerRadius:Double, outerRadius:Double, sections:[RabinSection] = []) {
        
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.sections = sections
    }
}
