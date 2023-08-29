//
//  ResponseSerializer.swift
//
//  Created by TruVideo on 8/08/23.
//  Copyright © TruVideo. All rights reserved.
//

@_implementationOnly import Alamofire
import Foundation

/// A  Serializer built in top of `Alamofire.ResponseSerializer` that allows more
/// fine grained block based serializations.
struct ResponseSerializer<SerializedObject: Decodable>: Alamofire.ResponseSerializer {
    let serializer: (URLRequest?, HTTPURLResponse?, Data?, Error?) throws -> SerializedObject

    // MARK: Initializers

    /// Creates a new instance of the `ResponseSerializer` configured with
    /// the serializer callback to use.
    ///
    /// - Parameter serializer: The callback to call when serializing the response.
    init(_ serializer: @escaping (URLRequest?, HTTPURLResponse?, Data?, Error?) throws -> SerializedObject) {
        self.serializer = serializer
    }

    // MARK: ResponseSerializer

    /// Serialize the response `Data` into the provided type..
    ///
    /// - Parameters:
    ///   - request:  `URLRequest` which was used to perform the request, if any.
    ///   - response: `HTTPURLResponse` received from the server, if any.
    ///   - data:     `Data` returned from the server, if any.
    ///   - error:    `Error` produced by Alamofire or the underlying `URLSession` during the request.
    /// - Returns:    The `SerializedObject`.
    /// - Throws:     Any `Error` produced during serialization.
    func serialize(
        request: URLRequest?,
        response: HTTPURLResponse?,
        data: Data?,
        error: Error?
    ) throws -> SerializedObject {

        try serializer(request, response, data, error)
    }
}
