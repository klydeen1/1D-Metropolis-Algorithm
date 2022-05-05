//
//  ContentView.swift
//  Shared
//
//  Created by Katelyn Lydeen on 3/25/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var metropolisAlgorithm = OneDMetropolis()
    @ObservedObject var drawingData = DrawingData(withData: true)
    
    @State var NString = "100" // Number of particles
    @State var tempString = "100.0" // Temperature
    @State var iterationsString = "1000" // Number of iterations for the simulation
    
    @State var selectedStart = "Cold"
    var startOptions = ["Cold", "Hot"]
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    VStack(alignment: .center) {
                        Text("Number of Particles N")
                            .font(.callout)
                            .bold()
                        TextField("# Number of Particles", text: $NString)
                            .padding()
                    }
                    
                    VStack(alignment: .center) {
                        Text("Temperature (K)")
                            .font(.callout)
                            .bold()
                        TextField("# Temperature (K)", text: $tempString)
                            .padding()
                    }
                    
                    VStack(alignment: .center) {
                        Text("Number of Iterations")
                            .font(.callout)
                            .bold()
                        TextField("# Number of Iterations", text: $iterationsString)
                            .padding()
                    }
                }
                
                VStack {
                    Text("Start Type")
                        .font(.callout)
                        .bold()
                    Picker("", selection: $selectedStart) {
                        ForEach(startOptions, id: \.self) {
                            Text($0)
                        }
                    }
                }
                
                HStack {
                    Button("Run Algorithm Once", action: {Task.init{await self.runOneDAlgorithm()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                    
                    Button("Run Simulation", action: {Task.init{await self.runMany()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                    
                    Button("Reset", action: {Task.init{self.reset()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                }
            }
            
            .padding()
            //DrawingField
            drawingView(redLayer: $drawingData.spinUpData, blueLayer: $drawingData.spinDownData, N: metropolisAlgorithm.N, n: metropolisAlgorithm.numIterations)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
            
        }
        // Stop the window shrinking to zero.
        Spacer()
        Divider()
    }
    
    func runOneDAlgorithm() async {
        checkParameterChange()
        
        metropolisAlgorithm.setButtonEnable(state: false)
        
        metropolisAlgorithm.printSpins = true
        await metropolisAlgorithm.iterateMetropolis(startType: selectedStart)
        
        metropolisAlgorithm.setButtonEnable(state: true)
    }
    
    @MainActor func runMany() async{
        checkParameterChange()
        self.reset()
        
        metropolisAlgorithm.setButtonEnable(state: false)
        
        metropolisAlgorithm.printSpins = false
        
        metropolisAlgorithm.numIterations = Int(iterationsString)!
        
        await metropolisAlgorithm.runSimulation(startType: selectedStart)
        drawingData.spinUpData = metropolisAlgorithm.newSpinUpPoints
        drawingData.spinDownData = metropolisAlgorithm.newSpinDownPoints
        
        metropolisAlgorithm.setButtonEnable(state: true)
    }
    
    func checkParameterChange() {
        let prevN = metropolisAlgorithm.N
        let prevT = metropolisAlgorithm.temp
        metropolisAlgorithm.N = Int(NString)!
        metropolisAlgorithm.temp = Double(tempString)!
        if (prevN != metropolisAlgorithm.N || prevT != metropolisAlgorithm.temp) {
            self.reset()
        }
    }
    
    @MainActor func reset() {
        metropolisAlgorithm.setButtonEnable(state: false)
        
        metropolisAlgorithm.mySpin.spinArray = []
        if(metropolisAlgorithm.printSpins) {
            print("\nNew Config")
        }
        
        drawingData.clearData()
        
        metropolisAlgorithm.setButtonEnable(state: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
