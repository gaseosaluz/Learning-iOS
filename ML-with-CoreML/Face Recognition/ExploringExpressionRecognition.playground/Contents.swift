//: Playground - noun: a place where people can play

import UIKit
import Vision
import CoreML
import PlaygroundSupport

// Required to run tasks in the background
PlaygroundPage.current.needsIndefiniteExecution = true

// Required to run tasks in the background
PlaygroundPage.current.needsIndefiniteExecution = true
var images = [UIImage]()
for i in 1...3 {
    guard let image = UIImage(named:"images/joshua_newnham_\(i).jpg")
        else {
            fatalError("Failed to extract features")
    }
    images.append(image)
}

let faceIdx = 0
let imageView = UIImageView(image: images[faceIdx])
imageView.contentMode = .scaleAspectFit

// Set up the type of analysis
let faceDetectionRequest = VNDetectFaceRectanglesRequest()
// Handler to execute the request
let faceDetectionRequestHandler = VNSequenceRequestHandler()

try?faceDetectionRequestHandler.perform([faceDetectionRequest], on: images[faceIdx].cgImage!, orientation: CGImagePropertyOrientation(images[faceIdx].imageOrientation))

// Once the analysis is done we can look at the objservation
if let faceDetectionResults = faceDetectionRequest.results as? [VNFaceObservation]{
    for face in faceDetectionResults {
        if let currentImage = imageView.image {
            let bbox = face.boundingBox
            
            let imageSize = CGSize(width: currentImage.size.width, height: currentImage.size.height)
            
            let w = bbox.width * imageSize.width
            let h = bbox.height * imageSize.height
            let x = bbox.origin.x * imageSize.width
            let y = bbox.origin.y * imageSize.height
            
            let faceRect = CGRect(x: x, y: y, width: w, height: h)
            
            let invertedY = imageSize.height - (faceRect.origin.y + faceRect.height)
            
            let invertedFaceRect = CGRect(x: x, y: invertedY, width: w, height: h)
            
            imageView.drawRect(rect: invertedFaceRect)
            
        }
    }
}



