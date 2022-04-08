//
//  DrawingView.swift
//  1D-Metropolis-Algorithm
//
//  Created by Katelyn Lydeen on 2/10/22.
//

import SwiftUI

struct drawingView: View {
    @Binding var redLayer : [(xPoint: Double, yPoint: Double)]
    @Binding var blueLayer : [(xPoint: Double, yPoint: Double)]
    
    var N: Int
    
    var body: some View {
        ZStack{
            drawSpins(drawingPoints: redLayer, numParticles: N)
                .stroke(Color.red)
            
            drawSpins(drawingPoints: blueLayer, numParticles: N)
                .stroke(Color.blue)
        }
        .background(Color.white)
        .aspectRatio(1, contentMode: .fill)
    }
}

struct DrawingView_Previews: PreviewProvider {
    @State static var redLayer : [(xPoint: Double, yPoint: Double)] = [(-0.5, 0.5), (0.5, 0.5), (0.0, 0.0), (0.0, 1.0)]
    @State static var blueLayer : [(xPoint: Double, yPoint: Double)] = [(-0.5, -0.5), (0.5, -0.5), (0.9, 0.0)]
    @State static var numParticles = 3
    
    static var previews: some View {
        drawingView(redLayer: $redLayer, blueLayer: $blueLayer, N: numParticles)
            .aspectRatio(1, contentMode: .fill)
            //.drawingGroup()
    }
}

struct drawSpins: Shape {
    let smoothness : CGFloat = 1.0
    var drawingPoints: [(xPoint: Double, yPoint: Double)]
    var numParticles: Int
    
    func path(in rect: CGRect) -> Path {
        
        // draw from the center of our rectangle
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let scale = rect.width

        // Create the Path for the display
        var path = Path()
        
        for item in drawingPoints {
            let xCoord = item.xPoint/(1000)*Double(scale)
            let yCoord = item.yPoint/Double(numParticles - 1)*Double(-scale) + 2.0*Double(center.y)
            path.addRect(CGRect(x: xCoord, y: yCoord, width: 1.0, height: 1.0))
        }
        return (path)
    }
}
