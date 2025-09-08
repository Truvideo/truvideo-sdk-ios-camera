//
//  Matrix+Operations.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 5/6/24.
//

import RealityKit
import simd

extension matrix_float4x4 {

    var position: SIMD3<Float> {
        get {
            let translation = columns.3
            return SIMD3<Float>(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = SIMD4<Float>(newValue.x, newValue.y, newValue.z, 1.0)
        }
    }

    func scaled(by scaleFactor: Float) -> matrix_float4x4 {
        let scaleInXMatrix = matrix_float4x4(diagonal: SIMD4<Float>(scaleFactor, 1, 1, 1))
        let scaleInYMatrix = matrix_float4x4(diagonal: SIMD4<Float>(1, scaleFactor, 1, 1))
        let scaleInZMatrix = matrix_float4x4(diagonal: SIMD4<Float>(1, 1, scaleFactor, 1))
        let scaleTransform = scaleInXMatrix * scaleInYMatrix * scaleInZMatrix
        return self * scaleTransform
    }

    func rotateOverXAxis(rotationAngle: Float) -> matrix_float4x4 {
        let rotationInXTransform = matrix_float4x4([
            simd_float4(1, 0, 0, 0),
            simd_float4(0, cos(rotationAngle), sin(rotationAngle), 0),
            simd_float4(0, -sin(rotationAngle), cos(rotationAngle), 0),
            simd_float4(0, 0, 0, 1),
        ])
        return self * rotationInXTransform
    }

    func rotateOverZAxis(rotationAngle: Float) -> matrix_float4x4 {
        let rotationInZTransform = matrix_float4x4([
            [cos(rotationAngle), -sin(rotationAngle), 0, 0],
            [sin(rotationAngle), cos(rotationAngle), 0, 0],
            [0, 0, 1, 0],
            [0, 0, 0, 1],
        ])
        return self * rotationInZTransform
    }

    func translatedBy(x: Float = 0, y: Float = 0, z: Float = 0) -> matrix_float4x4 {
        let translationTransform = matrix_float4x4([
            simd_float4(1, 0, 0, 0),
            simd_float4(0, 1, 0, 0),
            simd_float4(0, 0, 1, 0),
            simd_float4(x, y, z, 1),
        ])
        return self * translationTransform
    }

    func centerBetween(matrix1: matrix_float4x4, matrix2: matrix_float4x4) -> matrix_float4x4 {
        let positionA = matrix1.columns.3
        let positionB = matrix2.columns.3
        let centerPoint = (positionA + positionB) * 0.5

        var updatedMatrix = self
        let adjustedCenterPoint = centerPoint
        updatedMatrix.columns.3 = simd_float4(adjustedCenterPoint.x, adjustedCenterPoint.y, adjustedCenterPoint.z, 1.0)
        return updatedMatrix
    }

    func face(at target: matrix_float4x4) -> matrix_float4x4 {
        let anchorEntity = AnchorEntity(world: self)
        anchorEntity.look(at: target.position, from: self.position, relativeTo: nil)
        var rotationTransform = anchorEntity.transform.matrix
        rotationTransform.columns.3 = columns.3
        return rotationTransform
    }

    func interpolate(with end: matrix_float4x4, steps: Int) -> [matrix_float4x4] {
        var matrices: [matrix_float4x4] = []

        for step in 0 ... steps {
            let t = Float(step) / Float(steps)

            var interpolatedMatrix = matrix_float4x4()
            for i in 0 ..< 4 {
                for j in 0 ..< 4 {
                    interpolatedMatrix[i][j] = lerp(self[i][j], end[i][j], t)
                }
            }
            matrices.append(interpolatedMatrix)
        }

        return matrices
    }

    func distanceInCentimeters(to matrix: matrix_float4x4) -> String {
        let distanceInMeters = distanceTo(matrix: matrix)
        return " \(Int(distanceInMeters * 100))cm "
    }

    func distanceInInches(to matrix: matrix_float4x4) -> String {
        let distanceInMeters = distanceTo(matrix: matrix)
        return " \(formatFloat(distanceInMeters * 39))'' "
    }

    func distanceTo(matrix: matrix_float4x4) -> Float {
        let difference = self - matrix
        return frobeniusNorm(difference)
    }

    private func formatFloat(_ number: Float) -> String {
        if number == Float(Int(number)) {
            return String(format: "%.0f", number)
        } else {
            return String(format: "%.1f", number)
        }
    }

    // Function to calculate the Frobenius norm of a matrix
    private func frobeniusNorm(_ matrix: simd_float4x4) -> Float {
        var sum: Float = 0.0
        for i in 0 ..< 4 {
            let column = matrix[i]
            sum += column.x * column.x + column.y * column.y + column.z * column.z + column.w * column.w
        }
        return sqrt(sum)
    }

    // Function to linearly interpolate between two values
    private func lerp(_ start: Float, _ end: Float, _ t: Float) -> Float {
        start + (end - start) * t
    }

}
