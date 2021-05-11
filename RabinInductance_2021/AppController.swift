//
//  AppController.swift
//  RabinInductance_2021
//
//  Created by Peter Huber on 2021-04-28.
//

import Cocoa

class AppController: NSObject {
    
    let numTests = 10
    let L = 1.5
    let r1 = 0.2
    let r2 = 0.25
    
    @IBAction func handleTestM1(_ sender: Any) {
        
        let core = RabinCore(radius: 0.295 / 2, windowWidth: 0.350, windowHt: 0.680, windowHtMultiplier: 2.5)
        
        let fullInnerSection = RabinSection(name: "Inner", identification: 1, I: 170, N: 190, z1: 3 * meterPerInch, z2: 0)
    }
    
    @IBAction func handleTestAltM1(_ sender: Any) {
        
        for i in 1..<numTests {
            
            let n = Double(i)
            let m = n * π / L
            
            let x1 = m * r1
            let x2 = m * r2
            
            let intM0 = RabinCoil.IntegralOf_M0_t_dt(from: x1, to: x2)
            
            print(intM0)
            
        }
        
    }
    
}
