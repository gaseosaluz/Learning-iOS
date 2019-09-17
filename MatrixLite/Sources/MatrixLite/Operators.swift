//
// Copyright (c) 2017 Set. All rights reserved.
// Copyright (c) 2014 Mattt Thompson (http://mattt.me/)
//

import Foundation
import Accelerate

// MARK: Vector Operators

public func + (lhs: Vector<Float>, rhs: Vector<Float>) -> Vector<Float> {
    return add(lhs, y: rhs)
}

public func + (lhs: Vector<Double>, rhs: Vector<Double>) -> Vector<Double> {
    return add(lhs, y: rhs)
}

public func + (lhs: Vector<Float>, rhs: Float) -> Vector<Float> {
    return add(lhs, y: [Float](repeating: rhs, count: lhs.count))
}

public func + (lhs: Vector<Double>, rhs: Double) -> Vector<Double> {
    return add(lhs, y: Vector<Double>(repeating: rhs, count: lhs.count))
}

public func - (lhs: Vector<Float>, rhs: Vector<Float>) -> Vector<Float> {
    return sub(lhs, y: rhs)
}

public func - (lhs: Vector<Double>, rhs: Vector<Double>) -> Vector<Double> {
    return sub(lhs, y: rhs)
}

public func - (lhs: Vector<Float>, rhs: Float) -> Vector<Float> {
    return sub(lhs, y: Vector<Float>(repeating: rhs, count: lhs.count))
}

public func - (lhs: Vector<Double>, rhs: Double) -> Vector<Double> {
    return sub(lhs, y: Vector<Double>(repeating: rhs, count: lhs.count))
}

public func / (lhs: Vector<Float>, rhs: Vector<Float>) -> Vector<Float> {
    return div(lhs, y: rhs)
}

public func / (lhs: Vector<Double>, rhs: Vector<Double>) -> Vector<Double> {
    return div(lhs, y: rhs)
}

public func / (lhs: Vector<Float>, rhs: Float) -> Vector<Float> {
    return div(lhs, y: Vector<Float>(repeating: rhs, count: lhs.count))
}

public func / (lhs: Vector<Double>, rhs: Double) -> Vector<Double> {
    return div(lhs, y: Vector<Double>(repeating: rhs, count: lhs.count))
}

public func * (lhs: Vector<Float>, rhs: Vector<Float>) -> Vector<Float> {
    return mul(lhs, y: rhs)
}

public func * (lhs: Vector<Double>, rhs: Vector<Double>) -> Vector<Double> {
    return mul(lhs, y: rhs)
}

public func * (lhs: Vector<Float>, rhs: Float) -> Vector<Float> {
    return mul(lhs, y: Vector<Float>(repeating: rhs, count: lhs.count))
}

public func * (lhs: Vector<Double>, rhs: Double) -> Vector<Double> {
    return mul(lhs, y: Vector<Double>(repeating: rhs, count: lhs.count))
}

public func % (lhs: Vector<Float>, rhs: Vector<Float>) -> Vector<Float> {
    return mod(lhs, y: rhs)
}

public func % (lhs: Vector<Double>, rhs: Vector<Double>) -> Vector<Double> {
    return mod(lhs, y: rhs)
}

public func % (lhs: Vector<Float>, rhs: Float) -> Vector<Float> {
    return mod(lhs, y: Vector<Float>(repeating: rhs, count: lhs.count))
}

public func % (lhs: Vector<Double>, rhs: Double) -> Vector<Double> {
    return mod(lhs, y: Vector<Double>(repeating: rhs, count: lhs.count))
}

infix operator •
public func • (lhs: Vector<Double>, rhs: Vector<Double>) -> Double {
    return dot(lhs, y: rhs)
}

public func • (lhs: Vector<Float>, rhs: Vector<Float>) -> Float {
    return dot(lhs, y: rhs)
}

prefix operator -
public prefix func - (target: Vector<Double>) -> Vector<Double> {
    return neg(target)
}

public prefix func - (target: Vector<Float>) -> Vector<Float> {
    return neg(target)
}

// MARK: Matrix Operators

postfix operator +
public postfix func + (target: Matrix<Double>) -> Matrix<Double> {
    return pseudoInverse(target)
}

public postfix func + (target: Matrix<Float>) -> Matrix<Float> {
    return pseudoInverse(target)
}

public func + (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return add(lhs, y: rhs)
}

public func + (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return add(lhs, y: rhs)
}

public func - (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return sub(lhs, y: rhs)
}

public func - (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return sub(lhs, y: rhs)
}

public func * (lhs: Float, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, x: rhs)
}

public func * (lhs: Double, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, x: rhs)
}

public func * (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return mul(lhs, y: rhs)
}

public func * (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return mul(lhs, y: rhs)
}

public func / (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return div(lhs, y: rhs)
}

public func / (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return div(lhs, y: rhs)
}

public func / (lhs: Matrix<Double>, rhs: Double) -> Matrix<Double> {
    var result = Matrix<Double>(repeating: 0, rows: lhs.rows, columns: lhs.columns)
    result.data = lhs.data / rhs
    return result
}

public func / (lhs: Matrix<Float>, rhs: Float) -> Matrix<Float> {
    var result = Matrix<Float>(repeating: 0, rows: lhs.rows, columns: lhs.columns)
    result.data = lhs.data / rhs
    return result
}

postfix operator ′
public postfix func ′ (value: Matrix<Float>) -> Matrix<Float> {
    return transpose(value)
}

public postfix func ′ (value: Matrix<Double>) -> Matrix<Double> {
    return transpose(value)
}

// Element-wise multiplication
infix operator ×
public func × (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return elmul(lhs, y: rhs)
}

public func × (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return elmul(lhs, y: rhs)
}

// Element-wise division
infix operator ÷
public func ÷ (lhs: Matrix<Double>, rhs: Matrix<Double>) -> Matrix<Double> {
    return eldiv(lhs, y: rhs)
}

public func ÷ (lhs: Matrix<Float>, rhs: Matrix<Float>) -> Matrix<Float> {
    return eldiv(lhs, y: rhs)
}
