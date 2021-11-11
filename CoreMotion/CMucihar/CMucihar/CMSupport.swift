//
//  CMSupport.swift
//  CMucihar
//
//  Created by Ed Martinez on 11/4/21.
//

import Foundation
import CoreMotion
import CoreML



// MARK: Function to stop Core Motion and data collection
func stopDeviceMotion () {
    guard motionManager.isDeviceMotionAvailable else {
        debugPrint("Core Motion Data Unvailable")
        return
    }
    // Stop streaming device data
    motionManager.stopDeviceMotionUpdates()
    
    // Reset collection parameters (for the next time)
    currentIndexinPredictionWindow = 0
    currentState = try? MLMultiArray (
        shape: [(ModelConstants.hiddenInLenght +
                 ModelConstants.hiddenCellInLenght) as NSNumber],
        dataType: MLMultiArrayDataType.double)
}

