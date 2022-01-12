//
//  ChartsSupport.swift
//  ChartsDemoCSV
//
//  Created by Ed Martinez on 1/4/22.
//

import Charts
import SwiftUI

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
