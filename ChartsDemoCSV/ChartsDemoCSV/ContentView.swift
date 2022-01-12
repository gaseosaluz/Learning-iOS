//
//  ContentView.swift
//  ChartsDemoCSV
//
//  Created by Ed Martinez on 12/31/21.
//
// TODO: Put the graph view with other SwiftUI elements (buttons to open CSV, etc)

import SwiftUI
import Foundation
import CodableCSV
import Charts
import CoreML

// MARK: - CoreML model constants

struct ModelConstants {
    static let predictionWindowSize = 50
    static let sensorsUpdateInterval = 1.0 / 50.0
    static let stateInLength = 400
    static let hiddenInLenght = 20
    static let hiddenCellInLenght = 200
}


// MARK: The Core ML Classifier model expects MultiArrays, so create MLMultiArray variables to hold the sensor data that we are going to feed to the model

// MARK: - Accelerometer data. These variables are the same whether the data comes from a CSV file or from embedded hardware (Bluetooth or WiFi)
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

// MARK: Initialize CoreML Model
let activityClassificationModel: UCICreateML = {
    do {
        let config = MLModelConfiguration()
        return try UCICreateML(configuration: config)
    } catch {
        print(error)
        fatalError("Couldn't create ML Model")
    }
}()
// End Initialize CoreML Model

//MARK: Main View (ContentView)

struct ContentView: View {
    
    @State private var isImporting: Bool = false
    @State private var isExporting: Bool = false
    @State private var analysisArrayFull: Bool = false
    @State public var activityName: String = "No Activity"
    
    var body: some View {
        
        VStack {
            GroupBox(label: Text("CSV File Contents:")) {
            }
            Line(lineEntries: [
                BarChartDataEntry(x: 1, y: 1),
                BarChartDataEntry(x: 2, y: 2),
                BarChartDataEntry(x: 3, y: 3),
                BarChartDataEntry(x: 4, y: 4),
                BarChartDataEntry(x: 5, y: 10)
            ])
            
            GroupBox {
                HStack {
                    //TODO: This button action broke when I formatted it
                    Button(action: { isImporting = true }, label: {
                        Text("Analyze CSV")
                    })
                    
                }
            }
        }
        // MARK: CSV Reading. NOTE that the current code reads the entire CSV file into a string (memory). Given that we plan to have small CSV files, this should be OK. However if the files are large we will need to review this.
        // Uses fileimporter. Restricted to CSV files and can choose only one file (https://developer.apple.com/documentation/swiftui/form/fileimporter(ispresented:allowedcontenttypes:allowsmultipleselection:oncompletion:))
        .fileImporter(
            isPresented: $isImporting,
            // .plainText
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                guard let csvData = String(data: try Data(contentsOf: selectedFile), encoding: .utf8) else { return }
                
                // document.message = csvData
                
                // MARK: Parse CSV data from file
                // parseCSVFile(csvData: csvData)
                
                // Set stateOutput and input to zero before starting a new session
                // Not sure if this is the best way to do this. This is needed by the
                // CoreML model
                
                //for indx in stride(from: 0, to: ModelConstants.stateInLength - 1, by: 1)
                for indx in stride(from: 0, to: 399, by: 1)
                {
                    stateOutput[indx] = 0.0
                }
                
                addCSVMotionDataSampleToArray (csvData: csvData)
                
            } catch {
                // Handle error
                print("\(error)")
            }
            
        }
        // End File importer
    }
}

// MARK: Line Chart Code
// Understanding UIViewRepresentable: https://www.appcoda.com/learnswiftui/swiftui-uikit.html

struct Line : UIViewRepresentable {
    var lineEntries : [ChartDataEntry]
    
    
    func makeUIView(context: Context) -> LineChartView {
        let lineChart = LineChartView()
        lineChart.data = addLineData()
        
        let leftAxis = lineChart.leftAxis
        leftAxis.axisMaximum = 10
        leftAxis.axisMinimum = -10
        leftAxis.drawAxisLineEnabled = false
        
        lineChart.rightAxis.enabled = false
        lineChart.drawBordersEnabled = true
        lineChart.chartDescription?.enabled = false
        lineChart.setScaleEnabled(true)
        lineChart.legend.enabled = false
        lineChart.xAxis.enabled = true
        lineChart.drawGridBackgroundEnabled = true
        lineChart.setScaleEnabled(true)
        lineChart.lineData?.setDrawValues(false)
        lineChart.setNeedsDisplay()
        
        return lineChart
    }
    
    func updateUIView(_ uiView: LineChartView, context: Context) {
        // the next line will enable automatic chart update
        // in casd the data changes
        uiView.data = addLineData()
    }
    
    /*
    //MARK: Add data for LineChart
    func addLineData() -> LineChartData{
        let data = LineChartData()
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9)!)
        data.setDrawValues(true)
        
        let yVals1 = (0..<50).map { (i) -> ChartDataEntry in
            let val = Double(arc4random_uniform(10))
            return ChartDataEntry(x: Double(i), y: val)
        }
        
        let set1 = LineChartDataSet(entries: yVals1, label: "DataSet 1")
        
        set1.mode = .cubicBezier
        
        set1.axisDependency = .left
        set1.setColor(UIColor(red: 255/255, green: 241/255, blue: 46/255, alpha: 1))
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.circleRadius = 3
        //set1.fillAlpha = 1
        set1.drawFilledEnabled = true
        set1.fillColor = .white
        set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        set1.drawCircleHoleEnabled = false
        set1.drawFilledEnabled = false
        set1.drawValuesEnabled = false
        
        let dataSet = set1
        
        dataSet.colors = [NSUIColor.blue]
        //change data label
        dataSet.label = "My Data"
        data.addDataSet(dataSet)
        return data
    }
*/
    
}
typealias UIViewType = BarChartView

// End Line Chart Code

//MARK: Functions to add CSV File data to the charts


func parseCSVFile (csvData: String ) {
    
    do {
        
        let parsedCSV = try CSVReader(input: csvData) { $0.headerStrategy = .firstLine }
        
        let headers = parsedCSV.headers
        
        print("Parsed CSV File")
        print(headers)
        
        // let record = try parsedCSV.readRecord()
        
        //var currentIndexInPredictionWindow = 0
        /*
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
        */
        //currentIndexInPredictionWindow = 0
        
    } catch {
        print ("CSVRead: Failed to Open/Parse CSV file")
    }
}

struct Bar_Previews: PreviewProvider {
    static var previews: some View {
        /*
         Line(lineEntries: [
         BarChartDataEntry(x: 1, y: 1),
         BarChartDataEntry(x: 2, y: 2),
         BarChartDataEntry(x: 3, y: 3),
         BarChartDataEntry(x: 4, y: 4),
         BarChartDataEntry(x: 5, y: 5)
         ])
         */
        ContentView()
        
    }
}
