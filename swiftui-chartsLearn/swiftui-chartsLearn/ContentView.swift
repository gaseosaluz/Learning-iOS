//
//  ContentView.swift
//  swiftui-chartsLearn
//
//  Created by Ed Martinez on 12/29/21.
//

import SwiftUI
import Charts

struct ContentView: View {
    @State var data1: [CGFloat] = (2010...2020).map { _ in .random(in: 0.0...1.0) }
    @State var trim: CGFloat = 0
    
    var body: some View {
        HStack {
            VStack {
                AxisLabels(.vertical, data: (-10...10).reversed(), id: \.self) {
                    Text("\($0 * 10)")
                        .fontWeight(.bold)
                        .font(Font.system(size: 8))
                        .foregroundColor(.secondary)
                }
                .frame(width: 20)

                Rectangle().foregroundColor(.clear).frame(width: 20, height: 20)
            }

            VStack {
                Chart(data: data1)
                    .chartStyle(
                        LineChartStyle(.quadCurve, lineColor: .blue, lineWidth: 5, trimTo: $trim)
                    )
                    .padding()
                    .background(
                        GridPattern(horizontalLines: 20 + 1, verticalLines: data1.count + 1)
                            .inset(by: 1)
                            .stroke(Color.gray.opacity(0.1), style: .init(lineWidth: 2, lineCap: .round))
                    )
                    .onAppear {
                         trim = 0
                         withAnimation(.easeInOut(duration: 3)) {
                             trim = 1
                         }
                     }


                AxisLabels(.horizontal, data: 2010...2020, id: \.self) {
                    Text("\($0)".replacingOccurrences(of: ",", with: ""))
                        .fontWeight(.bold)
                        .font(Font.system(size: 8))
                        .foregroundColor(.secondary)
                }
                .frame(height: 20)
                .padding(.horizontal, 1)
            }
            .layoutPriority(1)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
