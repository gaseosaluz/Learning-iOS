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
    static let numOfFeatures = 6
    // Must be the same size as used during training
    static let predictionWindowSize = 50
    // Must be the same value as used during training
    static let sensorsUpdateInterval = 1.0 / 50.0
    static let stateInLength = 400
    static let hiddenInLenght = 20
    static let hiddenCellInLenght = 200
}


// MARK: The Core ML Classifier model expects MultiArrays, so create MLMultiArray variables to hold the sensor data that we are going to feed to the model

// MARK: - Accelerometer data
let accX = try! MLMultiArray(
    shape: [ModelConstants.predictionWindowSize] as [NSNumber],
    dataType: MLMultiArrayDataType.double)

let accY = try! MLMultiArray(
    shape: [ModelConstants.predictionWindowSize] as [NSNumber],
    dataType: MLMultiArrayDataType.double)

let accZ = try! MLMultiArray(
    shape: [ModelConstants.predictionWindowSize] as [NSNumber],
    dataType: MLMultiArrayDataType.double)

// MARK: - Gyroscope Data
let gyroX = try! MLMultiArray(
    shape: [ModelConstants.predictionWindowSize] as [NSNumber],
    dataType: MLMultiArrayDataType.double)

let gyroY = try! MLMultiArray(
    shape: [ModelConstants.predictionWindowSize] as [NSNumber],
    dataType: MLMultiArrayDataType.double)

let gyroZ = try! MLMultiArray(
    shape: [ModelConstants.predictionWindowSize] as [NSNumber],
    dataType: MLMultiArrayDataType.double)

var stateOutput = try! MLMultiArray(
    shape:[ModelConstants.stateInLength as NSNumber],
    dataType: MLMultiArrayDataType.double)

var currentState = try? MLMultiArray(
    shape: [(ModelConstants.hiddenInLenght + ModelConstants.hiddenCellInLenght) as NSNumber],
    dataType: MLMultiArrayDataType.double)

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

// MARK: - Initialize the Core Motion Manager
let motionManager = CMMotionManager()

// MARK: - CoreMotion constants
var currentIndexinPredictionWindow = 0


struct ContentView: View {
    @State private var activityName: String = "No Activity"
    @State private var coreMotionStatus: String = "Core Motion not available"

    let motionManager = CMMotionManager()
    let queue = OperationQueue()

    @State private var pitch = Double.zero
    @State private var yaw = Double.zero
    @State private var roll = Double.zero

    @State private var x = Double.zero
    @State private var y = Double.zero
    @State private var z = Double.zero

    
    var body: some View {
        
        VStack {
            Text("Activity Classifier")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // MARK: Gyro Data
            VStack{
                Text("Gyroscope Data")
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .padding(5.0)
                
                Text("Pitch: \(pitch)")
                Text("Yaw: \(yaw)")
                Text("Roll: \(roll)")
            } // End of Gyro Vstack
            .onAppear{
                
            }
            
            VStack{
                Text("Accelerometer Data")
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .padding(5.0)
                
                Text("Accel-X: \(x)")
                Text("Accel-Y: \(y)")
                Text("Accel-Z: \(z)")
                
            } // End Accelerometer Vstack
            .onAppear{
                print("Gyro and Accel Data")
                self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
                    guard let data = data else {
                        print("Error: \(error!)")
                        return
                    }
                    let attitude: CMAttitude = data.attitude

                    print("Pitch: \(attitude.pitch)")
                    print("Yaw: \(attitude.yaw)")
                    print("Roll: \(attitude.roll)")
                    
                    let userAcceleration: CMAcceleration = data.userAcceleration
                    
                    print("Accel X: \(userAcceleration.x)")
                    print("Accel Y: \(userAcceleration.y)")
                    print("Accel Z: \(userAcceleration.z)")

                    DispatchQueue.main.async {
                        self.pitch = attitude.pitch
                        self.yaw = attitude.yaw
                        self.roll = attitude.roll
                        
                        self.x = userAcceleration.x
                        self.y = userAcceleration.y
                        self.z = userAcceleration.z
                    }
                }
            } // End .onAppear()
            
            
            HStack {
                // MARK: - Start data collection
                Button("Start") {
                    print("Enabling Core Motion")
                    
                    // Make sure CoreMotion is available
                    guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable
                    else {
                        print("Core Motion is not Available")
                        return }
                    
                    // Initialize various CoreMotion constants
                    motionManager.accelerometerUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
                    motionManager.gyroUpdateInterval = TimeInterval(ModelConstants.sensorsUpdateInterval)
                    
                    // Start generating samples
                    motionManager.startAccelerometerUpdates()
                    motionManager.startGyroUpdates()
                    motionManager.startDeviceMotionUpdates()
                    
                    print("Start Collecting Accelerometer Updates")
                    motionManager.startAccelerometerUpdates(to: .main) { accelerometerData,
                        error in
                        guard let accelerometerData = accelerometerData else { return }
                        
                        // Add Accelerometer data to analysis array
                        print("Add Accel Data to Analysis Array")
                        //self.addAccelSampleToDataArray(accelSample: accelerometerData)
                        
                    } // End .startAccelerometerUpdates
                }
                .frame(width: 120)
                .padding(10)
                .background(Color.green)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .font(.system(size: 18, weight: .bold, design: .default))
            
                // MARK: - Stop data collection
                Button("Stop") {
                    print("Stopping Core Motion")
                    motionManager.stopGyroUpdates()
                    motionManager.stopAccelerometerUpdates()
                    motionManager.stopDeviceMotionUpdates()
                    stopDeviceMotion()
                }
                .frame(width: 120)
                .padding(10)
                .background(Color.red)
                .foregroundColor(Color.white)
                .cornerRadius(10)
                .font(.system(size: 18, weight: .bold, design: .default))
            }
        }
    }

}

#if ADD_DATA
// MARK: - Function to Add motion data to the Arrays
func addMotionDataSampleToArray(motionSample: CMDeviceMotion) {
    // Using global queue for building prediction array
    DispatchQueue.global().async {
        gyroX![self.currentIndexInPredictionWindow] = motionSample.rotationRate.x as NSNumber
        gyroY![currentIndexInPredictionWindow] = motionSample.rotationRate.y as NSNumber
        gyroZ![currentIndexInPredictionWindow] = motionSample.rotationRate.z as NSNumber
        self.accX![self.currentIndexInPredictionWindow] = motionSample.userAcceleration.x as NSNumber
        self.accY![self.currentIndexInPredictionWindow] = motionSample.userAcceleration.y as NSNumber
        self.accZ![self.currentIndexInPredictionWindow] = motionSample.userAcceleration.z as NSNumber
        
        // Update prediction array index
        self.currentIndexInPredictionWindow += 1
        
        // If data array is full - execute a prediction
        if (self.currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
            // Move to main thread to update the UI
            DispatchQueue.main.async {
                // Use the predicted activity
                self.label.text = self.activityPrediction() ?? "N/A"
            }
            // Start a new prediction window from scratch
            self.currentIndexInPredictionWindow = 0
        }
    }
}
#endif  // ADD_DATA



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

