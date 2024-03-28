//
//  TestDragUI.swift
//  SwiftUIImageCropPicker
//
//  Created by sukumar.sukumaran on 25/03/2024.
//

import SwiftUI

struct TestDragUI: View {
    @State private var location: CGPoint = CGPoint(x: 50, y: 50) // 1
    @State private var fingerLocation: CGPoint? // 1
    
    var body: some View {
        ZStack { // 3
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.pink)
                .frame(width: 100, height: 100)
                .position(location)
                .gesture(
                    simpleDrag.simultaneously(with: fingerDrag) // 4
                )
            
            if let fingerLocation = fingerLocation { // 5
                Circle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: 44, height: 44)
                    .position(fingerLocation)
            }
        }
    }
    
    var simpleDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                self.location = value.location
            }
    }
    
    var fingerDrag: some Gesture { // 2
        DragGesture()
            .onChanged { value in
                self.fingerLocation = value.location
            }
            .onEnded { value in
                self.fingerLocation = nil
            }
    }
}

#Preview {
    TestDragUI()
}
