//
//  RabinCoil.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//

import Foundation
import Accelerate



class RabinCoil:Codable {
    
    // The name of the coil. This should be set manually if setting up coils using the Excel design sheet.
    var name:String
    
    // radii of the coil
    let innerRadius:Double
    let outerRadius:Double
    
    private var sectionStore:[RabinSection] = []
    
    // the axial sections that make up the coil
    var sections:[RabinSection] {
        get {
            return self.sectionStore
        }
        set {
            self.sectionStore = newValue
            for nextSection in newValue
            {
                nextSection.parent = self
            }
        }
    }
    
    // the rated current through the coil
    let I:Double
    
    // the direction of the current in the coil. This is either -1 or 1 for Rabin coils
    let currentDirection:Int
    
    /// Designated initializer for the class. Returns a RabinCoil.
    /// - Parameter innerRadius: The innermost radius of the coil
    /// - Parameter outerRadius: The outermost (electrical) radius of the coil
    /// - Parameter I: The current through the coil
    /// - Parameter currentDirection: an Int representing the direction of current (clamped to -1 or 1)
    /// - Parameter sections: The axial sections that make up the coil.
    init(innerRadius:Double, outerRadius:Double, I:Double, currentDirection:Int, name:String = "", sections:[RabinSection] = []) {
        
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
        self.I = I
        
        if currentDirection >= 0
        {
            self.currentDirection = 1
        }
        else
        {
            self.currentDirection = -1
        }
        
        self.name = name

        self.sections = sections
    }
    
    /// Return a RabinCoil using the given Winding (generated by PCH_ExcelDesignFile) and the given RabinCore. The returned RabinCoil will be centered on the adjusted core window height. Note that every disc of a disc-winding will be modeled.
    convenience init(xlWinding:PCH_ExcelDesignFile.Winding, core:RabinCore, name:String = "")
    {
        var sections:[RabinSection] = []
        
        let numMainAxialSections = 1 + xlWinding.centerGap > 0 ? 1 : 0 + xlWinding.topDvGap > 0 ? 1 : 0 + xlWinding.bottomDvGap > 0 ? 1 : 0
        
        if xlWinding.windingType == .disc || xlWinding.windingType == .helix
        {
            let useAxialSections = xlWinding.windingType == .disc ? xlWinding.numAxialSections : Int(xlWinding.numTurns.max)
            let turnsPerDisc = xlWinding.numTurns.max / Double(useAxialSections)
            let numInterdisks = useAxialSections - numMainAxialSections
            let totalAxialInsulation = (Double(numInterdisks) * xlWinding.stdAxialGap + xlWinding.centerGap + xlWinding.topDvGap + xlWinding.bottomDvGap) * 0.98
            var gaps:[Double] = [0.0]
            let discAxialDimension = (xlWinding.electricalHeight - totalAxialInsulation) / Double(useAxialSections)
            
            var mainSectionDiscs:[Int] = []
            if numMainAxialSections == 1
            {
                mainSectionDiscs = [useAxialSections]
            }
            else if numMainAxialSections == 2
            {
                let bottomDiscCount = Int(ceil(Double(useAxialSections / 2)))
                mainSectionDiscs.append(bottomDiscCount)
                mainSectionDiscs.append(useAxialSections - bottomDiscCount)
                gaps = [xlWinding.centerGap]
            }
            else if numMainAxialSections == 3
            {
                let upperAndLowerSectionDiscCount = Int(ceil(Double(useAxialSections) / 4))
                let centerSectionDiscCount = useAxialSections - 2 * upperAndLowerSectionDiscCount
                mainSectionDiscs = [upperAndLowerSectionDiscCount, centerSectionDiscCount, upperAndLowerSectionDiscCount]
                gaps = [xlWinding.bottomDvGap, xlWinding.topDvGap]
            }
            else // 4 sections
            {
                let bottomHalfDiscCount = Int(ceil(Double(useAxialSections / 2)))
                let topHalfDiscCount = useAxialSections - bottomHalfDiscCount
                let bottompQuarterDiscCount = Int(ceil(Double(bottomHalfDiscCount / 2)))
                let centerBottomQuarterDiscCount = bottomHalfDiscCount - bottompQuarterDiscCount
                let topQuarterDiscCount = bottompQuarterDiscCount
                let centerTopQuarterDiscCount = topHalfDiscCount - topQuarterDiscCount
                
                mainSectionDiscs = [bottompQuarterDiscCount, centerBottomQuarterDiscCount, centerTopQuarterDiscCount, topQuarterDiscCount]
                
                gaps = [xlWinding.bottomDvGap, xlWinding.centerGap, xlWinding.topDvGap]
            }
            
            var currentMinZ = (core.adjustedWindowHeight - xlWinding.electricalHeight) / 2
            
            for nextMainSection in mainSectionDiscs
            {
                for _ in 0..<nextMainSection
                {
                    let newID = RabinSection.nextSerialNumber
                    let newName = String(format: "%s%04d", name, newID)
                    let newSection = RabinSection(name: newName, identification: RabinSection.nextSerialNumber, I: xlWinding.I, N: turnsPerDisc, z1: currentMinZ, z2: currentMinZ + discAxialDimension)
                    
                    sections.append(newSection)
                    
                    currentMinZ += discAxialDimension + xlWinding.stdAxialGap * 0.98
                }
                
                currentMinZ += (gaps.removeFirst() - xlWinding.stdAxialGap) * 0.98
            }
        }
        else // if xlWinding.windingType == .layer
        {
            // other windings are considered as huge single discs that may be divided by major axial gaps
            let useAxialSections = numMainAxialSections
            let turnsPerDisc = xlWinding.numTurns.max / Double(useAxialSections)
            let totalAxialInsulation = (xlWinding.centerGap + xlWinding.topDvGap + xlWinding.bottomDvGap) * 0.98
            var gaps:[Double] = [0.0]
            let discAxialDimension = (xlWinding.electricalHeight - totalAxialInsulation) / Double(useAxialSections)
            
            var mainSectionDiscs:[Int] = []
            if numMainAxialSections == 1
            {
                mainSectionDiscs = [useAxialSections]
            }
            else if numMainAxialSections == 2
            {
                let bottomDiscCount = Int(ceil(Double(useAxialSections / 2)))
                mainSectionDiscs.append(bottomDiscCount)
                mainSectionDiscs.append(useAxialSections - bottomDiscCount)
                gaps = [xlWinding.centerGap]
            }
            else if numMainAxialSections == 3
            {
                let upperAndLowerSectionDiscCount = Int(ceil(Double(useAxialSections) / 4))
                let centerSectionDiscCount = useAxialSections - 2 * upperAndLowerSectionDiscCount
                mainSectionDiscs = [upperAndLowerSectionDiscCount, centerSectionDiscCount, upperAndLowerSectionDiscCount]
                gaps = [xlWinding.bottomDvGap, xlWinding.topDvGap]
            }
            else // 4 sections
            {
                let bottomHalfDiscCount = Int(ceil(Double(useAxialSections / 2)))
                let topHalfDiscCount = useAxialSections - bottomHalfDiscCount
                let bottompQuarterDiscCount = Int(ceil(Double(bottomHalfDiscCount / 2)))
                let centerBottomQuarterDiscCount = bottomHalfDiscCount - bottompQuarterDiscCount
                let topQuarterDiscCount = bottompQuarterDiscCount
                let centerTopQuarterDiscCount = topHalfDiscCount - topQuarterDiscCount
                
                mainSectionDiscs = [bottompQuarterDiscCount, centerBottomQuarterDiscCount, centerTopQuarterDiscCount, topQuarterDiscCount]
                
                gaps = [xlWinding.bottomDvGap, xlWinding.centerGap, xlWinding.topDvGap]
            }
            
            var currentMinZ = (core.adjustedWindowHeight - xlWinding.electricalHeight) / 2
            
            for nextMainSection in mainSectionDiscs
            {
                for _ in 0..<nextMainSection
                {
                    // we need to be careful setting the N and I values for sheet windings that have been split in two (or more).
                    var newI = xlWinding.I
                    var newN = turnsPerDisc
                    
                    if xlWinding.windingType == .sheet && numMainAxialSections > 1
                    {
                        newN = xlWinding.numTurns.max
                        newI = newI / Double(numMainAxialSections)
                    }
                    
                    let newID = RabinSection.nextSerialNumber
                    let newName = String(format: "%s%04d", name, newID)
                    let newSection = RabinSection(name: newName, identification: RabinSection.nextSerialNumber, I: newI, N: newN, z1: currentMinZ, z2: currentMinZ + discAxialDimension)
                    
                    sections.append(newSection)
                    
                    currentMinZ += discAxialDimension // + xlWinding.stdAxialGap * 0.98
                }
                
                currentMinZ += gaps.removeFirst() * 0.98
            }
            
        }
        
        self.init(innerRadius:xlWinding.innerRadius, outerRadius:xlWinding.outerElectricalRadius, I:xlWinding.I, currentDirection:xlWinding.terminal.currentDirection, name:name, sections:sections)
    }
    
    
    // DelVecchio functions
    
    /// DelVecchio 3e, Eq. 9.58(a)
    static func L0(x:Double) -> Double
    {
        return gsl_sf_bessel_I0(x) - self.M0(x: x)
    }
    
    /// DelVecchio 3e, Eq. 9.58(b)
    static func L1(x:Double) -> Double
    {
        return gsl_sf_bessel_I1(x) - self.M1(x: x)
    }
    
    /// DelVecchio 3e, Eq. 9.59(a)
    static func M0(x:Double) -> Double
    {
        // consider changing to .qng to help performance
        let quadrature = Quadrature(integrator: .qag(pointsPerInterval: .sixtyOne, maxIntervals: 100), absoluteTolerance: PCH_Rabin2021_AbsError, relativeTolerance: PCH_Rabin2021_RelError)
        
        let integrationResult = quadrature.integrate(over: 0.0...(π / 2.0)) { theta in
            
            return exp(-x * cos(theta))
            
        }
        
        switch integrationResult {
        
        case .success((let result, _ /* let estAbsError */)):
            // DLog("Absolute error: \(estAbsError); p.u: \(estAbsError / result)")
            return result * 2.0 / π
        
        case .failure(let error):
            ALog("Error calling integration routine. The error is: \(error)")
            return 0.0
        }
    }
    
    /// The left-hand side of 9.59(b)
    static func AltM1(x:Double) -> Double
    {
        let quadrature = Quadrature(integrator: .qag(pointsPerInterval: .sixtyOne, maxIntervals: 100), absoluteTolerance: PCH_Rabin2021_AbsError, relativeTolerance: PCH_Rabin2021_RelError)
        
        let integrationResult = quadrature.integrate(over: 0.0...(π / 2.0)) { theta in
            
            let sinTheta = sin(theta)
            return exp(-x * cos(theta)) * sinTheta * sinTheta
            
        }
        
        switch integrationResult {
        
        case .success((let result, let estAbsError )):
            print("AltM1: Absolute error: \(estAbsError)")
            return result * 2.0 * x / π
        
        case .failure(let error):
            ALog("Error calling integration routine. The error is: \(error)")
            return 0.0
        }
    }
    
    /// DelVecchio 3e, Eq. 9.59(b)
    static func M1(x:Double) -> Double
    {
        // consider changing to .qng to help performance
        let quadrature = Quadrature(integrator: .qag(pointsPerInterval: .sixtyOne, maxIntervals: 100), absoluteTolerance: PCH_Rabin2021_AbsError, relativeTolerance: PCH_Rabin2021_RelError)
        
        let integrationResult = quadrature.integrate(over: 0.0...(π / 2.0)) { theta in
            
            return exp(-x * cos(theta)) * cos(theta)
            
        }
        
        switch integrationResult {
        
        case .success((let result, let estAbsError )):
            print("M1: Absolute error: \(estAbsError)")
            return (1.0 - result) * 2.0 / π
        
        case .failure(let error):
            ALog("Error calling integration routine. The error is: \(error)")
            return 0.0
        }
    }
    
    /// DelVecchio 3e, Eq. 6.60
    static func IntegralOf_M0_t_dt(from a:Double, to b:Double) -> Double
    {
        ZAssert(b >= a, message: "Illegal integral range")
        
        if a == 0.0
        {
            // consider changing to .qng to help performance
            let quadrature = Quadrature(integrator: .qag(pointsPerInterval: .sixtyOne, maxIntervals: 100), absoluteTolerance: PCH_Rabin2021_AbsError, relativeTolerance: PCH_Rabin2021_RelError)
            
            let integrationResult = quadrature.integrate(over: 0.0...(π / 2.0)) { theta in
                
                return (1 - exp(-b * cos(theta))) / cos(theta)
            }
            
            switch integrationResult {
            
            case .success((let result, _ /* let estAbsError */)):
                // DLog("Absolute error: \(estAbsError); p.u: \(estAbsError / result)")
                return result * 2.0 / π
            
            case .failure(let error):
                ALog("Error calling integration routine. The error is: \(error)")
                return 0.0
            }
        }
        
        return IntegralOf_M0_t_dt(from: 0, to: b) - IntegralOf_M0_t_dt(from: 0, to: a)
    }
}
