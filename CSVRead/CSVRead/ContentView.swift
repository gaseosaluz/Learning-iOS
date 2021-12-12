//
//  ContentView.swift
//  CSVRead
//
//  Created by Ed Martinez on 12/10/21.
//

import SwiftUI
import CodableCSV



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

    do {
        let parsedCSV = try CSVReader.decode(input: csvData)
        let headers: [String] = parsedCSV.headers
        
        print("Parsed CSV File")
        
        print(headers)
        // Access the CSV rows (i.e. raw [String] values)
        let rows = parsedCSV.rows
        let row = parsedCSV[1]
        print(row)
    } catch {
        print ("CSVRead: Failed to Open/Parse CSV file")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


