//
//  RabinSection.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//

import Foundation

class RabinSection:Codable {
    
    private static var nextSerialNumberStore:Int = 0
    
    static var nextSerialNumber:Int {
        get {
            
            let nextNum = RabinSection.nextSerialNumberStore
            RabinSection.nextSerialNumberStore += 1
            return nextNum
        }
    }
    
    var name: String
    
    var identification: Int
    
    var node1: Int = -1
    var node2: Int = -1
    
    var I: Double
    
    weak var parent: RabinCoil?
    
    var z1:Double
    var z2:Double
    
    let N:Double
    
    init(name:String, identification:Int, I:Double, N:Double, z1:Double, z2:Double, parent:RabinCoil? = nil) {
        
        self.name = name
        self.identification = identification
        self.I = I
        self.N = N
        self.z1 = z1
        self.z2 = z2
        self.parent = parent
    }
}
