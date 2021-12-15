//
//  CSVUtilities.swift
//  CSVActivityRecognition
//
//  Created by Ed Martinez on 12/15/21.
//

import SwiftUI
import CodableCSV

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
