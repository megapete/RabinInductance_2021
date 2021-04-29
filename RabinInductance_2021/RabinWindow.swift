//
//  RabinWindow.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//


// This class defines the window of a phase.

import Foundation

class RabinWindow:Codable {
    
    let core:RabinCore
    
    let coils:[RabinCoil]
    
    init(core:RabinCore, coils:[RabinCoil]) {
        
        self.core = core
        self.coils = coils
    }
    
}
