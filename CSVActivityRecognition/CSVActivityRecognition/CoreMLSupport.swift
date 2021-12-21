//
//  CoreMLSupport.swift
//  CSVActivityRecognition
//
//  Created by Ed Martinez on 12/15/21.
//

import Foundation
import CoreML
import CodableCSV

// MARK: - Add data to the CoreML analysis array

func performModelPrediction () -> String? {
    // Perform model prediction
    
    let modelPrediction = try! activityClassificationModel.prediction(acceleration_x: accX, acceleration_y: accY, acceleration_z: accZ, rotation_x: gyroX, rotation_y: gyroY, rotation_z: gyroZ, stateIn: stateOutput)

    // Update the state vector
    stateOutput = modelPrediction.stateOut

    // Return the predicted activity - the activity with the highest probability
    return modelPrediction.label
}
