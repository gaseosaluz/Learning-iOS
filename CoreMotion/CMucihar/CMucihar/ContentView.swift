//
//  ContentView.swift
//  CMucihar
//
//  Created by Ed Martinez on 11/2/21.
//

// MARK: References.
// CoreMotion Apple Documentation.  https://developer.apple.com/documentation/coremotion
// Getting RAW Gyroscope Events. https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events

import SwiftUI
import CoreML
import CoreMotion

// MARK:- ML Model constants and Model Initialization

struct ModelConstants {
    static let predictionWindowSize = 50
    static let sensorsUpdateInterval = 1.0 / 50.0
    static let stateInLength = 400
}

// MARK: - CoreMotion constants
var currentIndexinPredictionWindow = 0

// MARK: The Core ML Classifier model expects MultiArrays, so create MLMultiArray variables to hold the sensor data that we are going to feed to the model

// MARK: - Accelerometer data
let accelDataX = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
let accelDataY = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
let accelDataZ = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)

// MARK: - Gyroscope Data
let gyroDataX = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
let gyroDataY = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)
let gyroDataZ = try! MLMultiArray(shape: [ModelConstants.predictionWindowSize] as [NSNumber], dataType: MLMultiArrayDataType.double)

var stateOutput = try! MLMultiArray(shape:[ModelConstants.stateInLength as NSNumber], dataType: MLMultiArrayDataType.double)

// MARK: - Intialize CoreML Model
let activityClassificationModel: UCIHAClassifier = {
    do {
            let config = MLModelConfiguration()
            return try UCIHAClassifier(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create ML Model")
        }
}()

// MARK: - Initialize the Motion Manager
let motionManager = CMMotionManager()

struct ContentView: View {
    @State private var activityName: String = "No Activity"
    
    var body: some View {
        
        VStack {
            HStack {
                Button("Start") {
                    print("Enabling Core Motion")
                }
                .frame(width: 120)
                .padding(10)
                .background(Color.green)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .font(.system(size: 18, weight: .bold, design: .default))
            
                Button("Start") {
                    print("Stopping Core Motion")
                }
                .frame(width: 120)
                .padding(10)
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .font(.system(size: 18, weight: .bold, design: .default))
            }

            Text("HCI Activity Classifier")
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

