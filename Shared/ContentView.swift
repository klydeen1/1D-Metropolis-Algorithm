//
//  ContentView.swift
//  Shared
//
//  Created by Katelyn Lydeen on 3/25/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var metropolisAlgorithm = OneDMetropolis()
    
    @State var NString = "20" // Number of particles
    @State var tempString = "100.0" // Temperature
    
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
                    
                    Button("Run 100 Times", action: {Task.init{await self.runMany()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                    
                    Button("Reset", action: {Task.init{await self.reset()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                }
            }
            
            /*
            .padding()
            //DrawingField
            drawingView(redLayer:$metropolisAlgorithm.spinUpData, blueLayer:$metropolisAlgorithm.spinDownData)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
            // Stop the window shrinking to zero.
            Spacer()
             */
            
        }
        // Stop the window shrinking to zero.
        Spacer()
        Divider()
    }
    
    func runOneDAlgorithm() async {
        await checkNChange()
        
        metropolisAlgorithm.setButtonEnable(state: false)
        
        metropolisAlgorithm.N = Int(NString)!
        metropolisAlgorithm.temp = Double(tempString)!
        await metropolisAlgorithm.runMetropolis(startType: selectedStart)
        
        metropolisAlgorithm.setButtonEnable(state: true)
    }
    
    func runMany() async{
        await checkNChange()
        
        metropolisAlgorithm.setButtonEnable(state: false)
        
        metropolisAlgorithm.temp = Double(tempString)!
        for _ in 0...100 {
            await metropolisAlgorithm.runMetropolis(startType: selectedStart)
        }
        
        metropolisAlgorithm.setButtonEnable(state: true)
    }
    
    func checkNChange() async {
        let prevN = metropolisAlgorithm.N
        metropolisAlgorithm.N = Int(NString)!
        if (prevN != metropolisAlgorithm.N) {
            await reset()
        }
    }
    
    func reset() async {
        metropolisAlgorithm.setButtonEnable(state: false)
        
        metropolisAlgorithm.mySpin.spinArray = []
        print("\nNew Config")
        
        metropolisAlgorithm.setButtonEnable(state: true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
