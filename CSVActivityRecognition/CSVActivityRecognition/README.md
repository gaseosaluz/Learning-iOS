#  CSVActivity Recognition

## About this Project

CoreML Based Activity Recognition from Human Activity Data recorded/contained in a CSV file. 

## References

* Reead and write CSV files with `CodableCSV`. https://iosexample.com/read-and-write-csv-files-row-by-row-or-through-swifts-codable-interface/

* Uniform Type Identifiers.  https://developer.apple.com/documentation/uniformtypeidentifiers/system_declared_uniform_type_identifiers. Contains UTType identifies for comma separated text, tab separated text, etc files.  We are using `commaSeparatedText` to restrict it to CSV files where the `,` is the actual separator.

* Smartphone-Based Recognition of Human Activities and Postural Transitions Data Set. http://archive.ics.uci.edu/ml/datasets/Smartphone-Based+Recognition+of+Human+Activities+and+Postural+Transitions 

## Details

The CSV Data file contains the Gyro and Accelerometer data in the following format, with the first row being the header. This header is not used in the computations. It is discarded.

`rotation_x,rotation_y,rotation_z,acceleration_x,acceleration_y,acceleration_z
-0.755015,-0.306834,0.111704,-0.0487715,0.124232,-0.112227
0.577953,-0.232062,-0.585298,-0.131342,0.246649,-0.28662
0.74965,-0.442899,-0.749091,-0.249518,0.0726391,-0.057042
0.0351622,-0.413653,-0.676913,-0.124545,0.0489323,0.019612`

The file is parsed row by row and each element in the row's column is assigned to a `MultiArray` variable (6 items total).  These items will be inserted into the analysis window.

## Open Issues

* In this version the CSV file that contains the measurement that we want to analyze is read entirely into memory.  For now the files are very small so this should not be an issue, but if the sample files are much bigger this will have to be addressed by either splitting the input files or parsing and analyzing the file in chunks.

* Current version (as of 12/15/21) may not utilize the entire CSV file. It only reads enough data to fill the Prediction Analysis Array.  Once this is done, the CoreML model is asked to make a prediction with the data that has been read.

* If there is not enough data in the CSV file, no prediction will be made.  In fact the 


## TO DO

* Read and use all of the input CSV file instead of stopping when enough data has been read (to the size of the analysis window)

* Check number of entries in the input CSV file. There should be at least enough entries to fill a prediciton window. If there are not enough entries reject it as invalid.

* Parse the input file in chunks and discard a chunk that is not complete. 

## BUGS

* Prediction code not working. It alwasy returns *Sitting*



