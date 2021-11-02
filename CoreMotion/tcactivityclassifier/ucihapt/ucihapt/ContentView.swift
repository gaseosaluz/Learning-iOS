//
//  ContentView.swift
//  ucihapt
//
//  Created by Ed Martinez on 10/26/21.
//

// MARK: References.
// CoreMotion Apple Documentation.  https://developer.apple.com/documentation/coremotion
// Getting RAW Gyroscope Events. https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events

// MARK: Deploying the CoreML model in a SwiftUI app.  Deploying an activity classification model in an iOS/watchOS app involves 3 basic steps:

// MARK: 1. Enabling the relevant sensors, and setting them to provide readings at the desired frequency.
// MARK: 2. Aggregating the readings from the sensors into a prediction_window long array.
// MARK: 3. When the array gets full - calling the model's prediction() method to get a predicted activity.

import SwiftUI
import CoreMotion
import CoreML


// MARK:- ML Model constants and Model Initialization

struct ModelConstants {
    static let predictionWindowSize = 50
    static let sensorsUpdateInterval = 1.0 / 50.0
    static let stateInLength = 400
}

var currentIndexInPredictionWindow = 0

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

// MARK: Initialize for CoreML model
// TODO: Fix Model 'init() warning per this discussion in Apple forums: https://developer.apple.com/forums/thread/671446 and https://www.hackingwithswift.com/forums/swiftui/betterrest-init-deprecated/2593
// THe next line is the old way of declaring and initializing the model
// let activityClassificationModel = UCIHAPTClassifier()

let activityClassificationModel: UCIHAPTClassifier = {
    do {
            let config = MLModelConfiguration()
            return try UCIHAPTClassifier(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create ML Model")
        }
}()

// MARK: - Initialize the CoreMontion Manager
let motionManager = CMMotionManager()

struct ContentView: View {
   
    @State private var activityName: String = "No Analysis Available"
    
    var body: some View {
        
        VStack(spacing: 20) {
            // MARK: Navigation View
            NavigationView {
                Text(self.activityName)
                    .font(.title)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            VStack {
                                Text("Activity Analyzer")
                                    .font(.largeTitle)
                                    .navigationBarTitleDisplayMode(.inline)
                            }
                        }
                    }
            }
            //
            //Text(self.activityName)
            //    .font(.largeTitle)
            
            HStack {
                // MARK: Button to start Activity Analysis
                Button("Start") {
                    print("Enabling CoreMotion")
                    // Before we do anything, make sure CoreMotion is available
                    guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable
                    else {
                        print("Core Motion is not Available")
                        return }
                    
                    // Initialize various CoreMotion constants
                    motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
                    motionManager.gyroUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
                    
                    // MARK: Start Accelerometer updates
                    print("Start Accelerometer Updates")
                    motionManager.startAccelerometerUpdates(to: .main) { accelerometerData,
                        error in
                        guard let accelerometerData = accelerometerData else { return }
                        
                        // Add Accelerometer data to analysis array
                        self.addAccelSampleToDataArray(accelSample: accelerometerData)
                        
                    } // End .startAccelerometerUpdates
                    
                    // MARK: Start Gyro updates
                    print("Start Gyroscope Updates")
                    motionManager.startGyroUpdates(to: .main) { gyroData,
                        error in
                        guard let gyroData = gyroData else { return }
                        
                        // Add GYro Data to analysis array
                        // self.addGyroSampleToDataArray(gyroSample: gyroData)
                    }
                    
                }
                .frame(width: 120)
                .padding(10)
                .background(Color.green)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .font(.system(size: 18, weight: .bold, design: .default))
                
                // MARK: Button to STOP activity analysis
                Button("Stop") {
                    print("Stopping Core Motion")
                    //motionManager.stopGyroUpdates()
                    //motionManager.stopAccelerometerUpdates()
                    
                }.frame(width: 120)
                    .padding(10)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .font(.system(size: 18, weight: .bold, design: .default))
                
            } // HStack
        }
    }
    // MARK: Funtion to gather Accelerometer readings from a sensor.  The data is added to the prediction_window long data array.  Once the array is full then we can call on the model to make a prediction

    func addAccelSampleToDataArray (accelSample: CMAccelerometerData) {
        print("Adding Acceleration to Data Array")
        // Add the current accelerometer reading to the data array
        accelDataX[[currentIndexInPredictionWindow] as [NSNumber]] = accelSample.acceleration.x as NSNumber
        accelDataY[[currentIndexInPredictionWindow] as [NSNumber]] = accelSample.acceleration.y as NSNumber
        accelDataZ[[currentIndexInPredictionWindow] as [NSNumber]] = accelSample.acceleration.z as NSNumber
        
        print("Accel X: \(accelSample.acceleration.x)")
        print("Accel Y: \(accelSample.acceleration.y)")
        print("Accel Z: \(accelSample.acceleration.z)")
        
        // Update the index in the prediction window data array
        currentIndexInPredictionWindow += 1
        
        // If the data array is full, call the prediction method to get a new model prediction.
        
        if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
            
            // TODO: Address warning below. This will be fixed once we use the "predictedActivity" value in the GUI to display what the user is doing.
            print("Accel: Got enough samples. Perform Prediction")
            
            //if let predictedActivity = performModelPrediction() {
            //    print(predictedActivity)
            // Use the predicted activity here
            // ...
            
            // Start a new prediction window
            //  currentIndexInPredictionWindow = 0
            //  } // End if let predictedActivity (Acceleration)
            
        }
    }
    // MARK: Function to add the gyro data
    func addGyroSampleToDataArray (gyroSample: CMGyroData) {
        // Add the current accelerometer reading to the data array
        
        gyroDataX[[currentIndexInPredictionWindow] as [NSNumber]] = gyroSample.rotationRate.x as NSNumber
        gyroDataY[[currentIndexInPredictionWindow] as [NSNumber]] = gyroSample.rotationRate.y as NSNumber
        gyroDataZ[[currentIndexInPredictionWindow] as [NSNumber]] = gyroSample.rotationRate.z as NSNumber
        
        print("Gyro X: \(gyroSample.rotationRate.x)")
        print("Gyro Y: \(gyroSample.rotationRate.y)")
        print("Gyro Y: \(gyroSample.rotationRate.z)")
        
        // Update the index in the prediction window data array
        currentIndexInPredictionWindow += 1
        
        // If the data array is full, call the prediction method to get a new model prediction.
        // We assume here for simplicity that the Gyro data was added to the data arrays as well.
        if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
            print("Gyro: Got enough samples. Perform Prediction")
            //if let predictedActivity = performModelPrediction() {
            //    print(predictedActivity)
            // Use the predicted activity here
            // ...
            
            // Start a new prediction window
            //    currentIndexInPredictionWindow = 0
            //} // end if let predictedActivity
        }
    }
}


// MARK: Perform Model prediction.  After the readings have been stored, we call the model to analyze and predict what the user is doing.

func performModelPrediction () -> String? {
    // Perform model prediction
    let modelPrediction = try! activityClassificationModel.prediction(acc_x: accelDataX, acc_y: accelDataY, acc_z: accelDataZ, gyro_x: gyroDataX, gyro_y: gyroDataY, gyro_z: gyroDataZ, stateIn: stateOutput)
    
    // Update the state vector
    stateOutput = modelPrediction.stateOut
    
    // Return the predicted activity - the activity with the highest probability
    return modelPrediction.activity
}

// MARK: Content previewer for Xcode

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
