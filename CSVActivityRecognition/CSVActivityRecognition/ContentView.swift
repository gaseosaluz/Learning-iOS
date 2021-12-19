//
//  ContentView.swift
//  CSVActivityRecognition
//
//  Created by Ed Martinez on 12/15/21.
//

import SwiftUI
import CodableCSV
import CoreML

// MARK: - CoreML model constants

struct ModelConstants {
    static let predictionWindowSize = 50
    static let sensorsUpdateInterval = 1.0 / 50.0
    static let stateInLength = 400
}

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

struct ContentView: View {
    
    @State private var document: CSVDocument = CSVDocument(message: "No CSV data yet")
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var analysisArrayFull: Bool = false
    
    //let csvData = [String]()
    
    var body: some View {
        
        VStack {
            GroupBox(label: Text("CSV File Contents:")) {
                TextEditor(text: $document.message)
            }
            GroupBox {
                HStack {
                    Button(action: { isImporting = true }, label: {
                        Text("Import")
                    })
                    
                }
            }
        }
        // MARK: File importer
        .fileImporter(
            isPresented: $isImporting,
            // .plainText
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                guard let csvData = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                
                document.message = csvData
                
                // MARK: Parse CSV data from file.  This collects the Gyro and Accelerometer data into the AccX, AccY, AccZ, GyroX, GyroY, GyroZ MultiArrayVariables (Declared at the top of this file
                
                // getGyroAccelfromCSV(csvData: csvData)
                addCSVMotionDataSampleToArray (csvData: csvData)
                
            } catch {
                // Handle error
                print("\(error)")
            }
            
        }
        // End File importer
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
