/*
 Playground to figure out how to extract the R, G, G, B components from an
 array that simulates the Bayer Sensor Pattern
 
 This is a very, very brute force approach. There is likely a better (faster)
 way to do this. For right now this looks a lot like plain C code.
 
 Currently the output of this program is the creation of 4 arrays: Red, Green1,
 Blue and Green2.
 
 Now that I have this 'algorithm' then I can try it with real data from a
 a RAW file
 The next challenge will be to convert (merge) these arrays into an Array
 (I am guessing of the MultiArray Type?) with the shape
 
 [red, green1, blue, green2, n]
*/

// {0,1,2} for {R,G,B} and 3 for the extra G channel).
let bayern =
    [[0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 ],
     [3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0,],
     [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 ],
     [3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0,],
     [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 ],
     [3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0,],
     [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 ],
     [3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0,],
]
// red array with dummy data
var red =
    [[0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 ],
     [3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0 ],
     [0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0 ],
     [3.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0 ],
]

// Now make a blue and two green arrays with dummy data
var blue = red
var green1 = red
var green2 = red

bayern[0][1]
bayern.count        // Number of rows. Each row is an element in the array
bayern[0]           // First row
bayern[0].count
let numberColumns = bayern[0].count
let numberRows = bayern.count


// Extract the RED
for i in stride(from: 0, to: (numberRows-1), by: 2) {
    print("Row: \(i)", terminator:"\n")
    for j in stride(from: 0, to: (numberColumns-1), by: 2) {
        print(" \(bayern[i][j]), ", terminator:"")
        red[i/2][j/2] = bayern[i][j]
    }
    print("\n")
}
print("RED")
print(red)

// Extract the Blue
for i in stride(from: 1, to: (numberRows), by: 2) {
    print("Row: \(i)", terminator:"\n")
    for j in stride(from: 1, to: (numberColumns), by: 2) {
        print(" \(bayern[i][j]), ", terminator:"")
        blue[i/2][j/2] = bayern[i][j]
    }
    print("\n")
}
print("BLUE")
print(blue)

// Green is in every row, but intearleaves differently with R and B
// Extract the first Green, first the even rows and even columns

for i in stride(from: 0, to: (numberRows-1), by: 2) {
    print("Row: \(i)", terminator:"\n")
    // Green in odd columns
    for j in stride(from: 1, to: (numberColumns), by: 2) {
        print(" \(bayern[i][j]), ", terminator:"")
        green1[i/2][j/2] = bayern[i][j]
    }
    print("\n")
}
print("GREEN2")
print(green1)

// Extract the second GREEN
// In the odd rows

for i in stride(from: 1, to: (numberRows), by: 2) {
    print("Row: \(i)", terminator:"\n")
    // Green in odd columns
    for j in stride(from: 0, to: (numberColumns-1), by: 2) {
        print(" \(bayern[i][j]), ", terminator:"")
        green2[i/2][j/2] = bayern[i][j]
    }
    print("\n")
}
print("GREEN1")
print(green2)

var multiRAW = [red, green1, green2, blue]

print("")
print(multiRAW)

print(multiRAW.description)
