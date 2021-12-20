//
//  CSVUtilities.swift
//  CSVActivityRecognition
//
//  Created by Ed Martinez on 12/15/21.
//

/// CSVUtilities
///
/// This file contains various uitilies to manipulate CSV Files that contain Gyro and Accelerometer data

import SwiftUI
import CodableCSV

// Function (getGyroAccelfromCSV) below is for development purposes only - not used

func getGyroAccelfromCSV (csvData: String ) {
    
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
    return
}

///
/// addCSVMotionDataSampletoArray
///
/// This function takes the String that contains the entire CSV input file and parses it row by row.
/// As it parses each row it 'walks' the row from left to right and updates the gyroX, gyroY, gyroZ
/// AccelX, AccelY and AccelZ arrays with the data.
///
/// As it updates the Analysis array with a set of Gyro and Accelerometer data, it updates the index into the
/// prediction window
///
func addCSVMotionDataSampleToArray (csvData: String) {
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
            // print("Added sample at position: ", currentIndexInPredictionWindow)
            // If data array is full - execute a prediction
            if (currentIndexInPredictionWindow == ModelConstants.predictionWindowSize) {
                print("Enough data, make a prediction")
                if let predictedActivity = performModelPrediction() {
                    // activityName = predictedActivity
                    print("Predicted Activity: \(predictedActivity)")
                            // Use the predicted activity here
                            // ...

                            // Start a new prediction window
                    currentIndexInPredictionWindow = 0
                }
                break
            }
            
            print(("Row: \(row)"))
        }
        
        currentIndexInPredictionWindow = 0
        
    } catch {
        print ("CSVRead: Failed to Open/Parse CSV file")
    }
    return
}

///
/// parsedCSVStringToGyroAccel
///
/// Unpacks each row of CSV Data into individua entries for Gyro and Accelerometer Data.
/// This data will be used to create the analysis window that is passed to the CoreML model to make a prediction

func parsedCSVStringTo (parsedCSV: String) {
    
}
