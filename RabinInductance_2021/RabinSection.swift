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
    
    var xSection:Double {
        get {
            guard let parentCoil = self.parent else {
                return 0.0
            }
            
            return (parentCoil.outerRadius - parentCoil.innerRadius) * (self.z2 - self.z1)
        }
    }
    
    var Jsection:Double {
        get {
            return self.I * self.N / self.xSection
        }
    }
    
    var J:[Double] = []
    
    var name: String
    
    var identification: Int
    
    var node1: Int = -1
    var node2: Int = -1
    
    var I: Double
    
    weak var parent: RabinCoil?
    
    var z1:Double
    var z2:Double
    
    let N:Double
    
    /// Designated initializer
    /// - Parameter name: A string used to describe the section
    /// - Parameter identification: A unique integer that identifes the section (use the RabinSection.nextSerialNumber property to set this from the calling function)
    /// - Parameter I: The current through a single turn of the section
    /// - Parameter N: The number of turns in the section
    /// - Parameter z1: The bottom-most dimension of the section
    /// - Parameter z2: The top=most dimension of the section
    /// - Parameter parent: The RabinCoil that owns the array that this section is in
    /// - Note: It is assumed that z1 is less than z2. If this is not the case, the initializer will set the z1 and z2 properties to the correct values so that z1 is less than z2.
    init(name:String, identification:Int, I:Double, N:Double, z1:Double, z2:Double, parent:RabinCoil? = nil) {
        
        self.name = name
        self.identification = identification
        self.I = I
        self.N = N
        
        if z1 > z2 {
            
            self.z1 = z2
            self.z2 = z1
        }
        else {
            
            self.z1 = z1
            self.z2 = z2
        }
        
        self.parent = parent
    }
    
    func SetupJarray(L:Double)
    {
        guard self.parent != nil else {
            
            ALog("Parent coil has not been set")
            return
        }
        
        let jSect = self.Jsection
        
        self.J = [jSect * (self.z2 - self.z1) / L]
        
        for i in 1...PCH_Rabin2021_Num_Iterations
        {
            let n = Double(i)
            self.J.append((2 * jSect / (n * π)) * (sin(n * π * self.z2 / L)) - sin(n * π * self.z1 / L))
        }
    }
    
    // Some simple wrappers around constants that already exist in the parent RabinCoil (to avoid recalculating things). Note that these are all ZERO-based
    
    private func Integer_xI1x_dx(n:Int) -> Double
    {
        return self.parent!.G[n].Integral
    }
    
    private func Integer_xK1x_dx(n:Int) -> Double
    {
        return self.parent!.C[n]
    }
    
    private func Integer_xL1x_dx(n:Int) -> Double
    {
        return self.parent!.Int_tL1t[n]
    }
}
