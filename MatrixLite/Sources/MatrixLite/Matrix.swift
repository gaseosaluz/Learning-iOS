//
// Copyright (c) 2017 Set. All rights reserved.
// Copyright (c) 2014 Mattt Thompson (http://mattt.me/)
//

import Foundation
import Accelerate

public enum MatrixAxis {
    case rows
    case columns
}

public struct Matrix<T> where T: FloatingPoint, T: ExpressibleByFloatLiteral {

    let rows: Int
    let columns: Int
    public var data: Vector<T>

    init(_ data: [T], rows: Int, columns: Int? = nil) {
        let columns = columns ?? (data.count / rows)
        assert(rows * columns == data.count)
        self.rows = rows
        self.columns = columns
        self.data = data
    }

    init(repeating: T, rows: Int, columns: Int) {
        self.init(Vector<T>(repeating: repeating, count: rows * columns), rows: rows, columns: columns)
    }

    init(copy: Matrix) {
        self.init(copy.data, rows: copy.rows, columns: copy.columns)
    }

    init(unpack contents: [[T]]) {
        let rows: Int = contents.count
        let unpacked = contents.flatMap { $0 }
        let columns: Int = unpacked.count / rows
        self.init(unpacked, rows: rows, columns: columns)
    }

    // Initialize a zero matrix with the provided vector as diagonal
    init(diagonal: Vector<T>, rows: Int? = nil, columns: Int? = nil) {
        let rows = rows ?? diagonal.count
        let columns = columns ?? diagonal.count
        var array = Vector<T>(repeating: 0, count: rows * columns)
        let total = Swift.min(rows, diagonal.count)
        for (i, j) in stride(from: 0, to: total * columns, by: columns + 1).enumerated() {
            array[j] = diagonal[i]
        }
        self.init(array, rows: rows, columns: columns)
    }

    init(row: Vector<T>) {
        self.init(row, rows: 1, columns: row.count)
    }

    init(column: Vector<T>) {
        self.init(column, rows: column.count, columns: 1)
    }

    public func index(_ row: Int, _ column: Int) -> Int {
        assert(indexIsValidForRow(row, column: column))
        return (row * columns) + column
    }

    subscript(row: Int, column: Int) -> T {
        get { return data[index(row, column)] }
        set { data[index(row, column)] = newValue }
    }

    subscript(rows: Interval, columns: Interval) -> Matrix<T> {
        get {
            let lowerRow = rows.start ?? 0
            let upperRow = rows.end ?? (self.rows - 1)
            let lowerCol = columns.start ?? 0
            let upperCol = columns.end ?? (self.columns - 1)
            var newGrid = Vector<T>()
            for row in lowerRow...upperRow {
                newGrid.append(contentsOf: data[index(row, lowerCol)...index(row, upperCol)])
            }
            return Matrix(newGrid, rows: upperRow - lowerRow + 1, columns: upperCol - lowerCol + 1)
        }
        set {
            let lowerRow = rows.start ?? 0
            let upperRow = rows.end ?? (self.rows - 1)
            let lowerCol = columns.start ?? 0
            let upperCol = columns.end ?? (self.columns - 1)
            // Need an assert in here
            for (i, row) in (lowerRow...upperRow).enumerated() {
                data.replaceSubrange(index(row, lowerCol)...index(row, upperCol), with: newValue[row: i])
            }
        }
    }

    subscript(row row: Int) -> [T] {
        get {
            assert(row < rows)
            return Array(data[index(row, 0)...index(row, columns-1)])
        }
        set {
            assert(row < rows)
            assert(newValue.count == columns)
            data.replaceSubrange(index(row, 0)...index(row, columns-1), with: newValue)
        }
    }

    subscript(column column: Int) -> [T] {
        get {
            assert(column < columns)
            let strides = stride(from: index(0, column), to: data.count, by: columns)
            return strides.map { data[$0] }
        }
        set {
            assert(column < columns)
            assert(newValue.count == rows)
            let strides = stride(from: index(0, column), to: data.count, by: columns)
            strides.enumerated().forEach { data[$1] = newValue[$0] }
        }
    }

    public func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
}

// MARK: Matrix Transposition

// Compute the matrix transpose.
public func transpose(_ x: Matrix<Float>) -> Matrix<Float> {
    var results = Matrix<Float>(repeating: 0, rows: x.columns, columns: x.rows)
    vDSP_mtrans(x.data, 1, &results.data, 1, vDSP_Length(results.rows), vDSP_Length(results.columns))

    return results
}

// Compute the matrix transpose.
public func transpose(_ x: Matrix<Double>) -> Matrix<Double> {
    var results = Matrix<Double>(repeating: 0, rows: x.columns, columns: x.rows)
    vDSP_mtransD(x.data, 1, &results.data, 1, vDSP_Length(results.rows), vDSP_Length(results.columns))
    return results
}

// Matrix transpose property
extension Matrix where T == Float {
    var T: Matrix<Float> { return transpose(self) }
}

// Matrix transpose property
extension Matrix where T == Double {
    var T: Matrix<Double> { return transpose(self) }
}

// MARK: Matrix is Printable

extension Matrix: CustomStringConvertible {
    public var description: String {
        var description = ""

        for i in 0..<rows {
            let contents = (0..<columns).map{"\(self[i, $0])"}.joined(separator: " ")

            switch (i, rows) {
            case (0, 1):
                description += "( \(contents) )"
            case (0, _):
                description += "⎛ \(contents) ⎞"
            case (rows - 1, _):
                description += "⎝ \(contents) ⎠"
            default:
                description += "⎜ \(contents) ⎥"
            }

            description += "\n"
        }

        return description
    }
}

// MARK: Matrix as a Sequence

extension Matrix: Sequence {
    public func makeIterator() -> AnyIterator<ArraySlice<T>> {
        let endIndex = rows * columns
        var nextRowStartIndex = 0

        return AnyIterator {
            if nextRowStartIndex == endIndex { return nil }
            let currentRowStartIndex = nextRowStartIndex
            nextRowStartIndex += self.columns
            return self.data[currentRowStartIndex..<nextRowStartIndex]
        }
    }
}

// MARK: Matrix as Equatable

extension Matrix: Equatable {
    public static func ==<T>(lhs: Matrix<T>, rhs: Matrix<T>) -> Bool {
        return lhs.rows == rhs.rows && lhs.columns == rhs.columns && lhs.data == rhs.data
    }
}

// MARK: Matrix Utilities

/// Identity Matrix
///
/// - Parameters:
///     - rows: Number of rows in the output.
///     - columns: Number of columns in the output. If nil, defaults to `rows`.
///     - offset: Index of the diagonal: 0 (default) refers to the main diagonal, a positive value refers to an
///       upper diagonal, and a negative value to a lower diagonal.
/// - Returns: A 2-D tensor where all elements are 0, except for the `offset`-th diagonal, whose values are 1.
public func identity(rows: Int, columns: Int? = nil, offset: Int = 0) -> Matrix<Float> {
    let columns = columns ?? rows
    try! precondition(offset < rows, "offset should be less than or equal to rows.")
    var matrix = Matrix<Float>(repeating: 0, rows: rows, columns: columns)
    let offset = (offset >= 0 ? offset : -offset * columns)
    for i in stride(from: offset, to: rows * columns - offset, by: columns + 1) { matrix.data[i] = 1 }
    return matrix
}

/// Identity Matrix
///
/// - Parameters:
///     - rows: Number of rows in the output.
///     - columns: Number of columns in the output. If nil, defaults to `rows`.
///     - offset: Index of the diagonal: 0 (default) refers to the main diagonal, a positive value refers to an
///       upper diagonal, and a negative value to a lower diagonal.
/// - Returns: A 2-D tensor where all elements are 0, except for the `offset`-th diagonal, whose values are 1.
public func identity(rows: Int, columns: Int? = nil, offset: Int = 0) -> Matrix<Double> {
    let columns = columns ?? rows
    try! precondition(offset < rows, "offset should be less than or equal to rows.")
    var matrix = Matrix<Double>(repeating: 0, rows: rows, columns: columns)
    let offset = (offset >= 0 ? offset : -offset * columns)
    for i in stride(from: offset, to: rows * columns - offset, by: columns + 1) { matrix.data[i] = 1 }
    return matrix
}

// MARK: Matrix Arithmetic

public func add(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    var results = y
    cblas_saxpy(Int32(x.data.count), 1.0, x.data, 1, &(results.data), 1)
    return results
}

public func add(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with addition")
    var results = y
    cblas_daxpy(Int32(x.data.count), 1.0, x.data, 1, &(results.data), 1)
    return results
}

public func sub(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with subtraction")
    var results = y
    cblas_saxpy(Int32(x.data.count), 1.0, neg(x.data), 1, &(results.data), 1)
    return results
}

public func sub(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix dimensions not compatible with subtraction")
    var results = y
    cblas_daxpy(Int32(x.data.count), 1.0, neg(x.data), 1, &(results.data), 1)
    return results
}

public func mul(_ alpha: Float, x: Matrix<Float>) -> Matrix<Float> {
    var results = x
    cblas_sscal(Int32(x.data.count), alpha, &(results.data), 1)
    return results
}

public func mul(_ alpha: Double, x: Matrix<Double>) -> Matrix<Double> {
    var results = x
    cblas_dscal(Int32(x.data.count), alpha, &(results.data), 1)
    return results
}

// Matrix product of two matrices.
public func mul(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    try! precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    var results = Matrix<Float>(repeating: 0, rows: x.rows, columns: y.columns)
    cblas_sgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0,
            x.data, Int32(x.columns), y.data, Int32(y.columns), 0.0, &(results.data), Int32(results.columns))
    return results
}

// Matrix product of two matrices.
public func mul(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    try! precondition(x.columns == y.rows, "Matrix dimensions not compatible with multiplication")
    var results = Matrix<Double>(repeating: 0, rows: x.rows, columns: y.columns)
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans, Int32(x.rows), Int32(y.columns), Int32(x.columns), 1.0,
            x.data, Int32(x.columns), y.data, Int32(y.columns), 0.0, &(results.data), Int32(results.columns))
    return results
}

// Multiply matrices element-wise.
public func elmul(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Double>(repeating: 0, rows: x.rows, columns: x.columns)
    result.data = x.data * y.data
    return result
}

// Multiply matrices element-wise.
public func elmul(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Float>(repeating: 0, rows: x.rows, columns: x.columns)
    result.data = x.data * y.data
    return result
}

// Multiply matrices element-wise.
public func eldiv(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Double>(repeating: 0, rows: x.rows, columns: x.columns)
    result.data = x.data / y.data
    return result
}

// Multiply matrices element-wise.
public func eldiv(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    try! precondition(x.rows == y.rows && x.columns == y.columns, "Matrix must have the same dimensions")
    var result = Matrix<Float>(repeating: 0, rows: x.rows, columns: x.columns)
    result.data = x.data / y.data
    return result
}

public func div(_ x: Matrix<Double>, y: Matrix<Double>) -> Matrix<Double> {
    let yInv = inv(y)
    try! precondition(x.columns == yInv.rows, "Matrix dimensions not compatible")
    return mul(x, y: yInv)
}

public func div(_ x: Matrix<Float>, y: Matrix<Float>) -> Matrix<Float> {
    let yInv = inv(y)
    try! precondition(x.columns == yInv.rows, "Matrix dimensions not compatible")
    return mul(x, y: yInv)
}

public func pow(_ x: Matrix<Double>, _ y: Double) -> Matrix<Double> {
    return Matrix(pow(x.data, y), rows: x.rows, columns: x.columns)
}

public func pow(_ x: Matrix<Float>, _ y: Float) -> Matrix<Float> {
    return Matrix(pow(x.data, y), rows: x.rows, columns: x.columns)
}

public func sqrt(_ x: Matrix<Double>) -> Matrix<Double> {
    return Matrix(sqrt(x.data), rows: x.rows, columns: x.columns)
}

public func sqrt(_ x: Matrix<Float>) -> Matrix<Float> {
    return Matrix(sqrt(x.data), rows: x.rows, columns: x.columns)
}

public func exp(_ x: Matrix<Double>) -> Matrix<Double> {
    return Matrix(exp(x.data), rows: x.rows, columns: x.columns)
}

public func exp(_ x: Matrix<Float>) -> Matrix<Float> {
    return Matrix(exp(x.data), rows: x.rows, columns: x.columns)
}

// Apply a reducing function along the given axis.
//
// - Parameters:
//      - function: The reducer function to apply along the specified axis.
//      - x: The input matrix.
//      - axis: Axis or axes along which a sum is performed. The default is column-wise.
// - Returns: A row or column Matrix of values along the given axis (rows x 1 if axis = .row else 1 x columns).
public func apply(_ function: (_ v: Vector<Double>) -> Double, to x: Matrix<Double>,
                    along axis: MatrixAxis = .columns) -> Matrix<Double> {

    switch axis {
    case .columns:
        var result = Matrix<Double>(repeating: 0, rows: 1, columns: x.columns)
        for i in 0..<x.columns {
            result.data[i] = function(x[column: i])
        }
        return result

    case .rows:
        var result = Matrix<Double>(repeating: 0, rows: x.rows, columns: 1)
        for i in 0..<x.rows {
            result.data[i] = function(x[row: i])
        }
        return result
    }
}

// Apply a reducing function along the given axis.
//
// - Parameters:
//      - function: The reducer function to apply along the specified axis.
//      - x: The input matrix.
//      - axis: Axis or axes along which a sum is performed. The default is column-wise.
// - Returns: A row or column Matrix of values along the given axis (rows x 1 if axis = .row else 1 x columns).
public func apply(_ function: (_ v: Vector<Float>) -> Float, to x: Matrix<Float>,
                    along axis: MatrixAxis = .columns) -> Matrix<Float> {

    switch axis {
    case .columns:
        var result = Matrix<Float>(repeating: 0, rows: 1, columns: x.columns)
        for i in 0..<x.columns {
            result.data[i] = function(x[column: i])
        }
        return result

    case .rows:
        var result = Matrix<Float>(repeating: 0, rows: x.rows, columns: 1)
        for i in 0..<x.rows {
            result.data[i] = function(x[row: i])
        }
        return result
    }
}

// Apply a function to the matrix elements along the given axis.
//
// - Parameters:
//      - function: The function to apply along the specified axis.
//      - x: The input matrix.
//      - axis: Axis or axes along which a sum is performed. The default is column-wise.
// - Returns: A Matrix of the same shape with function applied along the given axis.
public func apply(_ function: (_ v: Vector<Double>) -> Vector<Double>, to x: Matrix<Double>,
                    along axis: MatrixAxis = .columns) -> Matrix<Double> {

    switch axis {
    case .columns:
        var result = Matrix<Double>(repeating: 0, rows: x.rows, columns: x.columns)
        for i in 0..<x.columns {
            result[column: i] = function(x[column: i])
        }
        return result

    case .rows:
        var result = Matrix<Double>(repeating: 0, rows: x.rows, columns: x.columns)
        for i in 0..<x.rows {
            result[row: i] = function(x[row: i])
        }
        return result
    }
}

// Apply a function to the matrix elements along the given axis.
//
// - Parameters:
//      - function: The function to apply along the specified axis.
//      - x: The input matrix.
//      - axis: Axis or axes along which a sum is performed. The default is column-wise.
// - Returns: A Matrix of the same shape with function applied along the given axis.
public func apply(_ function: (_ v: Vector<Float>) -> Vector<Float>, to x: Matrix<Float>,
                    along axis: MatrixAxis = .columns) -> Matrix<Float> {

    switch axis {
    case .columns:
        var result = Matrix<Float>(repeating: 0, rows: x.rows, columns: x.columns)
        for i in 0..<x.columns {
            result[column: i] = function(x[column: i])
        }
        return result

    case .rows:
        var result = Matrix<Float>(repeating: 0, rows: x.rows, columns: x.columns)
        for i in 0..<x.rows {
            result[row: i] = function(x[row: i])
        }
        return result
    }
}

// Apply a function to all matrix elements.
//
// - Parameters:
//      - function: The function to apply to the matrix elements.
//      - x: The input matrix.
// - Returns: A Matrix of the same shape with function applied to all elements.
public func apply(_ function: (_ v: Vector<Float>) -> Vector<Float>, to x: Matrix<Float>) -> Matrix<Float> {
    return Matrix(function(x.data), rows: x.rows, columns: x.columns)
}

// Apply a function to all matrix elements.
//
// - Parameters:
//      - function: The function to apply to the matrix elements.
//      - x: The input matrix.
// - Returns: A Matrix of the same shape with function applied to all elements.
public func apply(_ function: (_ v: Vector<Double>) -> Vector<Double>, to x: Matrix<Double>) -> Matrix<Double> {
    return Matrix(function(x.data), rows: x.rows, columns: x.columns)
}

// MARK: Matrix Linear Algebra

// Compute the (multiplicative) inverse of a matrix.
//
// Given a square matrix a, return the matrix a^-1 satisfying a * ainv = ainv * a = eye(a_rows).
//
// - Parameter: matrix Matrix to be inverted.
// - Returns: The (multiplicative) inverse of matrix.
public func inv(_ x : Matrix<Float>) -> Matrix<Float> {
    try! precondition(x.rows == x.columns, "Matrix must be square")

    var results = x
    var ipiv = [__CLPK_integer](repeating: 0, count: x.rows * x.rows)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CFloat](repeating: 0.0, count: Int(lwork))
    var error: __CLPK_integer = 0
    var nc1 = __CLPK_integer(x.columns)
    var nc2 = nc1
    var nc3 = nc1

    sgetrf_(&nc1, &nc2, &(results.data), &nc3, &ipiv, &error)
    sgetri_(&nc1, &(results.data), &nc2, &ipiv, &work, &lwork, &error)

    assert(error == 0, "Matrix not invertible")
    return results

}

// Compute the (multiplicative) inverse of a matrix.
//
// Given a square matrix a, return the matrix a^-1 satisfying a * ainv = ainv * a = eye(a_rows).
//
// - Parameter: matrix Matrix to be inverted.
// - Returns: The (multiplicative) inverse of matrix.
public func inv(_ x : Matrix<Double>) -> Matrix<Double> {
    try! precondition(x.rows == x.columns, "Matrix must be square")

    var results = x
    var ipiv = [__CLPK_integer](repeating: 0, count: x.rows * x.rows)
    var lwork = __CLPK_integer(x.columns * x.columns)
    var work = [CDouble](repeating: 0.0, count: Int(lwork))
    var error: __CLPK_integer = 0
    var nc1 = __CLPK_integer(x.columns)
    var nc2 = nc1
    var nc3 = nc1

    dgetrf_(&nc1, &nc2, &(results.data), &nc3, &ipiv, &error)
    dgetri_(&nc1, &(results.data), &nc2, &ipiv, &work, &lwork, &error)

    assert(error == 0, "Matrix not invertible")
    return results
}

// Compute the singular value decomposition of a matrix.
//
// Factors the matrix A as u * diag(s) * v, where u and v are unitary and s is a 1-d vector of a's singular values.
//
// - Parameter: matrix Matrix for which to calculate singular values.
// - Returns: Tuple containing a matrix U, a vector s, and a matrix V, such that A = U s V.H.
//
// - Notes:
// The decomposition is performed using LAPACK routine dgesvd_. The SVD is commonly written as a = U S V.H. The v
// returned by this function is V.H and u = U. If U is a unitary matrix, it means that it satisfies U.H = inv(U).
// The rows of v are the eigenvectors of a.H a. The columns of u are the eigenvectors of a a.H. For row i in v and
// column i in u, the corresponding eigenvalue is s[i]^2.
func singularValueDecomposition(_ A: Matrix<Double>) -> (U: Matrix<Double>, s: Vector<Double>, V: Matrix<Double>){
    var AT  = A.T
    var jobz1: Int8 = 65 // 'A'
    var jobz2 = jobz1

    var m = __CLPK_integer(A.rows)
    var n = __CLPK_integer(A.columns)

    var lda = m
    var ldu = m
    var ldvt = n

    // Allocate workspace size variables. By specifying an lWork of -1, we let LAPACK compute the optimal workspace.
    var wkOpt = __CLPK_doublereal(0.0)
    var lWork = __CLPK_integer(-1)
    var info = __CLPK_integer(0)
    //var iWork = [__CLPK_integer](repeating: 0, count: Int(8 * min(m, n)))

    // Create the output vectors and matrices
    var s = Vector(repeating: 0.0, count: Int(min(m, n)))
    var U = Matrix(repeating: 0.0, rows: Int(ldu), columns: Int(m))
    var VT = Matrix(repeating: 0.0, rows: Int(ldvt), columns: Int(n))

    // Query and allocate the optimal workspace
    dgesvd_(&jobz1, &jobz2, &m, &n, &AT.data, &lda, &s, &U.data, &ldu, &VT.data, &ldvt, &wkOpt, &lWork, &info)
    //dgesdd_(&jobz, &m, &n, &_A.grid, &lda, &s, &U.grid, &ldu, &VT.grid, &ldvt, &wkOpt, &lWork, &iWork, &info)

    // Create the relevant workspace and update lWork to 0
    lWork = __CLPK_integer(wkOpt)
    var work = Vector(repeating: 0.0, count: Int(lWork))

    // Compute SVD. There are two possible lapack functions that work equally well?
    dgesvd_(&jobz1, &jobz2, &m, &n, &AT.data, &lda, &s, &U.data, &ldu, &VT.data, &ldvt, &work, &lWork, &info)
    //dgesdd_(&jobz, &m, &n, &_A.grid, &lda, &s, &U.grid, &ldu, &VT.grid, &ldvt, &work, &lWork, &iWork, &info)

    // Check for convergence.
    try! precondition(info == 0, "SVD calculation failed to converge.")

    return (U.T, s, VT.T)
}

// Compute the singular value decomposition of a matrix.
//
// Factors the matrix A as u * diag(s) * v, where u and v are unitary and s is a 1-d vector of a's singular values.
//
// - Parameter: matrix Matrix for which to calculate singular values.
// - Returns: Tuple containing a matrix U, a vector s, and a matrix V, such that A = U s V.H.
//
// - Notes:
// The decomposition is performed using LAPACK routine sgesvd_. The SVD is commonly written as a = U S V.H. The v
// returned by this function is V.H and u = U. If U is a unitary matrix, it means that it satisfies U.H = inv(U).
// The rows of v are the eigenvectors of a.H a. The columns of u are the eigenvectors of a a.H. For row i in v and
// column i in u, the corresponding eigenvalue is s[i]^2.
func singularValueDecomposition(_ A: Matrix<Float>) -> (U: Matrix<Float>, s: Vector<Float>, V: Matrix<Float>){
    var AT  = A.T
    var jobz1: Int8 = 65 // 'A'
    var jobz2 = jobz1

    var m = __CLPK_integer(A.rows)
    var n = __CLPK_integer(A.columns)

    var lda = m
    var ldu = m
    var ldvt = n

    // Allocate workspace size variables. By specifying an lWork of -1, we let LAPACK compute the optimal workspace.
    var wkOpt = __CLPK_real(0.0)
    var lWork = __CLPK_integer(-1)
    var info = __CLPK_integer(0)
    //var iWork = [__CLPK_integer](repeating: 0, count: Int(8 * min(m, n)))

    // Create the output vectors and matrices
    var s = Vector<Float>(repeating: 0.0, count: Int(min(m, n)))
    var U = Matrix<Float>(repeating: 0.0, rows: Int(ldu), columns: Int(m))
    var VT = Matrix<Float>(repeating: 0.0, rows: Int(ldvt), columns: Int(n))

    // Query and allocate the optimal workspace
    sgesvd_(&jobz1, &jobz2, &m, &n, &AT.data, &lda, &s, &U.data, &ldu, &VT.data, &ldvt, &wkOpt, &lWork, &info)
    //sgesdd_(&jobz, &m, &n, &_A.grid, &lda, &s, &U.grid, &ldu, &VT.grid, &ldvt, &wkOpt, &lWork, &iWork, &info)

    // Create the relevant workspace and update lWork to 0
    lWork = __CLPK_integer(wkOpt)
    var work = Vector<Float>(repeating: 0.0, count: Int(lWork))

    // Compute SVD. There are two possible lapack functions that work equally well?
    sgesvd_(&jobz1, &jobz2, &m, &n, &AT.data, &lda, &s, &U.data, &ldu, &VT.data, &ldvt, &work, &lWork, &info)
    //sgesdd_(&jobz, &m, &n, &_A.grid, &lda, &s, &U.grid, &ldu, &VT.grid, &ldvt, &work, &lWork, &iWork, &info)

    // Check for convergence.
    try! precondition(info == 0, "SVD calculation failed to converge.")

    return (U.T, s, VT.T)
}

// Compute the (Moore-Penrose) pseudo-inverse of a matrix.
//
// Calculate the generalized inverse of a matrix using its singular-value decomposition (SVD) and including all large
// singular values. Preconditions on the SVD computation converging (which maybe is a bad idea?).
//
// - Parameter: matrix Matrix to be pseudo-inverted.
// - Returns: The pseudo-inverse of matrix.
//
// - Notes:
// The pseudo-inverse of a matrix A, denoted A^+, is defined as: "the matrix that 'solves' [the least-squares problem]
// Ax = b", i.e. if \bar{x} is said solution, then A^+ is that matrix such that \bar{x} = A^+b.
//
// It can be shown that if Q_1 \Sigma Q_2^T = A is the singular value decomposition of A, then A^+ = Q_2 \Sigma^+ Q_1^T,
// where Q_{1,2} are orthogonal matrices, \Sigma is a diagonal matrix consisting of A’s so-called singular values,
// (followed, typically, by zeros), and then \Sigma^+ is simply the diagonal matrix consisting of the reciprocals of
// A’s singular values (again, followed by zeros).
//
// - References:
// G. Strang, Linear Algebra and Its Applications, 2nd Ed., Orlando, FL, Academic Press, Inc., 1980, pp. 139-142.
//
// - Examples:
//
// The following example checks that a * a+ * a == a and a+ * a * a+ == a+:
//      let random = (0..<9*6).map { _ in drand48() }
//      let a = Matrix(random, rows: 9, columns: 6)
//      let b = pinv(a)
//      print(a, a * (b * a)) // The two sets of matrices should be _almost_ equal
//      print(b, b * (a * b))
public func pseudoInverse(_ matrix: Matrix<Double>) -> Matrix<Double> {

    let (U, s, V) = singularValueDecomposition(matrix)
    let m = U.rows
    let n = V.columns
    let ma = m < n ? n : m
    let tolerance = .ulpOfOne * Double(ma) * max(s)
    let sInverse = s.map { ($0 > tolerance) ? 1 / $0 : 0.0 }
    let Z = Matrix(diagonal: sInverse, rows: n, columns: m)
    let inverse = V.T * Z * U.T
    return inverse
}

// Compute the (Moore-Penrose) pseudo-inverse of a matrix.
//
// Calculate the generalized inverse of a matrix using its singular-value decomposition (SVD) and including all large
// singular values. Preconditions on the SVD computation converging (which maybe is a bad idea?).
//
// - Parameter: matrix Matrix to be pseudo-inverted.
// - Returns: The pseudo-inverse of matrix.
//
// - Notes:
// The pseudo-inverse of a matrix A, denoted A^+, is defined as: "the matrix that 'solves' [the least-squares problem]
// Ax = b", i.e. if \bar{x} is said solution, then A^+ is that matrix such that \bar{x} = A^+b.
//
// It can be shown that if Q_1 \Sigma Q_2^T = A is the singular value decomposition of A, then A^+ = Q_2 \Sigma^+ Q_1^T,
// where Q_{1,2} are orthogonal matrices, \Sigma is a diagonal matrix consisting of A’s so-called singular values,
// (followed, typically, by zeros), and then \Sigma^+ is simply the diagonal matrix consisting of the reciprocals of
// A’s singular values (again, followed by zeros).
//
// - References:
// G. Strang, Linear Algebra and Its Applications, 2nd Ed., Orlando, FL, Academic Press, Inc., 1980, pp. 139-142.
//
// - Examples:
//
// The following example checks that a * a+ * a == a and a+ * a * a+ == a+:
//      let random = (0..<9*6).map { _ in srand48() }
//      let a = Matrix(random, rows: 9, columns: 6)
//      let b = pinv(a)
//      print(a, a * (b * a)) // The two sets of matrices should be _almost_ equal
//      print(b, b * (a * b))
public func pseudoInverse(_ matrix: Matrix<Float>) -> Matrix<Float> {
    let (U, s, V) = singularValueDecomposition(matrix)
    let m = U.rows
    let n = V.columns
    let ma = m < n ? n : m
    let tolerance = .ulpOfOne * Float(ma) * max(s)
    let sInverse = s.map { ($0 > tolerance) ? 1 / $0 : 0.0 }
    let Z = Matrix(diagonal: sInverse, rows: n, columns: m)
    let inverse = V.T * Z * U.T
    return inverse
}
