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
                
                // MARK: Parse CSV data from file
                parseCSVFile(csvData: csvData)
                
            } catch {
                // Handle error
                print("\(error)")
            }
            
        }
        // End File importer
    }
}

func parseCSVFile (csvData: String ) {
    
    do {
        
        let parsedCSV = try CSVReader(input: csvData) { $0.headerStrategy = .firstLine }
        
        let headers = parsedCSV.headers
        
        print("Parsed CSV File")
        print(headers)
        
        // let record = try parsedCSV.readRecord()
        
        var currentIndexInPredictionWindow = 0
        
        for row in parsedCSV {
            gyroX[currentIndexInPredictionWindow] = Double(row[0])! as NSNumber
            gyroY[currentIndexInPredictionWindow] = Double(row[1])! as NSNumber
            gyroZ[currentIndexInPredictionWindow] = Double(row[2])! as NSNumber
            
            accX[currentIndexInPredictionWindow] = Double(row[3])! as NSNumber
            accY[currentIndexInPredictionWindow] = Double(row[4])! as NSNumber
            accZ[currentIndexInPredictionWindow] = Double(row[5])! as NSNumber
            
            currentIndexInPredictionWindow += 1
            // rowindex = rowindex + 6
            
            print(("Row: \(row)"))
        }
        
        currentIndexInPredictionWindow = 0
        
    } catch {
        print ("CSVRead: Failed to Open/Parse CSV file")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
