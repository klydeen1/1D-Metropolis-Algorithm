//
//  ContentView.swift
//  Shared
//
//  Created by Katelyn Lydeen on 3/25/22.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var metropolisAlgorithm = OneDMetropolis()
    
    @State var selectedStart = "Cold"
    var startOptions = ["Cold", "Hot"]
    
    var body: some View {
        HStack {
            VStack {
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
                    Button("Run Algorithm", action: {Task.init{await self.runOneDAlgorithm()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                    
                    Button("Reset", action: {Task.init{await self.reset()}})
                        .padding()
                        .disabled(metropolisAlgorithm.enableButton == false)
                }
            }
        }
    }
    
    func runOneDAlgorithm() async {
        await metropolisAlgorithm.runMetropolis(startType: selectedStart)
    }
    
    func reset() async {
        metropolisAlgorithm.mySpin.spinArray = []
        print("\nNew Config")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
