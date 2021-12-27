//
//  ContentView.swift
//  SwiftUIChartsCSV
//
//  Created by Ed Martinez on 12/26/21.
//

import SwiftUI
import SwiftUICharts

struct ContentView: View {
    
    var body: some View {
        
        NavigationView {
            List {
                Section(header: Text("Line Chart")) {
                    NavigationLink(destination: LineChartDemoView()) {
                        Text("Line Chart")
                    }
                }            }
            .navigationTitle("SwiftUIChartsCSV")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
