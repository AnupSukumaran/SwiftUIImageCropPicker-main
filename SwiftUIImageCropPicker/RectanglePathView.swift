//
//  RectanglePathView.swift
//  Previews
//
//  Created by David Kemp on 24/03/2024.
//

import SwiftUI

struct RectanglePathView: View {
    @State private var location = CGPoint.zero
    @State private var position = CGPoint(x: 500, y: 100)
    @State private var frameX: CGFloat = 100
    @State private var frameY: CGFloat = 100
    
    @State private var startX: CGFloat = 500
    @State private var startY: CGFloat = 100
    @State private var newPosition: CGPoint = CGPoint(x: 500, y: 100)
    @State private var newFrame: CGSize = CGSize(width: 100, height: 100)
    @State private var originalPosition: CGPoint = CGPoint(x: 500, y: 100)
    @State private var lowerEdge: Bool = false
    @State private var circlePosition: CGPoint = CGPoint.zero
    @State private var translation: CGSize = CGSize.zero
    @State private var resizing: Bool = false
    
    
    var body: some View {
        ZStack {
            VStack {
                Text("StartLocation: x: \(self.startX), y: \(self.startY)")
                Text("Frame: x: \(self.frameX) y: \(self.frameY)")
                Text("New Frame: x: \(self.newFrame.width), y: \(self.newFrame.height)")
                Text("Position: x: \(self.position.x), y: \(self.position.y)")
                Text("Position Offset x: \(self.position.x - self.newPosition.x), y: \(self.position.y - self.newPosition.y)")
                Text("Translation: x: \(self.translation.width) y: \(self.translation.height)")
                Text("Resize Offset x: \(self.newFrame.width + -1 * (self.frameX)), y: \(self.newFrame.height + -1 * (self.frameY))")
                
                Spacer()
            }
            VStack {
                Rectangle()
                    .opacity(0.25)
                    .foregroundStyle(.red)
                    .border(.red)
                    .frame(width: self.frameX, height: self.frameY)
                Text("Location: \(Int(location.x)), \(Int(location.y))")
            }
            .gesture(drag)
            .position(self.position)
            .coordinateSpace(name: "stack")
            Circle()
                .foregroundStyle(.black)
                .frame(width: 20, height: 20)
                .position(self.circlePosition)
            Rectangle()
                .foregroundStyle(.blue)
                .frame(width: 1, height: self.frameY + 10)
                .position(CGPoint(x: self.newPosition.x - self.frameX * (1/4) , y: self.newPosition.y))
            Rectangle()
                .foregroundStyle(.green)
                .frame(width: self.frameX + 10, height: 1)
                .position(CGPoint(x: self.newPosition.x, y: self.newPosition.y + self.frameY * (1/4)))
        }
    }
    
    var drag: some Gesture {
        DragGesture(coordinateSpace: .named("stack"))
            .onChanged { info in
                self.startX = info.startLocation.x
                self.startY = info.startLocation.y
                if info.startLocation.x > self.newPosition.x - (self.frameX / 2) + 20 && info.startLocation.x < self.newPosition.x + (self.frameX / 2) - 20 && info.startLocation.y < self.newPosition.y + (self.frameY / 2) - 20 &&
                    info.startLocation.y > self.newPosition.y - (self.frameY / 2) + 20 && !self.resizing {
                    self.position = info.location
                } else if info.startLocation.x <= self.newPosition.x - (self.newFrame.width / 2) + 20 && info.startLocation.y >= self.newPosition.y + (self.newFrame.height / 2) - 20 { // Bottom left
                    self.resizing = true
                    self.frameX = max(self.newFrame.width + -1 * (info.translation.width), 5)
                    self.frameY = max(self.newFrame.height + (info.translation.height), 5)
                    self.position.x = self.originalPosition.x + (self.newFrame.width + -1 * (self.frameX)) / 2
                    self.position.y = self.originalPosition.y - (self.newFrame.height + -1 * self.frameY) / 2
                } else if info.startLocation.x <= self.newPosition.x - ((self.newFrame.width / 4)) && info.startLocation.y <= self.newPosition.y - (self.newFrame.height / 4) { // top left
                    self.resizing = true
                    self.frameX = max(self.newFrame.width + -1 * (info.translation.width), 5)
                    self.frameY = max(self.newFrame.height + -1 * (info.translation.height), 5)
                    self.position.x = self.originalPosition.x + (self.newFrame.width + -1 * (self.frameX)) / 2
                    self.position.y = self.originalPosition.y + (self.newFrame.height + -1 * self.frameY) / 2
                } else if info.startLocation.x >= self.newPosition.x + ((self.newFrame.width / 4)) && info.startLocation.y <= self.newPosition.y - (self.newFrame.height / 4) { // top right
                    self.resizing = true
                    self.frameX = max(self.newFrame.width + (info.translation.width), 5)
                    self.frameY = max(self.newFrame.height + -1 * (info.translation.height), 5)
                    self.position.x = self.originalPosition.x - (self.newFrame.width + -1 * (self.frameX)) / 2
                    self.position.y = self.originalPosition.y + (self.newFrame.height + -1 * self.frameY) / 2
                } else if info.startLocation.x >= self.newPosition.x + ((self.newFrame.width / 4)) && info.startLocation.y >= self.newPosition.y + (self.newFrame.height / 4) { // bottom right
                    self.resizing = true
                    self.frameX = max(self.newFrame.width + (info.translation.width), 5)
                    self.frameY = max(self.newFrame.height + (info.translation.height), 5)
                    self.position.x = self.originalPosition.x - (self.newFrame.width + -1 * (self.frameX)) / 2
                    self.position.y = self.originalPosition.y - (self.newFrame.height + -1 * self.frameY) / 2
                } else {
                    self.resizing = false
                }
                self.circlePosition = CGPoint(x: self.position.x - ((self.frameX / 2) - 10), y: self.position.y + (self.frameY / 2) - 20)
                self.translation = info.translation
                location = self.position
            }
            .onEnded { info in
                self.resizing = false
                self.newPosition = self.position
                self.originalPosition = self.position
                self.newFrame = CGSize(width: self.frameX, height: self.frameY)
            }
    }
}

#Preview {
    RectanglePathView()
}
