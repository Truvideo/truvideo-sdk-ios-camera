//
//  Measure.swift
//  TruvideoSdkCamera
//
//  Created by Luis Francisco Piura Mejia on 14/6/24.
//

import Foundation

struct Measure {
    let origin: matrix_float4x4
    let end: matrix_float4x4

    func getMeasureLineVertices(
        radius: Float,
        segments: Int
    ) -> [SIMD4<Float>] {
        var vertices: [SIMD4<Float>] = []

        let direction = normalize(end.localization - origin.localization)
        let length = distance(origin.localization, end.localization)
        let angleStep = 2 * Float.pi / Float(segments)

        // Convert to 3-component vectors for cross product calculations
        let direction3 = SIMD3<Float>(direction.x, direction.y, direction.z)
        let up3 = SIMD3<Float>(0, 1, 0)  // Up vector

        // Calculate perpendicular vectors
        let right3 = normalize(cross(direction3, up3))
        let forward3 = normalize(cross(right3, direction3))

        // Convert back to 4-component vectors
        let right = SIMD4<Float>(right3.x, right3.y, right3.z, 0)
        let forward = SIMD4<Float>(forward3.x, forward3.y, forward3.z, 0)

        // Create vertices for the bottom and top circles
        for i in 0 ..< segments {
            let angle = Float(i) * angleStep
            let x = cos(angle) * radius
            let z = sin(angle) * radius

            // Bottom circle vertices
            let localPosBottom = SIMD4<Float>(x, 0, z, 0)
            let worldPosBottom = origin.localization + right * localPosBottom.x + forward * localPosBottom.z
            vertices.append(worldPosBottom)

            // Top circle vertices
            let localPosTop = SIMD4<Float>(x, length, z, 0)
            let worldPosTop =
                origin.localization + right * localPosTop.x + forward * localPosTop.z + direction * localPosTop.y
            vertices.append(worldPosTop)
        }

        // Add center vertices for the top and bottom faces
        vertices.append(origin.localization)  // Bottom center vertex
        vertices.append(end.localization)  // Top center vertex

        return vertices
    }

    func getMeasureLineIndices(segments: Int) -> [UInt16] {
        var indices: [UInt16] = []

        // Indices for the side faces
        for i in 0 ..< segments {
            let nextIndex = (i + 1) % segments
            indices.append(UInt16(i))
            indices.append(UInt16(i + segments))
            indices.append(UInt16(nextIndex))

            indices.append(UInt16(nextIndex))
            indices.append(UInt16(i + segments))
            indices.append(UInt16(nextIndex + segments))
        }

        // Indices for the bottom face
        let bottomCenterIndex = UInt16(segments * 2)
        for i in 0 ..< segments {
            indices.append(bottomCenterIndex)
            indices.append(UInt16(i))
            indices.append(UInt16((i + 1) % segments))
        }

        // Indices for the top face
        let topCenterIndex = UInt16(segments * 2 + 1)
        for i in 0 ..< segments {
            indices.append(topCenterIndex)
            indices.append(UInt16(i + segments))
            indices.append(UInt16(((i + 1) % segments) + segments))
        }

        return indices
    }
}

extension matrix_float4x4 {
    fileprivate var localization: SIMD4<Float> {
        columns.3
    }
}
