//
//  ImageCropView.swift
//  SwiftUIImageCropPicker
//
//  Created by Takenori Kabeya on 2023/02/06.
//

import SwiftUI


struct ImageCropView: View {
    @Binding var sourceImage: UIImage?
    @Binding var croppedImage: UIImage?
    @State var paddingTop: CGFloat = 0
    @State var paddingLeft: CGFloat = 0
    @State var paddingBottom: CGFloat = 0
    @State var paddingRight: CGFloat = 0
    
    @State var cropTop: CGFloat = 0
    @State var cropLeft: CGFloat = 0
    @State var cropBottom: CGFloat = 0
    @State var cropRight: CGFloat = 0
    @State var scaledRectWidth: CGFloat = 0
    @State var scaledRectHeight: CGFloat = 0
    var coordinator: ImageCropPicker.Coordinator
    
    @State var newTopBlockArea: CGFloat = 0
    @State var newBottomBlockArea: CGFloat = 0
    @State var newLeftBlockArea: CGFloat = 0
    @State var newRightBlockArea: CGFloat = 0
    
    @State var topBlockArea: CGFloat = 0
    @State var bottomBlockArea: CGFloat = 0
    @State var leftBlockArea: CGFloat = 0
    @State var rightBlockArea: CGFloat = 0
    
    @State var percentCovered: CGFloat = 0
//    @State private var position = CGPoint(x: 500, y: 100)
    let gripCircleSize: CGFloat = 16
    let screenSizeToImageSizeRatio: CGFloat = 0.7
    
    @State var activeOffset: CGSize = CGSize(width: 0, height: 0)
    @State var finalOffset: CGSize = CGSize(width: 0, height: 0)
    var surroundingColor = Color.black.opacity(0.45)
    
    
    @State private var location: CGPoint = CGPoint(x: 0, y: 0) // 1
    
    let imageHeight: CGFloat = 19.666667
    let imageWidth: CGFloat = 29
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                if let image = self.sourceImage {
//                    Image(uiImage: image)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .scaledToFit()
//                        .frame(width: image.size.width < image.size.height ?
//                               
//                               geometry.size.height * screenSizeToImageSizeRatio / image.size.height * image.size.width :
//                                
//                                geometry.size.width * screenSizeToImageSizeRatio
//                               
//                               ,
//                               height: image.size.width < image.size.height ?
//                               geometry.size.height * screenSizeToImageSizeRatio :
//                                geometry.size.width * screenSizeToImageSizeRatio / image.size.width * image.size.height)
//                        .clipShape(Rectangle())
                    Color.black
                        .frame(width: geometry.size.width * screenSizeToImageSizeRatio , height: geometry.size.width * (screenSizeToImageSizeRatio / imageWidth) * imageHeight)
                        .overlay(cropOperator)
                    Text("image.size.height = \(image.size.height)")
                    Text("image.size.width = \(image.size.width)")
//                        .onAppear {
//                            let width = geometry.size.width
////                            ?
////                            geometry.size.height * screenSizeToImageSizeRatio / image.size.height * image.size.width :
////                             geometry.size.width * screenSizeToImageSizeRatio
////                            
//                            let height = geometry.size.height
////                            ?
////                            geometry.size.height * screenSizeToImageSizeRatio :
////                             geometry.size.width * screenSizeToImageSizeRatio / image.size.width * image.size.height
//                            
//                            debugPrint("<ttt> width = \(width)")
//                            debugPrint("<ttt> height = \(height)")
//                        }
                }
                Spacer()
                HStack {
                    Button(role:.cancel, action: {
                        self.croppedImage = nil
                        if let vc = self.coordinator.cropViewHostingController {
                            vc.dismiss(animated: false)
                        }
                    }, label: { Text("Cancel") })
                        .padding(20)
                    Spacer()
                    Button("Choose", action: {
                        cropImage()
//                        if let vc = self.coordinator.cropViewHostingController {
//                            vc.dismiss(animated: false)
//                            self.coordinator.parent.originalImage = self.croppedImage
//                        }
                    })
                        .padding(20)
                }
            }
        }
    }
    
    func cropImage() {
        guard let uiImage = self.sourceImage else {
            return
        }
        guard let cgImage = uiImage.cgImage else {
            return
        }
        let xScale = uiImage.size.width / scaledRectWidth
        let yScale = uiImage.size.height / scaledRectHeight
        let newWidth = xScale * (scaledRectWidth - paddingLeft - paddingRight)
        let newHeight = yScale * (scaledRectHeight - paddingTop - paddingBottom)
        let croppedRect = CGRect(x: paddingLeft * xScale, y: paddingTop * yScale, width: newWidth, height: newHeight)
        debugPrint("<cord> croppedRect.minY = \(croppedRect.minY)")
        debugPrint("<cord> croppedRect.minX = \(croppedRect.minX)")
        debugPrint("<cord> croppedRect.maxY = \(croppedRect.maxY)")
        debugPrint("<cord> croppedRect.maxX = \(croppedRect.maxX)")
        guard let croppedImage = cgImage.cropping(to: croppedRect) else {
            return
        }
        self.croppedImage = UIImage(cgImage: croppedImage)
    }
    
    var cropOperator: some View {
        GeometryReader { geometry in
            let scaledRectWidth = geometry.size.width
            let scaledRectHeight = geometry.size.height
            
            VStack {
                ZStack {
                    
                    // gray area outside of cropped area
                    ZStack {
                        Group {
                            ///top
                            Rectangle()
                                .foregroundColor(Color.red.opacity(0.3))
                                .foregroundColor(surroundingColor)
                                .offset(x:0, y:-scaledRectHeight / 2 + paddingTop / 2)
                                .frame(height: paddingTop < 0 ? 0 : paddingTop)
                            
                            ///bottom
                            Rectangle()
                                .foregroundColor(Color.blue.opacity(0.3))
                                .foregroundColor(surroundingColor)
                                .offset(x:0, y:scaledRectHeight / 2 - paddingBottom / 2)
                                .frame(height: paddingBottom < 0 ? 0 : paddingBottom)
                            
                            ///left
                            Rectangle()
                                .foregroundColor(Color.yellow.opacity(0.3))
                                .foregroundColor(surroundingColor)
                                .offset(x:-scaledRectWidth / 2 + paddingLeft / 2, y: (paddingTop - paddingBottom) / 2)
                                .frame(width: paddingLeft < 0 ? 0 : paddingLeft,
                                       height: scaledRectHeight - paddingTop - paddingBottom < 0 ? 0 : scaledRectHeight - paddingTop - paddingBottom)
                            
                            ///green
                            Rectangle()
                                .foregroundColor(Color.green.opacity(0.3))
                                .foregroundColor(surroundingColor)
                                .offset(x:scaledRectWidth / 2 - paddingRight / 2, y: (paddingTop - paddingBottom) / 2)
                                .frame(width: paddingRight < 0 ? 0 : paddingRight,
                                       height: scaledRectHeight - paddingTop - paddingBottom < 0 ? 0 : scaledRectHeight - paddingTop - paddingBottom)
                        }
                        
//                        .foregroundColor(.gray)
//                        .opacity(0.4)
                    }
                    
//                    Rectangle() // square to fit image size
//                        .stroke(Color(red: 0.8, green: 0.8, blue: 0.8), lineWidth: 2)
//                        .padding(EdgeInsets(top: paddingTop, leading: paddingLeft, bottom: paddingBottom, trailing: paddingRight))
                    Rectangle() // square to cover all grip circles
                        .foregroundColor(Color.black.opacity(0.3))
                        .foregroundColor(surroundingColor)
                    //   .position(location) // 2
                        //.offset(x: activeOffset.width, y: activeOffset.height)
                        .opacity(0.5)    // when set opacity=0, drag handler will be ignored. so use small value for it.
                        .padding(EdgeInsets(top: paddingTop - gripCircleSize/2,
                                            leading: paddingLeft - gripCircleSize/2,
                                            bottom: paddingBottom - gripCircleSize/2,
                                            trailing: paddingRight - gripCircleSize/2))
                        
                        .gesture(drag2)
                    
                    
                    // grip circles
                    ZStack {
                        //top-left
                        gripCircle.offset(x: paddingLeft - scaledRectWidth / 2, y: paddingTop - scaledRectHeight / 2)
                        //bottom-left
                        gripCircle.offset(x: paddingLeft - scaledRectWidth / 2, y: -paddingBottom + scaledRectHeight / 2)
                        //top-right
                        gripCircle.offset(x: -paddingRight + scaledRectWidth / 2, y: paddingTop - scaledRectHeight / 2)
                        //bottom-right
                        gripCircle.offset(x: -paddingRight + scaledRectWidth  / 2, y: -paddingBottom + scaledRectHeight / 2)
                        //center-left
                        gripCircle.offset(x: paddingLeft - scaledRectWidth / 2, y: (paddingTop - paddingBottom) / 2)
                        //center-right
                        gripCircle.offset(x: -paddingRight + scaledRectWidth / 2, y: (paddingTop - paddingBottom) / 2)
                        //top-center
                        gripCircle.offset(x: (paddingLeft - paddingRight) / 2, y: paddingTop - scaledRectHeight / 2)
                        //bottom-center
                        gripCircle.offset(x: (paddingLeft - paddingRight) / 2, y: -paddingBottom + scaledRectHeight / 2)
                    }
                }
            }
            .onAppear {
                if self.scaledRectWidth != scaledRectWidth {
                    self.scaledRectWidth = scaledRectWidth
                }
                if self.scaledRectHeight != scaledRectHeight {
                    self.scaledRectHeight = scaledRectHeight
                }
            }
        }
    }
    
    var coverFrame: some View {
        Rectangle()
            .foregroundColor(.gray)
            .opacity(0.4)
    }
    
    var gripCircle: some View {
        Circle()
            .frame(width: gripCircleSize, height: gripCircleSize)
            .foregroundColor(.gray)
            .opacity(0.5)
    }
    
    var drag: some Gesture {
        return DragGesture()
            .onChanged { gestureValue in
                if let vc = self.coordinator.cropViewHostingController {
                    vc.isModalInPresentation = true
                }
                if (abs(gestureValue.startLocation.x - self.cropLeft) < gripCircleSize) {
                    self.paddingLeft = cropLeft + gestureValue.translation.width
                }
                else if (abs(gestureValue.startLocation.x - (self.scaledRectWidth - self.cropRight)) < gripCircleSize) {
                    self.paddingRight = cropRight - gestureValue.translation.width
                }
                if (abs(gestureValue.startLocation.y - self.cropTop) < gripCircleSize) {
                    self.paddingTop = cropTop + gestureValue.translation.height
                }
                if (abs(gestureValue.startLocation.y - (self.scaledRectHeight - self.cropBottom)) < gripCircleSize) {
                    self.paddingBottom = cropBottom - gestureValue.translation.height
                }
            }
            .onEnded { gestureValue in
                self.cropLeft = self.paddingLeft
                self.cropTop = self.paddingTop
                self.cropRight = self.paddingRight
                self.cropBottom = self.paddingBottom
            }
    }
    
    var drag2: some Gesture {
        return DragGesture()
            .onChanged { gestureValue in

                let cropX1 = gestureValue.startLocation.x - self.cropLeft
               
                let cropX2 = gestureValue.startLocation.x - (self.scaledRectWidth - self.cropRight)
                
                let cropY1 = gestureValue.startLocation.y - self.cropTop
                
                let cropY2 = gestureValue.startLocation.y - (self.scaledRectHeight - self.cropBottom)
                
                
                topBlockArea = newTopBlockArea
                bottomBlockArea = newBottomBlockArea
                leftBlockArea = newLeftBlockArea
                rightBlockArea = newRightBlockArea
                let baseArea = scaledRectHeight * scaledRectWidth
                
                if (abs(cropX1) < gripCircleSize) {
                    
                    let leftPadding = cropLeft + gestureValue.translation.width
                    
                    let totalWidthCovered = leftPadding + paddingRight
//                    let topPadding = cropTop + gestureValue.translation.height
//                    let bottomPadding = cropBottom - gestureValue.translation.height
//                    let leftBlockHeight = (scaledRectHeight - (topPadding + bottomPadding))
                    
//                    leftBlockArea = leftPadding * leftBlockHeight
//                    debugPrint("leftBlockArea = \(leftBlockArea)")
                    
                    let percent = (totalWidthCovered / scaledRectWidth)
                    debugPrint("percent_1 = \(percent)")
                    if percent < 0.6 {
                        self.paddingLeft = max(leftPadding, 0)
                        debugPrint("Hit - 4")
                    }
                  
                    
                }
                
                else if (abs(cropX2) < gripCircleSize) {
                    debugPrint("<jkg> Hit 2")
                    let rightPadding = cropRight - gestureValue.translation.width
                    
                    let totalWidthCovered = rightPadding + paddingLeft
                    
//                    let topPadding = cropTop + gestureValue.translation.height
//                    let bottomPadding = cropBottom - gestureValue.translation.height
//                    let rightBlockHeight = (scaledRectHeight - (topPadding + bottomPadding))
//                    
//                    rightBlockArea = rightPadding * rightBlockHeight
                    
                    let percent = (totalWidthCovered / scaledRectWidth)
                    debugPrint("percent_2 = \(percent)")
                    if percent < 0.6 {
                        self.paddingRight = max(rightPadding, 0)
                        debugPrint("Hit - 5")
                    }
                   
                  //  self.paddingRight = max(rightPadding, 0)
                    
                //    self.paddingRight = percent < 0.8 ? max(rightPadding, 0) : paddingRight
                   
                    
                }
                
                
            //    if gestureValue.startLocation.y  > 50 {
                 if (abs(cropY1) < gripCircleSize) {
                    debugPrint("<jkg> Hit 3")
                    let topPadding = cropTop + gestureValue.translation.height
                     
                     let totalHeightCovered = topPadding + paddingBottom
                     
                  //   topBlockArea = topPadding * scaledRectWidth
                    
                    //let percent = (topPadding / scaledRectHeight)
                    let percent = (totalHeightCovered / scaledRectHeight)
                    debugPrint("percent_3 = \(percent)")
                    if percent < 0.6 {
                        self.paddingTop = max(topPadding, 0)
                        debugPrint("Hit - 6")
                    }
                     
                
                     
                     
                    
                    
                }
                
                 else if (abs(cropY2) < gripCircleSize) {
                    debugPrint("<jkg> Hit 4")
                    let bottomPadding = cropBottom - gestureValue.translation.height
                     
                    // bottomBlockArea = bottomPadding * scaledRectWidth
                     
                     let totalHeightCovered = bottomPadding + paddingTop
                    
                    let percent = (totalHeightCovered / scaledRectHeight)
                    debugPrint("percent_4 = \(percent)")
                     
                     
                    if percent < 0.6 {
                        self.paddingBottom = max(bottomPadding, 0)
                        debugPrint("Hit - 7")
                    }
                    
                     
                    
                } 
                
                if  (abs(cropX1) > gripCircleSize) && (abs(cropX2) > gripCircleSize) && (abs(cropY1) > gripCircleSize) && (abs(cropY2) > gripCircleSize) {
                    
                    debugPrint("Hit - 1")
                    let topPadding = cropTop + gestureValue.translation.height
                    let leftPadding = cropLeft + gestureValue.translation.width
                    let rightPadding = cropRight - gestureValue.translation.width
                    let bottomPadding = cropBottom - gestureValue.translation.height
                    
                    debugPrint("<jkg> topPadding = \(topPadding)")
//                    let topPercent = (topPadding / scaledRectHeight)
//                    let leftPercent = (leftPadding / scaledRectWidth)
//                    let rightPercent = (rightPadding / scaledRectWidth)
//                    let bottomPercent = (bottomPadding / scaledRectHeight)
//                    debugPrint("percent = \(bottomPercent)")
//                    if topPercent < 0.6 {
//                        self.paddingTop = max(topPadding, 0)
//                    }
//                    if leftPercent < 0.6 {
//                        self.paddingLeft = max(leftPadding, 0)
//                    }
//                    if bottomPercent < 0.6 {
//                        self.paddingBottom = max(bottomPadding, 0)
//                    }
//                    if rightPercent < 0.6 {
//                        self.paddingRight = max(rightPadding, 0)
//                    }
//                    if topPadding >= 0, leftPadding >= 0, rightPadding >= 0, bottomPadding >= 0 {
//                        self.paddingTop = max(topPadding, 0)
//                        self.paddingLeft = max(leftPadding, 0)
//                        self.paddingRight = max(rightPadding, 0)
//                        self.paddingBottom = max(bottomPadding, 0)
//
//                    }
//
//                    if topPadding >= 0, leftPadding >= 0, rightPadding >= 0, bottomPadding >= 0 {
//                        self.paddingTop = max(topPadding, 0)
//                        self.paddingLeft = max(leftPadding, 0)
//                        self.paddingRight = max(rightPadding, 0)
//                        self.paddingBottom = max(bottomPadding, 0)
//
//                    }
                    
                    if topPadding > 0,  bottomPadding > 0 {
                        debugPrint("Hit - 2")
                        self.paddingTop = max(topPadding, 0)
                       
                        self.paddingBottom = max(bottomPadding, 0)
                        
                    }
                    
                    if leftPadding >= 0, rightPadding >= 0 {
                        debugPrint("Hit - 3")
                        self.paddingLeft = max(leftPadding, 0)
                        self.paddingRight = max(rightPadding, 0)
                      
                        
                    }
                    
//                    self.paddingTop = max(topPadding, 0)
//                    self.paddingBottom = max(bottomPadding, 0)
//                    self.paddingLeft = max(leftPadding, 0)
//                    self.paddingRight = max(rightPadding, 0)

                    
                }
                

                
                debugPrint("<xyj> self.paddingLeft = \(self.paddingLeft))")
                debugPrint("gestureValue.startLocation.x = \(gestureValue.startLocation.x)")
                debugPrint("<jkg> self.cropLeft = \(self.cropLeft))")
                
                debugPrint("<xyj> gestureValue.translation.width = \(gestureValue.translation.width))")
                
               // let workingOffset = CGSize(width: finalOffset.width + gestureValue.translation.width , height: finalOffset.height + gestureValue.translation.height)
                //debugPrint("workingOffset.width = \(gestureValue.translation.width)")
//activeOffset.width = gestureValue.translation.width
                
                let totalArea = topBlockArea + bottomBlockArea + leftBlockArea + rightBlockArea
                
                
                percentCovered = totalArea / baseArea
                
                print("percentCovered = \(percentCovered)")
                
            }
            .onEnded { gestureValue in
                self.cropLeft = self.paddingLeft
                self.cropTop = self.paddingTop
                self.cropRight = self.paddingRight
                self.cropBottom = self.paddingBottom
                
                
                newTopBlockArea = topBlockArea
                newBottomBlockArea = bottomBlockArea
                newLeftBlockArea = leftBlockArea
                newRightBlockArea = rightBlockArea
                
              //  finalOffset = activeOffset
            }
    }
    
//    func calculateAreaPercentCovered() -> CGFloat {
//        
//    }
}

struct CNWImageCropView_Previews: PreviewProvider {
    @State static var image: UIImage? = UIImage(systemName:"scissors.badge.ellipsis")
    @State static var croppedImage: UIImage? = nil
    static var previews: some View {
        ImageCropView(sourceImage: $image,
                    croppedImage: $croppedImage,
                        coordinator: ImageCropPicker.Coordinator(ImageCropPicker(originalImage: $image, croppedImage: $croppedImage)))
    }
}
