#  ChartsDemoCSV

Reads a CSV file that contains Acceleromenter and Gyro data (from a mobile device or embedded hardware) and:

* Plots a Graph of the file
* Runs the accelerometer and gyro data through an Activity Recognition CoreML Model
* Displays the Activity that is represented by the CSV file

## References

* Understanding UIViewRepresentable: https://www.appcoda.com/learnswiftui/swiftui-uikit.html
* Swift Charts: https://github.com/danielgindi/Charts
* Read and Write CSV files using Codable CSV. https://github.com/dehesa/CodableCSV

## Notes

* TBD

## Limitations

* It reads the entire contents of the CSV file into memory (a String). Since we expect that the analysis window (directly related to the CSV file size) will be small, we don't anticipate that this will be a problem.
* If the CSV input file contains more samples than the current size of the analysis window (as it will most likely be the case) the current version of the program only analyzes the fist N-values until it gathers enough data for an analysis window.  The remaining of the data is currently ignored.

## TODO

* Clean up GUI - fix visuals
* Display the name of the CSV file that is being analyzed

## Bugs

* Code is unstable - it fails with `BAD ACESS` or `malloc()` errors at various places. Not a consistent point of failure.
* Code fails when it calls `UCICreateML()` to initialize the model (in `ContentView`) to make a prediction.

