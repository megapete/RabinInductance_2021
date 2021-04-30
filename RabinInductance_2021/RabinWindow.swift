//
//  RabinWindow.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//


// This class defines the contents of the window of a phase.

import Foundation

let PCH_Rabin2021_Num_Iterations = 200
let PCH_Rabin2021_RelError = 1.0E-12
let PCH_Rabin2021_AbsError = 1.0E-15


class RabinWindow:Codable {
    
    let core:RabinCore
    
    let coils:[RabinCoil]
    
    init(core:RabinCore, coils:[RabinCoil]) {
        
        self.core = core
        self.coils = coils
    }
    
}
