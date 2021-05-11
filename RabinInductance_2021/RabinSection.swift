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
    
    // Self Inductance Calculation
    func SelfInductance() -> Double
    {
        let N1 = self.N
        let I1 = self.I
        
        let selfCoil = self.parent!
        
        let L = selfCoil.core.adjustedWindowHeight
        
        let r1 = selfCoil.innerRadius
        let r2 = selfCoil.outerRadius
        
        let firstTerm =  π * µ0 * N1 * N1 / (6 * L) * ((r2 + r1) * (r2 + r1) + 2 * r1 * r1)
        
        let result = PCH_MathArray(doubleArray: [firstTerm])
        
        let multiplierNumerator = π * µ0 * L // * N1 * N1
        let multiplierDenominator = I1 * I1 // * N1 * N1
        let multiplier = multiplierNumerator / multiplierDenominator
        
        for n in 1...PCH_Rabin2021_Num_Iterations
        {
            let m = Double(n) * π / L
            
            let Jn1 = self.J[n]
            
            let Jn1Jn1 = Jn1 * Jn1
            let m4 = m * m * m * m
            
            result.Insert(selfCoil.E[n-1] * self.Integral_xI1x_dx(n: n-1) * Jn1Jn1 * multiplier / m4)
            result.Insert(selfCoil.F[n-1].Dn * self.Integral_xK1x_dx(n: n-1) * Jn1Jn1 * multiplier / m4)
            result.Insert(selfCoil.F[n-1].Integral * self.Integral_xK1x_dx(n: n-1) * Jn1Jn1 * multiplier / m4)
            result.Insert(self.Integral_xL1x_dx(n: n-1) * -π / 2.0 * Jn1Jn1 * multiplier / m4)
        }
        
        return result.Sum()
    }
    
    // Mutual Inductance Calculation
    func MutualInductanceTo(otherSection:RabinSection) -> Double
    {
        let N1 = self.N
        let N2 = otherSection.N
        
        let I1 = self.I
        let I2 = otherSection.I
        
        let selfCoil = self.parent!
        let otherCoil = otherSection.parent!
        
        let L = selfCoil.core.adjustedWindowHeight
        
        let r1 = selfCoil.innerRadius
        let r2 = selfCoil.outerRadius
        
        // let r3 = otherCoil.innerRadius
        // let r4 = otherCoil.outerRadius
        
        let sameRadialPosition = fabs(r1 - otherCoil.innerRadius) < 0.001
        
        let firstTerm = sameRadialPosition ? π * µ0 * N1 * N2 / (6 * L) * ((r2 + r1) * (r2 + r1) + 2 * r1 * r1) : π * µ0 * N1 * N2 / (3 * L) * (r1 * r1 + r1 * r2 + r2 * r2)
        
        let result = PCH_MathArray(doubleArray: [firstTerm])
        
        // Ignore the N1N2/N1N2 addition that DelVecchio does. I think the real reason he does it is to take care of "opposite" wound coils. For now, I am ignoring it. This may change if I can figure out whether it is required for "double-stacked" coils. All that really needs to be done is for the N1 * N2 terms in the following two let statements to be uncommented.
        let multiplierNumerator = π * µ0 * L // * N1 * N2
        let multiplierDenominator = I1 * I2 // * N1 * N2
        let multiplier = multiplierNumerator / multiplierDenominator
        
        for n in 1...PCH_Rabin2021_Num_Iterations
        {
            let m = Double(n) * π / L
            // let x1 = m * r1
            // let x2 = m * r2
            
            let Jn1 = self.J[n]
            let Jn2 = otherSection.J[n]
            
            let Jn1Jn2 = Jn1 * Jn2
            let m4 = m * m * m * m
            
            if sameRadialPosition
            {
                result.Insert(selfCoil.E[n-1] * self.Integral_xI1x_dx(n: n-1) * Jn1Jn2 * multiplier / m4)
                result.Insert(selfCoil.F[n-1].Dn * self.Integral_xK1x_dx(n: n-1) * Jn1Jn2 * multiplier / m4)
                result.Insert(selfCoil.F[n-1].Integral * self.Integral_xK1x_dx(n: n-1) * Jn1Jn2 * multiplier / m4)
                result.Insert(self.Integral_xL1x_dx(n: n-1) * -π / 2.0 * Jn1Jn2 * multiplier / m4)
            }
            else
            {
                result.Insert(otherCoil.C[n-1] * self.Integral_xI1x_dx(n: n-1) * Jn1Jn2 * multiplier / m4)
                result.Insert(otherCoil.D[n-1] * self.Integral_xK1x_dx(n: n-1) * Jn1Jn2 * multiplier / m4)
            }
        }
        
        return result.Sum()
    }
    
    func SetupJarray(L:Double)
    {
        guard self.parent != nil else {
            
            ALog("Parent coil has not been set")
            return
        }
        
        let jSect = self.Jsection
        
        // J0
        self.J = [jSect * (self.z2 - self.z1) / L]
        
        for i in 1...PCH_Rabin2021_Num_Iterations
        {
            let n = Double(i)
            self.J.append((2 * jSect / (n * π)) * (sin(n * π * self.z2 / L)) - sin(n * π * self.z1 / L))
        }
    }
    
    // Some simple wrappers around constants that already exist in the parent RabinCoil (to avoid recalculating things). Note that these are all ZERO-based
    
    private func Integral_xI1x_dx(n:Int) -> Double
    {
        return self.parent!.G[n].Integral
    }
    
    private func Integral_xK1x_dx(n:Int) -> Double
    {
        return self.parent!.C[n]
    }
    
    private func Integral_xL1x_dx(n:Int) -> Double
    {
        return self.parent!.Int_tL1t[n]
    }
}
