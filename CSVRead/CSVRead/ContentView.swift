//
//  ContentView.swift
//  CSVRead
//
//  Created by Ed Martinez on 12/10/21.
//

import SwiftUI
import CodableCSV
import CoreML

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
            allowedContentTypes: [.plainText],
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
    var rotX = 0.0
    var rotY = 0.0
    var rotZ = 0.0
    var accX = 0.0
    var accY = 0.0
    var accZ = 0.0
    
    struct ModelConstants {
        static let predictionWindowSize = 50
        static let sensorsUpdateInterval = 1.0 / 50.0
        static let stateInLength = 400
    }
    
    var currentIndexInPredictionWindow = 0


    do {
        // NOTE: The headers are not picked up by the library.  The string is empty, however
        // they are assigned to the parsedCSV[0].  Until I figure out why, make sure to start
        // using the data begining at parsedCSV[1]
        
        let parsedCSV = try CSVReader.decode(input: csvData)
        let headers: [String] = parsedCSV.headers
        
        print("Parsed CSV File")
        
        print(headers)
        // Access the CSV rows (i.e. raw [String] values)
        let rows = parsedCSV.rows
        let row = parsedCSV[1]
        print("Parsed row: \(row)")
        
        rotX = Double(row[0]) ?? 0.0
        rotY = Double(row[1]) ?? 0.0
        rotZ = Double(row[2]) ?? 0.0
        
        accX = Double(row[3]) ?? 0.0
        accY = Double(row[4]) ?? 0.0
        accZ = Double(row[5]) ?? 0.0
        
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
        
        
    } catch {
        print ("CSVRead: Failed to Open/Parse CSV file")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


