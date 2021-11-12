//
//  ContentView.swift
//  CMuciharPlay
//
//  Created by Ed Martinez on 11/11/21.
//
// MARK: The model created for this program was created with the `tcHAPT` notebook in https://github.com/gaseosaluz/Learning-iOS/blob/master/CoreMotion/tcactivityclassifier/notebooks/tcHAPT.ipynb


//
import SwiftUI
import CoreML
import CoreMotion
import Foundation

// MARK:- Core ML Model constants
struct ModelConstants {
    //    static let numOfFeatures = 6
    // Must be the same size as used during training
    static let predictionWindowSize = 50    // (*)
    // Must be the same value as used during training
    static let sensorsUpdateInterval = 1.0 / 50.0   //(*)
    static let stateInLength = 400  //(*)
    //    static let hiddenInLenght = 20
    //    static let hiddenCellInLenght = 200
}

// MARK: - CoreMotion constants
var currentIndexInPredictionWindow = 0

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

//var currentState = try? MLMultiArray(
//    shape: [(ModelConstants.hiddenInLenght + ModelConstants.hiddenCellInLenght) as NSNumber],
//    dataType: MLMultiArrayDataType.double)

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



struct ContentView: View {
    
    @State private var activityName: String = "No Activity"
    @State private var coreMotionStatus: String = "Core Motion not available"
    
    let queue = OperationQueue()
    
    @State private var pitch = Double.zero
    @State private var yaw = Double.zero
    @State private var roll = Double.zero
    
    @State private var x = Double.zero
    @State private var y = Double.zero
    @State private var z = Double.zero
    
    // MARK: - Initialize the Core Motion Manager
    let motionManager = CMMotionManager()
    
    var body: some View {
        VStack {
            Text("UCI_P Activity \n Classifier")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .background(Color.green.opacity(0.2))
                .padding()
            Text("Activity: \(activityName)")
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
            // MARK: Accelerometer Data
            VStack{
                Text("Accelerometer Data")
                    .fontWeight(.bold)
                    .font(.subheadline)
                    .padding(5.0)
                
                Text("Accel-X: \(x)")
                Text("Accel-Y: \(y)")
                Text("Accel-Z: \(z)")
                
            } // End Accelerometer Vstack
            // Start displaying data as soon as GUI comes up
            .onAppear{
                print("Gyro and Accel Data")
                self.motionManager.startDeviceMotionUpdates(to: self.queue) { (data: CMDeviceMotion?, error: Error?) in
                    guard let data = data else {
                        print("Error: \(error!)")
                        return
                    }
                    let attitude: CMAttitude = data.attitude
                    
                    //                      print("Pitch: \(attitude.pitch)")
                    //                      print("Yaw: \(attitude.yaw)")
                    //                      print("Roll: \(attitude.roll)")
                    
                    let userAcceleration: CMAcceleration = data.userAcceleration
                    
                    //                      print("Accel X: \(userAcceleration.x)")
                    //                      print("Accel Y: \(userAcceleration.y)")
                    //                      print("Accel Z: \(userAcceleration.z)")
                    
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
            .padding()
            
            HStack {
                // MARK: - Start data collection
                Button("Start") {
                    print("Collectng data for Core ML")
                    // Make sure CoreMotion is available
                    guard motionManager.isAccelerometerAvailable, motionManager.isGyroAvailable
                    else {
                        print("Core Motion is not Available")
                        return }
                    // motionManager.startAccelerometerUpdates()
                    // motionManager.startGyroUpdates()
                    // motionManager.startDeviceMotionUpdates()
                    
                    motionManager.deviceMotionUpdateInterval = ModelConstants.sensorsUpdateInterval
                    motionManager.showsDeviceMovementDisplay = true
                    // Not sure if I should use a different queue than the one using for the
                    // raw Accel/Gyro display. For now  updating to .main queuue.
                    motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
                        guard let motionData = motionData else { return }
                        addMotionDataSampleToArray(motionSample: motionData)
                    }
                    
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
                    //stop
                    motionManager.stopGyroUpdates()
                    motionManager.stopAccelerometerUpdates()
                    motionManager.stopDeviceMotionUpdates()
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
    
    // MARK: - Core Motion Support Functions
    // MARK: Function to Stop the collection of Motion Data
    func stopDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            debugPrint("Core Motion Data Unavailable!")
            return
        }
        // Stop streaming device data
        motionManager.stopDeviceMotionUpdates()
        // Reset some parameters
        currentIndexInPredictionWindow = 0
        //        currentState = try? MLMultiArray(shape: [(20 + 200) as NSNumber], dataType: MLMultiArrayDataType.double)
        //      currentState = try? MLMultiArray(
        //          shape: [(ModelConstants.hiddenInLength +
        //                      ModelConstants.hiddenCellInLength) as NSNumber],
        //          dataType: MLMultiArrayDataType.double)
        
    }// end of stopDeviceMotion()
    // End of function to stop collection of Motion Data
    
    // MARK: Function to Start Collection of CM data to Array that will be used by the Core ML Model
    // Function to start collection of Motion Data
    func startDeviceMotion() {
        guard motionManager.isDeviceMotionAvailable else {
            debugPrint("Core Motion Data Unavailable!")
            return
        }
        motionManager.deviceMotionUpdateInterval = ModelConstants.sensorsUpdateInterval
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startDeviceMotionUpdates(to: .main) { (motionData, error) in
            guard let motionData = motionData else { return }
            // Add motion data sample to array
            addMotionDataSampleToArray(motionSample: motionData)
        }
    }
    
    // MARK: Function to add data to the Core ML analysis array
    func addMotionDataSampleToArray(motionSample: CMDeviceMotion) {
        // Using global queue for building prediction array
        //        DispatchQueue.global().async {
        gyroX[currentIndexInPredictionWindow] = motionSample.rotationRate.x as NSNumber
        gyroY[currentIndexInPredictionWindow] = motionSample.rotationRate.y as NSNumber
        gyroZ[currentIndexInPredictionWindow] = motionSample.rotationRate.z as NSNumber
        accX[currentIndexInPredictionWindow] = motionSample.userAcceleration.x as NSNumber
        accY[currentIndexInPredictionWindow] = motionSample.userAcceleration.y as NSNumber
        accZ[currentIndexInPredictionWindow] = motionSample.userAcceleration.z as NSNumber
        //        } // End DispatchQueue.global()
        
        // Update prediction Array Index
        currentIndexInPredictionWindow += 1
        //print("Sample Number: \(currentIndexInPredictionWindow)")
        
        // If data array is full - execute a prediction
        if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
            print("Got enough data - Make a prediction")
            // Move to main thread to update the UI
            if let predictedActivity = performModelPrediction() {
                activityName = predictedActivity
                print("Predicted Activity: \(predictedActivity)")
                // Start a new prediction window
                currentIndexInPredictionWindow = 0
            }
            // Start a new prediction window from scratch
            print("Start a new prediction window")
            
            // currentIndexInPredictionWindow = 0
        }
        
    } // End of func addMotionDataSampleToArray()
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
