//
//  CoreMLSupport.swift
//  CMucihar
//
//  Created by Ed Martinez on 11/4/21.
//

import Foundation
import CoreML

func activityPrediction() -> String {
    // Perform the prediction
    let modelPrediction = try? activityClassificationModel.prediction(
        acc_x: accX,
        acc_y: accY,
        acc_z: accZ,
        gyro_x: gyroX,
        gyro_y: gyroY,
        gyro_z: gyroZ,
        stateIn: currentState!)
    
    // Update the state vector
    currentState = modelPrediction?.stateOut
    
    // Return the predicted activity
    return modelPrediction!.activity
}
