//: # A Lightweight 'Accelerated' Matrix Library for Swift
//: ## About
//: `MatrixLite` is our answer to a user-friendly Matrix library that supports array striding, transposing, slicing, and various reducers and mathematical functions. Currently supports most of the methods required for basic artificial neural network (ANN) architectures and [extreme learning machines]().
//: Matrices are the workhorse of many machine learning/ANN workflows, so optimization and API simplification at the level of data representation has far-reaching implications for complex computational workflows. `MatrixLite` is designed to be fast, super lightweight, and most importantly, easy to use. Wherever possible, we take advantage of [SIMD](https://en.wikipedia.org/wiki/SIMD) instructions and data types and we take advantage of Apple's [Accelerate framework](https://developer.apple.com/documentation/accelerate) throughout. To facilitate rapid model development and prototyping, Tensorize wraps all of this computational power under a much more readable and 'Swifty' API.
//: ## API
//: ### Designated Initializer
//: ```swift
//: Matrix(_ data: [FloatingPoint], rows: Int, columns: Int? = nil)
//: ```
//: The default initializer for a `Matrix` creates an 2-dimensional array wrapping an underlying array data storage:
//: - Parameters:
//:   - `data` is a 1D array storage. It is an instance of Array.
//:   - `rows` is an Int specifying the number of rows of the Matrix
//:   - `columns` is an Int specifying the number of columns of the Matrix
//:   - Returns: An 2-dimensional Matrix wrapping `data`.
//: ### Other Initializers
//: Because we use Matrices in many different contexts, we need multiple ways to specify them:
//:
import Foundation
@testable import MatrixLite
//:
//: Create 2D matrix from an array of arrays
let data = [[1.0, 2.0, 3.0, 4.0],
            [5.0, 6.0, 7.0, 8.0],
            [8.0, 7.0, 6.0, 5.0],
            [4.0, 3.0, 2.0, 1.0]]
let matrix = Matrix(unpack: data)
//: Create 2D Matrix of repeated values
let ones = Matrix(repeating: 1.0, rows: 4, columns: 4)
//: Make a copy of an existing Matrix object
let copy = Matrix(copy: matrix)
//: Create a diagonal Matrix from an input array
let diag = Matrix(diagonal: data[0])
//: Row and Column Matrices are also easy to specify
let rowMatrix = Matrix(row: [1.0, 2.0, 3.0, 4.0])
let colMatrix = Matrix(column: [1.0, 2.0, 3.0, 4.0])
//:
//: We also have several useful `Vector` initializers, where `Vector` is simply a type alias to a `FloatingPoint` `Array`
//: ```swift
typealias Vector<FloatingPoint> = [FloatingPoint]
//: ```
//:
let range = Vector(from: 0.0, to: 10.0, by: 1.0)
let linspace = Vector(from: 1.0, through: 10.0, by: 1.0)
//:
//: Or to create a vector of random uniform values in [0, 1]
let random = Vector(initializedWith: drand48, count: 10)
//:
//: ### Mathematical Operations
//: How about matrix multiplication? Sure we got that:
//:
let vector = Vector(initializedWith: drand48, count: 25)
let B = Matrix(vector, rows: 5, columns: 5) // Some random matrix
let A: Matrix<Double> = identity(rows: 10, columns: 5, offset: 0) // Identity matrix
let C = A * B
//: or, for element-wise multiplication
let D = A[0..<5, 0..<5] × B
//:
//: We've also got a whole slew of SIMD math functions (that operate along the whole matrix):
//:
let arange = Vector(from: 0.0, to: 10.0, by: 0.1)
let initial = Matrix(arange, rows: 20, columns: 5)
let chained = pow((5.0 * matrix) / 5.0, 2.0)
//:
//: And even some commonly used reducers:
//:
let total = sum(Vector(chained))
let totalByRows = apply(sum, to: chained, along: .rows)
let average = mean(Vector(chained))
//:
//: And of course, since this is Swift, you can use things like map, flatMap, and reduce directly:
//:
let anotherTotal = Vector(chained).reduce(0.0) { $0 + $1 }
let product = Vector(chained).reduce(1.0) { $0 * $1 }
let cube = Vector(chained).map { $0 * $0 * $0 }
let flattened = Vector(chained)
//:
//: ### Slicing and Dicing
//:
let moreData = Vector(from: 0, to: 25, by: 1.0)
print(moreData.count)
let anotherMatrix = Matrix(moreData, rows: 5, columns: 5)
//: Slice by rows and cols
print(anotherMatrix[0..<5, 0])
//: Grab sub-matrices
print(anotherMatrix[0..<3, 0..<3])
print(anotherMatrix[0..<3, ...2]) // Mix and match range types
//: Grab individual elements
print(anotherMatrix[0, 0])
//: We can also shift and slice from the 'top' and 'bottom' directly
let hiLo = anotherMatrix[0..<3, 0..<5][...1, ...3]
print(hiLo.rows, hiLo.columns) // (2, 4)

