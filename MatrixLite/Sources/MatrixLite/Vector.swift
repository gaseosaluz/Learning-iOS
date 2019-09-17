//
// Copyright (c) 2017 Set. All rights reserved.
// Copyright (c) 2014 Mattt Thompson (http://mattt.me/)
//

import Foundation
import Accelerate

public typealias Vector<FloatingPoint> = [FloatingPoint]

extension Vector where Element: Strideable {
    /// Initialize a vector of evenly spaced values within a given interval.
    ///
    /// - Returns: A vector with values generated within the half-open interval [from, to) (i.e., the interval
    /// including `from` but excluding `to`).
    init(from: Element, to: Element, by: Element.Stride) {
        self.init(stride(from: from, to: to, by: by))
    }

    /// Initialize a vector of evenly spaced values within a given interval.
    ///
    /// - Returns: A vector with values generated within the half-open interval [from, to] (i.e., the interval
    ///   including `from` and `to`).
    init(from: Element, through: Element, by: Element.Stride) {
        self.init(stride(from: from, through: through, by: by))
    }

    /// Initialize a vector with an input initializer function.
    ///
    /// - Returns: A vector of `count` values initialized with `initializer`. This is particularly useful for
    ///   generating vectors of random values.
    init(initializedWith initializer: () -> Element, count: Int) {
        self.init(Vector((0..<count).map { _ in initializer() }))
    }
}

extension Vector where Element: FloatingPoint, Element: ExpressibleByFloatLiteral {
    /// Initialize a Vector from a Matrix
    ///
    /// - Returns: A Vector with the data elements from the input Matrix
    init(_ matrix: Matrix<Element>) {
        self.init(matrix.data)
    }
}

// MARK: Sum

public func sum(_ x: Vector<Float>) -> Float {
    var result: Float = 0.0
    vDSP_sve(x, 1, &result, vDSP_Length(x.count))

    return result
}

public func sum(_ x: Vector<Double>) -> Double {
    var result: Double = 0.0
    vDSP_sveD(x, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Sum of Absolute Values

public func asum(_ x: Vector<Float>) -> Float {
    return cblas_sasum(Int32(x.count), x, 1)
}

public func asum(_ x: Vector<Double>) -> Double {
    return cblas_dasum(Int32(x.count), x, 1)
}

// MARK: Maximum Value

public func max(_ x: Vector<Float>) -> Float {
    var result: Float = 0.0
    vDSP_maxv(x, 1, &result, vDSP_Length(x.count))

    return result
}

public func max(_ x: Vector<Double>) -> Double {
    var result: Double = 0.0
    vDSP_maxvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Maximum Value Index

public func argmax(_ x: Vector<Float>) -> Int {
    var value: Float = 0.0
    var index: vDSP_Length = 0
    vDSP_maxvi(x, 1, &value, &index, vDSP_Length(x.count))
    return Int(index)
}

public func argmax(_ x: Vector<Double>) -> Int {
    var value: Double = 0.0
    var index: vDSP_Length = 0
    vDSP_maxviD(x, 1, &value, &index, vDSP_Length(x.count))
    return Int(index)
}

// MARK: Minimum Value

public func min(_ x: Vector<Float>) -> Float {
    var result: Float = 0.0
    vDSP_minv(x, 1, &result, vDSP_Length(x.count))

    return result
}

public func min(_ x: Vector<Double>) -> Double {
    var result: Double = 0.0
    vDSP_minvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Minimum Value Index

public func argmin(_ x: Vector<Float>) -> Int {
    var value: Float = 0.0
    var index: vDSP_Length = 0
    vDSP_minvi(x, 1, &value, &index, vDSP_Length(x.count))
    return Int(index)
}

public func argmin(_ x: Vector<Double>) -> Int {
    var value: Double = 0.0
    var index: vDSP_Length = 0
    vDSP_minviD(x, 1, &value, &index, vDSP_Length(x.count))
    return Int(index)
}

// MARK: Normalized

/// Return normalized vector (substract mean value and divide by standard deviation).
///
/// - Parameter: x Vector
/// - Returns: Normalized vector x
public func normalized(_ x: Vector<Float>) -> Vector<Float> {
    var m: Float = 0.0
    var s: Float = 0.0
    var c = Vector<Float>(repeating: 0.0, count: x.count)
    vDSP_normalize(x, 1, &c, 1, &m, &s, vDSP_Length(x.count))
    //guard let scale = scale, let bias = bias else { return c }
    return c// * scale + bias
}

/// Return normalized vector (substract mean value and divide by standard deviation).
///
/// - Parameter: x Vector
/// - Returns: Normalized version of vector x, such that x = (x - mean) / std.dev.
public func normalized(_ x: Vector<Double>) -> Vector<Double> {
    var m: Double = 0.0
    var s: Double = 0.0
    var c = Vector<Double>(repeating: 0.0, count: x.count)
    vDSP_normalizeD(x, 1, &c, 1, &m, &s, vDSP_Length(x.count))
    //guard let scale = scale, let bias = bias else { return c }
    return c// * scale + bias
}

// MARK: Mean

public func mean(_ x: Vector<Float>) -> Float {
    var result: Float = 0.0
    vDSP_meanv(x, 1, &result, vDSP_Length(x.count))

    return result
}

public func mean(_ x: Vector<Double>) -> Double {
    var result: Double = 0.0
    vDSP_meanvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Mean Magnitude

public func meamg(_ x: Vector<Float>) -> Float {
    var result: Float = 0.0
    vDSP_meamgv(x, 1, &result, vDSP_Length(x.count))

    return result
}

public func meamg(_ x: Vector<Double>) -> Double {
    var result: Double = 0.0
    vDSP_meamgvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Mean Square Value

public func measq(_ x: Vector<Float>) -> Float {
    var result: Float = 0.0
    vDSP_measqv(x, 1, &result, vDSP_Length(x.count))

    return result
}

public func measq(_ x: Vector<Double>) -> Double {
    var result: Double = 0.0
    vDSP_measqvD(x, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Standard Deviation

/// Return standard deviation of vector.
///
/// - Parameter: x Vector
/// - Returns: Standard deviation of vector x.
public func std(_ x: Vector<Float>) -> Float {
    var m: Float = 0.0
    var s: Float = 0.0
    vDSP_normalize(x, 1, nil, 1, &m, &s, vDSP_Length(x.count))
    return s
}

/// Return standard deviation of vector.
///
/// - Parameter: x Vector
/// - Returns: Standard deviation of vector x.
public func std(_ x: Vector<Double>) -> Double {
    var m: Double = 0.0
    var s: Double = 0.0
    vDSP_normalizeD(x, 1, nil, 1, &m, &s, vDSP_Length(x.count))
    return s
}

// MARK: Addition

public func add(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(y)
    cblas_saxpy(Int32(x.count), 1.0, x, 1, &results, 1)

    return results
}

public func add(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(y)
    cblas_daxpy(Int32(x.count), 1.0, x, 1, &results, 1)

    return results
}

// MARK: Subtraction

public func sub(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(y)
    catlas_saxpby(Int32(x.count), 1.0, x, 1, -1, &results, 1)

    return results
}

public func sub(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(y)
    catlas_daxpby(Int32(x.count), 1.0, x, 1, -1, &results, 1)

    return results
}

// MARK: Multiply

public func mul(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vDSP_vmul(x, 1, y, 1, &results, 1, vDSP_Length(x.count))

    return results
}

public func mul(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vDSP_vmulD(x, 1, y, 1, &results, 1, vDSP_Length(x.count))

    return results
}

// MARK: Divide

public func div(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvdivf(&results, x, y, [Int32(x.count)])

    return results
}

public func div(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvdiv(&results, x, y, [Int32(x.count)])

    return results
}

// MARK: Modulo

public func mod(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvfmodf(&results, x, y, [Int32(x.count)])

    return results
}

public func mod(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvfmod(&results, x, y, [Int32(x.count)])

    return results
}

// MARK: Remainder

public func remainder(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvremainderf(&results, x, y, [Int32(x.count)])

    return results
}

public func remainder(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvremainder(&results, x, y, [Int32(x.count)])

    return results
}

// MARK: Square Root

public func sqrt(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvsqrtf(&results, x, [Int32(x.count)])

    return results
}

public func sqrt(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvsqrt(&results, x, [Int32(x.count)])

    return results
}

// MARK: Dot Product

public func dot(_ x: Vector<Float>, y: Vector<Float>) -> Float {
    try! precondition(x.count == y.count, "Vectors must have equal count")

    var result: Float = 0.0
    vDSP_dotpr(x, 1, y, 1, &result, vDSP_Length(x.count))

    return result
}

public func dot(_ x: Vector<Double>, y: Vector<Double>) -> Double {
    try! precondition(x.count == y.count, "Vectors must have equal count")

    var result: Double = 0.0
    vDSP_dotprD(x, 1, y, 1, &result, vDSP_Length(x.count))

    return result
}

// MARK: Distance

public func dist(_ x: Vector<Float>, y: Vector<Float>) -> Float {
    try! precondition(x.count == y.count, "Vectors must have equal count")
    let sub = x - y
    var squared = Vector<Float>(repeating: 0.0, count: x.count)
    vDSP_vsq(sub, 1, &squared, 1, vDSP_Length(x.count))

    return sqrt(sum(squared))
}

public func dist(_ x: Vector<Double>, y: Vector<Double>) -> Double {
    try! precondition(x.count == y.count, "Vectors must have equal count")
    let sub = x - y
    var squared = Vector<Double>(repeating: 0.0, count: x.count)
    vDSP_vsqD(sub, 1, &squared, 1, vDSP_Length(x.count))

    return sqrt(sum(squared))
}

// MARK: Power

public func pow(_ x: Vector<Float>, y: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvpowf(&results, x, y, [Int32(x.count)])

    return results
}

public func pow(_ x: Vector<Double>, y: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvpow(&results, x, y, [Int32(x.count)])

    return results
}

public func pow(_ x: Vector<Float>, _ y: Float) -> Vector<Float> {
    let yVec = Vector<Float>(repeating: y, count: x.count)
    return pow(yVec, y: x)
}

public func pow(_ x: Vector<Double>, _ y: Double) -> Vector<Double> {
    let yVec = Vector<Double>(repeating: y, count: x.count)
    return pow(yVec, y: x)
}

// MARK: Exponentiation

public func exp(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvexpf(&results, x, [Int32(x.count)])

    return results
}

public func exp(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvexp(&results, x, [Int32(x.count)])

    return results
}

// MARK: Natural Logarithm

public func log(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(x)
    vvlogf(&results, x, [Int32(x.count)])

    return results
}

public func log(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(x)
    vvlog(&results, x, [Int32(x.count)])

    return results
}

// MARK: Base-2 Logarithm

public func log2(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(x)
    vvlog2f(&results, x, [Int32(x.count)])

    return results
}

public func log2(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(x)
    vvlog2(&results, x, [Int32(x.count)])

    return results
}

// MARK: Base-10 Logarithm

public func log10(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(x)
    vvlog10f(&results, x, [Int32(x.count)])

    return results
}

public func log10(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(x)
    vvlog10(&results, x, [Int32(x.count)])

    return results
}

// MARK: Absolute Value

public func abs(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvfabs(&results, x, [Int32(x.count)])

    return results
}

public func abs(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvfabsf(&results, x, [Int32(x.count)])

    return results
}

// MARK: Ceiling

public func ceil(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvceilf(&results, x, [Int32(x.count)])

    return results
}

public func ceil(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvceil(&results, x, [Int32(x.count)])

    return results
}

// MARK: Clip

public func clip(_ x: Vector<Float>, low: Float, high: Float) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count), y = low, z = high
    vDSP_vclip(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))

    return results
}

public func clip(_ x: Vector<Double>, low: Double, high: Double) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count), y = low, z = high
    vDSP_vclipD(x, 1, &y, &z, &results, 1, vDSP_Length(x.count))

    return results
}

// MARK: Copy Sign

public func copysign(_ sign: Vector<Float>, magnitude: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: sign.count)
    vvcopysignf(&results, magnitude, sign, [Int32(sign.count)])

    return results
}

public func copysign(_ sign: Vector<Double>, magnitude: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: sign.count)
    vvcopysign(&results, magnitude, sign, [Int32(sign.count)])

    return results
}

// MARK: Floor

public func floor(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvfloorf(&results, x, [Int32(x.count)])

    return results
}

public func floor(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvfloor(&results, x, [Int32(x.count)])

    return results
}

// MARK: Negate

public func neg(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vDSP_vneg(x, 1, &results, 1, vDSP_Length(x.count))

    return results
}

public func neg(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vDSP_vnegD(x, 1, &results, 1, vDSP_Length(x.count))

    return results
}

// MARK: Reciprocal

public func rec(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvrecf(&results, x, [Int32(x.count)])

    return results
}

public func rec(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvrec(&results, x, [Int32(x.count)])

    return results
}

// MARK: Round

public func round(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvnintf(&results, x, [Int32(x.count)])

    return results
}

public func round(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvnint(&results, x, [Int32(x.count)])

    return results
}

// MARK: Threshold

public func threshold(_ x: Vector<Float>, low: Float) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count), y = low
    vDSP_vthr(x, 1, &y, &results, 1, vDSP_Length(x.count))

    return results
}

public func threshold(_ x: Vector<Double>, low: Double) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count), y = low
    vDSP_vthrD(x, 1, &y, &results, 1, vDSP_Length(x.count))

    return results
}

// MARK: Truncate

public func trunc(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvintf(&results, x, [Int32(x.count)])

    return results
}

public func trunc(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvint(&results, x, [Int32(x.count)])

    return results
}

// MARK: Hyperbolic Sine

public func sinh(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvsinhf(&results, x, [Int32(x.count)])

    return results
}

public func sinh(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvsinh(&results, x, [Int32(x.count)])

    return results
}

// MARK: Hyperbolic Cosine

public func cosh(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvcoshf(&results, x, [Int32(x.count)])

    return results
}

public func cosh(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvcosh(&results, x, [Int32(x.count)])

    return results
}

// MARK: Hyperbolic Tangent

// Hyperbolic tangent (TanH) function
/// f(x) = tanh(x) = 2 / (1 + exp(-2x)) - 1
///
/// - Parameter: x Input Vector
/// - Returns: Vector of computed values
///
/// - References:
///   - https://en.wikipedia.org/wiki/Hyperbolic_function#Hyperbolic_tangent
public func tanh(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvtanhf(&results, x, [Int32(x.count)])
    return results
}

// Hyperbolic tangent (TanH) function
/// f(x) = tanh(x) = 2 / (1 + exp(-2x)) - 1
///
/// - Parameter: x Input Vector
/// - Returns: Vector of computed values
///
/// - References:
///   - https://en.wikipedia.org/wiki/Hyperbolic_function#Hyperbolic_tangent
public func tanh(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvtanh(&results, x, [Int32(x.count)])
    return results
}

// MARK: Inverse Hyperbolic Sine

public func asinh(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvasinhf(&results, x, [Int32(x.count)])

    return results
}

public func asinh(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvasinh(&results, x, [Int32(x.count)])

    return results
}

// MARK: Inverse Hyperbolic Cosine

public func acosh(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvacoshf(&results, x, [Int32(x.count)])

    return results
}

public func acosh(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvacosh(&results, x, [Int32(x.count)])

    return results
}

// MARK: Inverse Hyperbolic Tangent

public func atanh(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvatanhf(&results, x, [Int32(x.count)])

    return results
}

public func atanh(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvatanh(&results, x, [Int32(x.count)])

    return results
}

// MARK: Sine-Cosine

public func sincos(_ x: Vector<Float>) -> (sin: Vector<Float>, cos: Vector<Float>) {
    var sin = Vector<Float>(repeating: 0.0, count: x.count)
    var cos = Vector<Float>(repeating: 0.0, count: x.count)
    vvsincosf(&sin, &cos, x, [Int32(x.count)])

    return (sin, cos)
}

public func sincos(_ x: Vector<Double>) -> (sin: Vector<Double>, cos: Vector<Double>) {
    var sin = Vector<Double>(repeating: 0.0, count: x.count)
    var cos = Vector<Double>(repeating: 0.0, count: x.count)
    vvsincos(&sin, &cos, x, [Int32(x.count)])

    return (sin, cos)
}

// MARK: Sine

public func sin(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvsinf(&results, x, [Int32(x.count)])

    return results
}

public func sin(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvsin(&results, x, [Int32(x.count)])

    return results
}

// MARK: Cosine

public func cos(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvcosf(&results, x, [Int32(x.count)])

    return results
}

public func cos(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvcos(&results, x, [Int32(x.count)])

    return results
}

// MARK: Tangent

public func tan(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvtanf(&results, x, [Int32(x.count)])

    return results
}

public func tan(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvtan(&results, x, [Int32(x.count)])

    return results
}

// MARK: Arcsine

public func asin(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvasinf(&results, x, [Int32(x.count)])

    return results
}

public func asin(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvasin(&results, x, [Int32(x.count)])

    return results
}

// MARK: Arccosine

public func acos(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvacosf(&results, x, [Int32(x.count)])

    return results
}

public func acos(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvacos(&results, x, [Int32(x.count)])

    return results
}

// MARK: Arctangent

public func atan(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    vvatanf(&results, x, [Int32(x.count)])

    return results
}

public func atan(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    vvatan(&results, x, [Int32(x.count)])

    return results
}

// MARK: Radians to Degrees

func rad2deg(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    let divisor = Vector<Float>(repeating: Float.pi / 180.0, count: x.count)
    vvdivf(&results, x, divisor, [Int32(x.count)])

    return results
}

func rad2deg(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    let divisor = Vector<Double>(repeating: Double.pi / 180.0, count: x.count)
    vvdiv(&results, x, divisor, [Int32(x.count)])

    return results
}

// MARK: Degrees to Radians

func deg2rad(_ x: Vector<Float>) -> Vector<Float> {
    var results = Vector<Float>(repeating: 0.0, count: x.count)
    let divisor = Vector<Float>(repeating: 180.0 / Float.pi, count: x.count)
    vvdivf(&results, x, divisor, [Int32(x.count)])

    return results
}

func deg2rad(_ x: Vector<Double>) -> Vector<Double> {
    var results = Vector<Double>(repeating: 0.0, count: x.count)
    let divisor = Vector<Double>(repeating: 180.0 / Double.pi, count: x.count)
    vvdiv(&results, x, divisor, [Int32(x.count)])

    return results
}
