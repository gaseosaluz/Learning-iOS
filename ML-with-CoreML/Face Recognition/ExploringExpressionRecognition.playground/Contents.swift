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
    guard let image = UIImage(named:"images/joshua_newman_\(i).jpg")
        else {
            fatalError("Failed to extract features")
    }
    images.append(image)
}

let faceIdx = 0
let imageView = UIImageView(image: images[faceIdx])
imageView.contentMode = .scaleAspectFit
print("images/joshua_newman_1.jpg")


