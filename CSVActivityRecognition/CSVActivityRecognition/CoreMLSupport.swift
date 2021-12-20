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
    
    let modelPrediction = try! activityClassificationModel.prediction(acc_x: accX, acc_y: accY, acc_z: accZ, gyro_x: gyroX, gyro_y: gyroY, gyro_z: gyroZ, stateIn: stateOutput)

    // Update the state vector
    stateOutput = modelPrediction.stateOut

    // Return the predicted activity - the activity with the highest probability
    return modelPrediction.activity
}
