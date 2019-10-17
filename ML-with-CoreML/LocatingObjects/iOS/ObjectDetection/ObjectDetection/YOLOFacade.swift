//
//  YOLOFacade.swift
//  ObjectDetection
//

import UIKit
import Photos
import CoreML
import Vision

class YOLOFacade{
    
    // Input size (of image)
    var targetSize = CGSize(width: 416, height: 416)
    
    // Grid size
    let gridSize = CGSize(width: 13, height: 13)
    
    // Number of classes
    let numberOfClasses = 20
    
    // Number of anchor boxes
    let numberOfAnchorBoxes = 5
    
    // Anchor shapes (describing aspect ratio)
    let anchors : [Float] = [1.08, 1.19, 3.42, 4,41, 6.63, 11.38, 9.42, 5.11, 16.62, 10.52]
    
    // We will use the Vision Framework to work with the Model
    lazy var model : VNCoreMLModel = {
        do{
            // Get the model
            let model = try VNCoreMLModel(
                for: tinyyolo_voc2007().model)
            return model
        } catch{
            fatalError("Failed to obtain tinyyolo_voc2007")
        }
    }()
    
    // Entry point of the class and called by PhotoSearcher for each
    // image it receives from the Photo Framework
    
    func asyncDetectObjects(photo:UIImage, completionHandler: @escaping (_ result:[ObjectBounds]?) -> Void){
        DispatchQueue.global(qos: .background).sync {
            
            self.detectObjects(photo: photo, completionHandler: { (result) -> Void in
                DispatchQueue.main.async {
                    completionHandler(result)
                }
            })
        }
    }
    
}

// MARK: - Core ML
// functionality to perform inference
extension YOLOFacade{
    // This is responsible for performing inferernce via the tinyyolo_voc2007 call and
    // VNImageRequestHandler. Then it passes the model's output to the detectObjectBounds
    // method and finally transforms the normalized bounds to the dimentions of the
    // original image.
    
    func detectObjects(photo:UIImage, completionHandler:(_ result:[ObjectBounds]?) -> Void){
        guard let cgImage = photo.cgImage else{
            completionHandler(nil)
            return
        }
        
        // reprocess image and pass to model
        let request = VNCoreMLRequest(model: self.model)
        request.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform classification. \n\(error.localizedDescription)")
            completionHandler(nil)
            return
        }
        
        // Pass models results to detectObjectsBounds(::)
        
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation] else {
            completionHandler(nil)
            return
        }
        var detectedObjects = [ObjectBounds]()
        
        for observation in observations{
            guard let multiArray = observation.featureValue.multiArrayValue else{
                continue
            }
            
            if let observationDetectedObjects = self.detectObjectsBounds(array: multiArray) {
                for detectedOject in observationDetectedObjects.map({$0.transformFromCenteredCropping(from: photo.size, to: self.targetSize)}){
                    detectedObjects.append(detectedOject)
                }
            }
        
        }
        completionHandler(detectedObjects)
        
    }
    
    func detectObjectsBounds(array:MLMultiArray, objectThreshold:Float = 0.3) -> [ObjectBounds]?{
        
        // Interpret the models output
        // This method receives a MLMultiArray with shape of (125, 13, 13). The (13,13) is the
        // shape of the grid. The 125 represents the encoding of five blocks each containing the
        // bounding box, the probability of an object being present and the probabioity distribution
        // across 20 classes.
        let gridStride = array.strides[0].intValue
        let rowStride = array.strides[1].intValue
        let colStride = array.strides[2].intValue
        
        let arrayPointer = UnsafeMutablePointer<Double>(OpaquePointer(array.dataPointer))
        
        var objectBounds = [ObjectBounds]()
        var objectConfidences = [Float]()
        
        
        return nil
    }
}

// MARK: - Non-Max Suppression
// Implementing the Non-Max Supression algorithm
extension YOLOFacade{
    
    func filterDetectedObjects(objectsBounds:[ObjectBounds],
                                 objectsConfidence:[Float],
                                 nmsThreshold : Float = 0.3) -> [ObjectBounds]?{
        
        // If there are no bounding boxes do nothing
        guard objectsBounds.count > 0 else{
            return []
        }
        
        // TODO implement Non-Max Suppression
        
        return nil
    }
}
