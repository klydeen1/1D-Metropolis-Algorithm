//
//  OneDMetropolis.swift
//  1D-Metropolis-Algorithm
//
//  Created by Katelyn Lydeen on 3/25/22.
//

import Foundation

class OneDMetropolis: NSObject, ObservableObject {
    @Published var OneDSpins: [Double] = []
    @Published var enableButton = true
    
    var mySpin = OneDSpin()
    var N = 20
    var temp = 273.15 // Temperature in Kelvin
    let kB = 1.380649e-23 // Boltzmann constant
    let J = 1.0 // The exchange energy
    
    /// runMetropolis
    /// Runs the 1D Metropolis algorithm and prints the resulting configuration
    /// Also sets and prints the initial spin array if the array is empty
    /// - Parameters:
    ///   - startType: the starting configuration for the spin array. value "hot" means we start with random spins. "cold" means the spins are ordered
    func runMetropolis(startType: String) async {
        if (mySpin.spinArray.isEmpty) {
            await initializeSpin(startType: startType)
        }

        let newSpinArray = await metropolis(spinConfig: mySpin.spinArray)
        await printSpin(spinConfig: newSpinArray)
        mySpin.spinArray = newSpinArray
    }
    
    /// initializeSpin
    /// Sets the initial spin array in either a "hot" or "cold" configuration and prints that starting configuration
    /// - Parameters:
    ///   - startType: the starting configuration for the spin array. value "hot" means we start with random spins. "cold" means the spins are ordered
    func initializeSpin(startType: String) async {
        switch(startType.lowercased()) {
        case "hot":
            await mySpin.hotStart(N: N)
            
        case "cold":
            await mySpin.coldStart(N: N)
            
        default:
            await mySpin.hotStart(N: N)
        }
        await printSpin(spinConfig: mySpin.spinArray) // Print the starting spin array
    }
    
    /// metropolis
    /// Function to run the 1D Metropolis algorithm
    /// - Parameters:
    ///   - spinConfig: the 1D spin configuration with positive values representing spin up and negative representing spin down
    /// - returns: the new spin configuration which is either the original configuration or a new one where one random spin is flipped
    func metropolis(spinConfig: [Double]) async -> [Double] {
        // var newSpinConfig: [Double] = []
        let spinToFlip = Int.random(in: 0..<spinConfig.count) // Pick a random particle
        var trialConfig = spinConfig
        trialConfig[spinToFlip] *= -1.0 // Flip the spin of the random particle
        
        // Get the energies of the configurations
        let trialEnergy = await getConfigEnergy(spinConfig: trialConfig)
        let prevEnergy = await getConfigEnergy(spinConfig: spinConfig)
        
        if (trialEnergy <= prevEnergy) {
            // Accept the trial
            return trialConfig
        }
        else {
            // Accept with relative probability R = exp(-ΔE/kB T)
            // let R = exp((-1.0*abs(trialEnergy - prevEnergy))/(kB * temp))
            let R = exp((-1.0*abs(trialEnergy - prevEnergy))) // kBT = 1 for debugging
            let r = Double.random(in: 0...1)
            // print("r is \(r) and R is \(R)")
            if (R >= r) { return trialConfig } // Accept the trial
            else { return spinConfig } // Reject the trial and keep the original spin config
        }
    }
    
    /// getConfigEnergy
    /// Gets the energy value of a spin configuration assuming that B = 0. Also applies Born-von Karman boundary conditions
    /// - Parameters:
    ///   - spinConfig: the 1D spin configuration with positive values representing spin up and negative representing spin down
    func getConfigEnergy(spinConfig: [Double]) async -> Double {
        //          /   |  --      |    \           --                     --
        // E    =  / a  |  \    V  | a   \  =  - J  \   s  * s     - B μ   \    s
        //   ak    \  k |  /__   i |  k  /          /__  i    i+1        b /__   i
        
        // But for simplicity, we assume B = 0 so the second term drops out
        // We also use Born-von Karman boundary conditions
        
        var energy = 0.0
        for i in 0..<spinConfig.count {
            if (i == (spinConfig.count-1)) {
                // Couple the last particle in the array to the first particle in it
                energy += -J * spinConfig[0] * spinConfig[i]
            }
            else {
                // Couple the current particle (index i) with the next one (index i+1)
                energy += -J * spinConfig[i] * spinConfig[i+1]
            }
        }
        return energy
    }
    
    /// printSpin
    /// Prints the current spin configuration with + representing a spin up particle and - representing a spin down particle
    /// - Parameters:
    ///   - spinConfig: the 1D spin configuration with positive values representing spin up and negative representing spin down
    func printSpin(spinConfig: [Double]) async {
        var spinString = ""
        for i in 0..<spinConfig.count {
            if (spinConfig[i] < 0) { spinString += "-" }
            else { spinString += "+" }
        }
        print(spinString)
    }
    
    /// setButton Enable
    /// Toggles the state of the Enable Button on the Main Thread
    /// - Parameter state: Boolean describing whether the button should be enabled.
    @MainActor func setButtonEnable(state: Bool) {
        if state {
            Task.init {
                await MainActor.run { self.enableButton = true }
            }
        }
        else{
            Task.init { await MainActor.run { self.enableButton = false }
            }
        }
    }
}
